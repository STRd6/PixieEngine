window.engine = Engine
  canvas: $("canvas").powerCanvas()
  
20.times (i) ->
  engine.add
    x: 32 * i
    y: 32 * 14
    width: 32
    height: 32
    solid: true
    
engine.add
  class: "Moogle"
  
engine.start()

developer = false

$(document).mousedown (event) ->
  if developer
    engine.add
      x: event.pageX.snap(32)
      y: event.pageY.snap(32)
      width: 32
      height: 32
      solid: true

$(document).bind "keydown", "esc", () ->
  developer = !developer

  if developer
    engine.pause()
  else
    engine.play()

$(document).bind "keydown", "f3", () ->
  engine.saveState()
  
$(document).bind "keydown", "f4", () ->
  engine.loadState()
  
$(document).bind "keydown", "f5", () ->
  engine.reload()

