( ($) ->
  defaults =
    FPS: 33.3333
    ambientLight: 1
    backgroundColor: "#FFFFFF"
    cameraTransform: Matrix.IDENTITY
    excludedModules: []
    includedModules: []
    objects: []

  window.Engine = (I) ->
    I ||= {}

    $.reverseMerge I, defaults

    intervalId = null
    age = 0
    paused = false

    queuedObjects = []
  
    update = ->
      I.objects = I.objects.select (object) ->
        object.update()
        
      I.objects = I.objects.concat(queuedObjects)
      queuedObjects = []
      
      self.trigger "update"
      
    drawDeveloperOverlay = (canvas) ->
      #TODO: Move this into the debug draw method of the objects themselves
      canvas.withTransform I.cameraTransform, (canvas) ->
        I.objects.each (object) ->
          canvas.fillColor 'rgba(255, 0, 0, 0.5)'
          canvas.fillRect(object.bounds().x, object.bounds().y, object.bounds().width, object.bounds().height)
          
      canvas.fillColor 'rgba(0, 0, 0, 0.5)'
      canvas.fillRect(430, 10, 200, 60)
      canvas.fillColor '#fff'
      canvas.fillText("Developer Mode. Press Esc to resume", 440, 25)
      canvas.fillText("Shift+Left click to add boxes", 440, 43)
      canvas.fillText("Right click red boxes to edit properties", 440, 60)

    draw = ->
      canvas.withTransform I.cameraTransform, (canvas) ->
        if I.backgroundColor
          canvas.fill(I.backgroundColor)

        I.objects.invoke("draw", canvas)

      self.trigger "draw", canvas

      drawDeveloperOverlay(canvas) if paused

    step = ->
      unless paused
        update()
        age += 1

      draw()
   
    canvas = I.canvas || $("<canvas />").powerCanvas()
  
    self = Core(I).extend
      add: (entityData) ->
        obj = GameObject.construct entityData
        
        if intervalId && !paused
          queuedObjects.push obj
        else
          I.objects.push obj
  
      #TODO: This is only used in testing and should be removed when possible
      age: ->
        age
  
      #TODO: This is a bad idea in case access is attempted during update
      objects: ->
        I.objects
        
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
        I.objects.each iterator

      find: (selector) ->
        results = []

        matcher = EngineSelector.generate(selector)

        I.objects.each (object) ->
          results.push object if matcher.match object

        $.extend results, EngineSelector.instanceMethods

      collides: (bounds, sourceObject) ->
        I.objects.inject false, (collided, object) ->
          collided || (object.solid() && (object != sourceObject) && object.collides(bounds))
          
      rayCollides: (source, direction, sourceObject) ->
        hits = I.objects.map (object) ->
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
    
    self.attrAccessor "ambientLight"
    self.attrAccessor "backgroundColor"
    self.attrAccessor "cameraTransform"
    self.include Bindable

    defaultModules = ["Shadows", "HUD", "SaveState"]
    modules = defaultModules.concat(I.includedModules)
    modules = modules.without(I.excludedModules)

    modules.each (moduleName) ->
      self.include Engine[moduleName]

    return self
)(jQuery)

