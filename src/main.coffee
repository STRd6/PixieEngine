window.engine = Engine 
  ambientLight: 0.05
  canvas: $("canvas").powerCanvas()

block = 
  color: "#CB8"
  width: 32
  height: 32
  solid: true
  opaque: true

20.times (i) ->
  engine.add $.extend(
    x: 32 * i
    y: 32 * 14
  , block)
    
engine.add
  class: "Moogle"
  x: 320
  y: 240

levels = [level1, level3, level4, level5, level6]

engine.loadState levels.rand()

PLAY_TO = 50
 
engine.start()

engine.bind "update", ->
  playerInfo = {}
  
  engine.eachObject (o) ->
    if o.I.controller? 
      playerInfo[o.I.controller] = o.I
      
  # Winner?
  highestScore = 0
  winningPlayers = []
  
  for id, info of playerInfo
    id = parseInt(id, 10)

    if info.score > highestScore
      highestScore = info.score
      winningPlayers = [id]
    else if playerInfo.score == highestScore
      winningPlayers.push[id]
      
  if highestScore >= PLAY_TO
    if winningPlayers.length == 1
      alert "Player #{winningPlayers[0] + 1} Wins!"
    else
      alert "Tie Between Players #{winningPlayers.map((n)-> n + 1).join(', ')}"
    
    engine.loadState levels.rand()
    return

  # Player Spawner
  CONTROLLERS.each (controller, i) ->
    if controller.actionDown "D"
      exists = playerInfo[i]

      unless exists
        engine.add
          class: "Moogle"
          controller: i
          x: [64, 256, 320, 512].rand()
          y: -16

  # Camera Tracking
  engine.eachObject (o) ->
    if o.I.camera
      engine.cameraTransform o.cameraTransform()

developer = false

objectToUpdate = null
window.updateObjectProperties = (newProperties) ->
  if objectToUpdate
    $.extend objectToUpdate, engine.construct(newProperties)

$(document).bind "contextmenu", (event) ->
  event.preventDefault()

$(document).mousedown (event) ->
  if developer
    console.log event.which

    if event.which == 3
      if object = engine.objectAt(event.pageX, event.pageY)
        parent.editProperties(object.I)
        
        objectToUpdate = object
        
      console.log object
    else if event.which == 2 || keydown.shift
      engine.add $.extend(
        x: event.pageX.snap(32)
        y: event.pageY.snap(32)
      , block)

$(document).bind "keydown", "esc", () ->
  developer = !developer

  if developer
    engine.pause()
  else
    engine.play()

$(document).bind "keydown", "f3", () ->
  Local.set("level", engine.saveState())
  
$(document).bind "keydown", "f4", () ->
  engine.loadState(Local.get("level"))
  
$(document).bind "keydown", "f5", () ->
  engine.reload()

