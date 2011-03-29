window.engine = Engine 
  ambientLight: 0.025
  canvas: $("canvas").powerCanvas()

block = 
  color: "#CB8"
  width: 32
  height: 32
  solid: true
    
20.times (i) ->
  engine.add $.extend(
    x: 32 * i
    y: 32 * 14
  , block)
    
engine.add
  class: "Moogle"
  x: 320
  y: 240

if level = Local.get("level")
  engine.loadState level
else if level1
  engine.loadState level1

engine.start()

# Player Spawner
engine.bind "update", ->
  CONTROLLERS.each (controller, i) ->
    if controller.actionDown "D"
      exists = false
      engine.eachObject (o) ->
        exists ||= o.I.controller == i

      unless exists
        engine.add
          class: "Moogle"
          controller: i
          x: [64, 256, 320, 512].rand()
          y: -16

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

