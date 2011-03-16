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
    
  self =
    add: (entityData) ->
      obj = construct entityData
        
      objects.push obj
      
    age: ->
      age
      
    rewind: () ->
      
      
    saveState: () ->
      savedState = objects.map (object) ->
        $.extend({}, object.I)
      log "saved state"

    loadState: () ->
      if savedState
        objects = savedState.map (objectData) ->
          construct $.extend({}, objectData)
      log "loaded state"

    reload: () ->
      objects = objects.map (object) ->
        construct object.I
      log "reloaded!"

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

