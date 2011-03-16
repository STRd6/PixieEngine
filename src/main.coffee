engine = Engine
  canvas: $("canvas").powerCanvas()
  
engine.add
  x: 32
  y: 32
  width: 32
  height: 32
  
engine.start()


$(document).mousedown (event) ->
  engine.add
    x: event.pageX.snap(32)
    y: event.pageY.snap(32)
    width: 32
    height: 32

$(document).bind "keydown", "f3", () ->
  engine.saveState()
  
$(document).bind "keydown", "f4", () ->
  engine.loadState()
  
$(document).bind "keydown", "f5", () ->
  engine.reload()

