Camera = (I) ->
  I ||= {}
  
  # TODO globalize width/height
  $.reverseMerge I,
    width: 640
    height: 480

  self = GameObject(I).extend
    cameraTransform: ->
      Matrix.translation(I.width / 2 - I.x, I.height / 2 I.y)

