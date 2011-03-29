Camera = (I) ->
  I ||= {}

  self = GameObject(I).extend
    cameraTransform: ->
      Matrix.translation(I.width / 2 - I.x, I.height / 2 I.y)

