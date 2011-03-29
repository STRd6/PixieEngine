Camera = (I) ->
  I ||= {}

  $.extend I,
    camera: true
    solid: false
    width: 320
    height: 240

  self = GameObject(I).extend
    draw: (canvas) ->
      canvas.fillColor "rgba(0, 255, 255, 0.25)"
      canvas.fillRect(0, 0, I.width, I.height)

    cameraTransform: ->
      Matrix.translation(-I.x, -I.y)

