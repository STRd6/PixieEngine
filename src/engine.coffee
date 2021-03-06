( ($) ->
  defaults =
    FPS: 33.3333
    backgroundColor: "#FFFFFF"
    ambientLight: 1
    
  shadowCanvas = $("<canvas width=640 height=480 />").powerCanvas()
 
  window.Engine = (I) ->
    $.reverseMerge I, defaults
  
    intervalId = null
    savedState = null
    age = 0
    paused = false

    queuedObjects = []
    objects = []

    cameraTransform = Matrix.IDENTITY
  
    update = ->
      objects = objects.select (object) ->
        object.update()
        
      objects = objects.concat(queuedObjects)
      queuedObjects = []

    draw = ->
      if I.ambientLight < 1
        lightSources = objects.inject 0, (count, object) -> 
          count + if object.illuminate then 1 else 0
  
        shadowContext = shadowCanvas.context()
        shadowContext.globalCompositeOperation = "source-over"
        shadowCanvas.clear()
        # Fill with shadows
        shadowCanvas.fill("rgba(0, 0, 0, #{1 - I.ambientLight})")
  
        # Etch out the light
        shadowContext.globalCompositeOperation = "destination-out"
        shadowCanvas.withTransform cameraTransform, (shadowCanvas) ->
          objects.each (object, i) ->
            object.illuminate?(shadowCanvas)

      canvas.withTransform cameraTransform, (canvas) ->
        if I.backgroundColor
          canvas.fill(I.backgroundColor)
        objects.invoke("draw", canvas)

      if I.ambientLight < 1
        shadows = shadowCanvas.element()
        canvas.drawImage(shadows, 0, 0, shadows.width, shadows.height, 0, 0, shadows.width, shadows.height)      

    step = ->
      unless paused
        update()
        age += 1

      draw()
   
    canvas = I.canvas || $("<canvas />").powerCanvas()
    
    construct = (entityData) ->
      if entityData.class
        entityData.class.constantize()(entityData)
      else
        GameObject(entityData)
  
    self =
      add: (entityData) ->
        obj = construct entityData
        
        if intervalId && !paused
          queuedObjects.push obj
        else
          objects.push obj
          
      construct: construct
  
      #TODO: This is only used in testing and should be removed when possible
      age: ->
        age
  
      #TODO: This is a bad idea in case access is attempted during update
      objects: ->
        objects
        
      objectAt: (x, y) ->
        targetObject = null
        bounds =
          x: x
          y: y
          width: 1
          height: 1

        self.eachObject (object) ->
          targetObject = object if object.collides(bounds)

        return targetObject
        
      eachObject: (iterator) ->
        objects.each iterator
        
      collides: (bounds) ->
        objects.inject false, (collided, object) ->
          collided || (object.solid() && object.collides(bounds))
          
      rayCollides: (source, direction) ->
        hits = objects.map (object) ->
          hit = object.solid() && Collision.rayRectangle(source, direction, object.centeredBounds())
          hit.object = object if hit
          
          hit
          
        nearestDistance = Infinity
        nearestHit = null
    
        hits.each (hit) ->
          if hit && (d = hit.distance(source)) < nearestDistance
            nearestDistance = d
            nearestHit = hit
            
        nearestHit
        
      rewind: () ->
        
        
      saveState: () ->
        savedState = objects.map (object) ->
          $.extend({}, object.I)
  
      loadState: (newState) ->
        if newState ||= savedState
          objects = newState.map (objectData) ->
            construct $.extend({}, objectData)
  
      reload: () ->
        objects = objects.map (object) ->
          construct object.I
  
      start: () ->
        unless intervalId
          intervalId = setInterval(() ->
            step()
          , 1000 / I.FPS)
        
      stop: () ->
        clearInterval(intervalId)
        intervalId = null
        
      play: ->
        paused = false
        
      pause: ->
        paused = true
        
      paused: ->
        paused
        
      setFramerate: (newFPS) ->
        I.FPS = newFPS
        self.stop()
        self.start()
)(jQuery)

