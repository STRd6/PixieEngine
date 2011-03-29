( ($) ->
  defaults =
    FPS: 33.3333
    ambientLight: 1
    backgroundColor: "#FFFFFF"
    cameraTransform: Matrix.IDENTITY

  shadowCanvas = $("<canvas width=640 height=480 />").powerCanvas()

  window.Engine = (I) ->
    $.reverseMerge I, defaults
  
    intervalId = null
    savedState = null
    age = 0
    paused = false

    queuedObjects = []
    objects = []
  
    update = ->
      objects = objects.select (object) ->
        object.update()
        
      objects = objects.concat(queuedObjects)
      queuedObjects = []
      
      self.trigger "update"

    draw = ->
      if I.ambientLight < 1
        shadowContext = shadowCanvas.context()
        shadowContext.globalCompositeOperation = "source-over"
        shadowCanvas.clear()
        # Fill with shadows
        shadowCanvas.fill("rgba(0, 0, 0, #{1 - I.ambientLight})")
  
        # Etch out the light
        shadowContext.globalCompositeOperation = "destination-out"
        shadowCanvas.withTransform I.cameraTransform, (shadowCanvas) ->
          objects.each (object, i) ->
            object.illuminate?(shadowCanvas)

      canvas.withTransform I.cameraTransform, (canvas) ->
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
  
    self = Core(I).extend
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
        
      collides: (bounds, sourceObject) ->
        objects.inject false, (collided, object) ->
          collided || (object.solid() && (object != sourceObject) && object.collides(bounds))
          
      rayCollides: (source, direction, sourceObject) ->
        hits = objects.map (object) ->
          hit = object.solid() && (object != sourceObject) && Collision.rayRectangle(source, direction, object.centeredBounds())
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
    
    self.attrAccessor "cameraTransform"
    self.include Bindable
    
    return self
)(jQuery)

