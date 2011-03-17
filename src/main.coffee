window.engine = Engine
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
  
engine.start()

developer = false

$(document).mousedown (event) ->
  if developer
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
  engine.saveState()
  
$(document).bind "keydown", "f4", () ->
  engine.loadState()
  
$(document).bind "keydown", "f5", () ->
  engine.reload()

