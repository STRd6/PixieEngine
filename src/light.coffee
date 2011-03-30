Light = (I) ->
  I ||= {}

  $.reverseMerge I,
    cacheStatic: false
    intensity: 1
    color: "orange"
    radius: 500
    shadows: true
    flicker: false

  flickerState = "on"
 
  if I.shadows
    I.cacheStatic = true
 
  if I.cacheStatic
    cacheBuilt = false
    cachedShadowCanvas = $("<canvas width=640 height=480 />").powerCanvas()

  lineTo = (canvas, dest, color) ->
    canvas.strokeColor color || "black"
    canvas.drawLine(I.x, I.y, dest.x, dest.y, 1)

  corners = (object) ->
    ((I) ->
      return [
        Point(I.x, I.y)
        Point(I.x + I.width, I.y)
        Point(I.x, I.y + I.height)
        Point(I.x + I.width, I.y + I.height)
      ]
    )(object.I)
    
  farthestCorners = (object, canvas) ->
    originPoint = Point(I.x, I.y)
    ((I) ->
  
      centerLine = object.center().subtract(originPoint)
      
      min = max = undefined
      minCross = maxCross = undefined
  
      corners(object).each (corner) ->
        lineToCorner = corner.subtract(originPoint)
        newCross = centerLine.cross(lineToCorner)
        
        # canvas.fillColor("#F0F")
        # canvas.fillText (newCross * 100).round()/100, corner.x, corner.y
        
        if min?
          if newCross < minCross
            min = corner
            minCross = newCross
        else
          min = corner
          minCross = newCross
  
        if max?
          if newCross > maxCross
            max = corner
            maxCross = newCross
        else
          max = corner
          maxCross = newCross
          
      return [min, max]
    )(object.I)
    
  drawLightSource = (canvas) ->
    context = canvas.context()
    context.globalAlpha = I.intensity

    radgrad = Light.radialGradient(I, context, true)
    canvas.fillCircle(I.x, I.y, I.radius, radgrad)
    
  setCanvasToRemove = (canvas) ->
    canvas
      .globalAlpha(1)
      .compositeOperation("destination-out")
      .fillColor("#000")
      
  drawObjectShadows = (object, canvas) ->
    farCorners = farthestCorners(object, canvas)

    veryFar = [
      farCorners[0].subtract(I).norm().scale(1000).add(farCorners[0])
      farCorners[1].subtract(I).norm().scale(1000).add(farCorners[1])
    ]

    canvas.fillShape veryFar[0], farCorners[0], farCorners[1], veryFar[1]

  self = GameObject(I).extend
    draw: (canvas) ->
      #canvas.fillCircle(I.x, I.y, 10, I.color)
      
    illuminate: (canvas) ->
      if I.flicker
        r = rand()
        if r < 0.05
          flickerState = "off"
        else if r < 0.10
          flickerState = "on"

        return if flickerState == "off"

      if I.shadows
        if I.cacheStatic
          if cacheBuilt
            staticCanvas = null
            mobileCanvas = Light.shadowCanvas()
            mobileCanvas
              .globalAlpha(1)
              .compositeOperation("source-over")
            cached = cachedShadowCanvas.element()
            mobileCanvas.drawImage(cached, 0, 0, cached.width, cached.height, 0, 0, cached.width, cached.height)
          else
            staticCanvas = cachedShadowCanvas
            staticCanvas
              .globalAlpha(1)
              .compositeOperation("source-over")

            drawLightSource(staticCanvas)
            mobileCanvas = Light.shadowCanvas()
            cached = cachedShadowCanvas.element()
            mobileCanvas.drawImage(cached, 0, 0, cached.width, cached.height, 0, 0, cached.width, cached.height)
        else
          mobileCanvas = staticCanvas = Light.shadowCanvas()
          mobileCanvas
            .globalAlpha(1)
            .compositeOperation("source-over")

          drawLightSource(mobileCanvas)

        setCanvasToRemove(mobileCanvas)
        setCanvasToRemove(staticCanvas) if staticCanvas

        engine.eachObject (object) ->
          if object.I.opaque
            if cacheBuilt
              if object.I.mobile
                drawObjectShadows(object, mobileCanvas)
            else
              if object.I.mobile
                drawObjectShadows(object, mobileCanvas)
              else
                drawObjectShadows(object, staticCanvas) if I.cacheStatic
                

        cacheBuilt = true if I.cacheStatic

        shadows = mobileCanvas.element()
        canvas.drawImage(shadows, 0, 0, shadows.width, shadows.height, 0, 0, shadows.width, shadows.height)
      else
        drawLightSource(canvas)

( ->
  canvas = $("<canvas width=640 height=480 />").powerCanvas()
  Light.shadowCanvas = ->
    canvas.clear()
    canvas
)()

Light.radialGradient = (c, context, quadratic) ->
  ###
    c1 = x: c.x, y: c.y, radius: 0
    c2 = x: c.x, y: c.y, radius: c.radius
    
    stops =
      0: "#000"
      1: "rgba(0, 0, 0, 0)"
    
    if quadratic
      $.extend stops,
        "0.25": "rgba(0, 0, 0, 0.5625)"
        "0.5": "rgba(0, 0, 0, 0.25)"
        "0.75": "rgba(0, 0, 0, 0.0625)"

    canvas.buildRadialGradient(c1, c2, stops)
  ###
  
  radgrad = context.createRadialGradient(c.x, c.y, 0, c.x, c.y, c.radius)
  
  radgrad.addColorStop(0, "#000")

  if quadratic
    radgrad.addColorStop(0.25, "rgba(0, 0, 0, 0.5625)")
    radgrad.addColorStop(0.5, "rgba(0, 0, 0, 0.25)")
    radgrad.addColorStop(0.75, "rgba(0, 0, 0, 0.0625)")

  radgrad.addColorStop(1, "rgba(0, 0, 0, 0)")
  
  radgrad

