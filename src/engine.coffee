Engine = (options) ->
  options ||= {}

  intervalId = null
  savedState = null
  age = 0
  FPS = options.FPS || 33.3333
  
  objects = []

  update = ->
    objects = objects.select (object) ->
      object.update()

  draw = ->
    canvas.fill("#080")
    objects.invoke("draw", canvas)
    
  step = ->
    update()
    draw()
    
    age += 1
 
  canvas = options.canvas || $("<canvas />").powerCanvas()
  
  construct = (entityData) ->
    if entityData.class
      entityData.class.constantize()(entityData)
    else
      GameObject(entityData)

  self =
    add: (entityData) ->
      obj = construct entityData
        
      objects.push obj

    #TODO: This is only used in testing and should be removed when possible
    age: ->
      age

    #TODO: This is a bad idea in case access is attempted during update
    objects: ->
      objects
      
    rewind: () ->
      
      
    saveState: () ->
      savedState = objects.map (object) ->
        $.extend({}, object.I)

    loadState: () ->
      if savedState
        objects = savedState.map (objectData) ->
          construct $.extend({}, objectData)

    reload: () ->
      objects = objects.map (object) ->
        construct object.I

    play: () ->
      unless intervalId
        intervalId = setInterval(() ->
          step()
        , 1000 / FPS)
      
    pause: () ->
      clearInterval(intervalId)
      intervalId = null
      
    setFramerate: (newFPS) ->
      FPS = newFPS
      self.pause()
      self.play()

