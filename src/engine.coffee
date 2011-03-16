( ($) ->
  defaults =
    FPS: 33.3333
 
  window.Engine = (options) ->
    options = $.extend({}, defaults, options)
  
    intervalId = null
    savedState = null
    age = 0
    paused = false
    FPS = options.FPS
    
    objects = []
  
    update = ->
      objects = objects.select (object) ->
        object.update()
  
    draw = ->
      canvas.fill("#080")
      objects.invoke("draw", canvas)
      
    step = ->
      unless paused
        update()
        age += 1

      draw()
   
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
  
      start: () ->
        unless intervalId
          intervalId = setInterval(() ->
            step()
          , 1000 / FPS)
        
      stop: () ->
        clearInterval(intervalId)
        intervalId = null
        
      play: ->
        paused = false
        
      pause: ->
        paused = true
        
      setFramerate: (newFPS) ->
        FPS = newFPS
        self.pause()
        self.play()
)(jQuery)

