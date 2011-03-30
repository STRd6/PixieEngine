Light = (I) ->
  I ||= {}

  $.reverseMerge I,
    cacheStatic: false
    intensity: 1
    color: "orange"
    radius: 500
    shadows: true

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

  self = GameObject(I).extend
    draw: (canvas) ->
      #canvas.fillCircle(I.x, I.y, 10, I.color)
      
    illuminate: (canvas) ->
      radgrad = Light.radialGradient(I, canvas.context(), true)

      if I.shadows
        shadowCanvas = Light.shadowCanvas()
        shadowContext = shadowCanvas.context()
        shadowContext.globalAlpha = I.intensity
        shadowContext.globalCompositeOperation = "source-over"
        shadowCanvas.clear()
        shadowCanvas.fillCircle(I.x, I.y, I.radius, radgrad)
      
        shadowContext.globalAlpha = 1
        shadowContext.globalCompositeOperation = "destination-out"
        shadowCanvas.fillColor('#000')
  
        engine.eachObject (object) ->
          if(object.I.opaque)
            corners(object).each (corner) ->
              ;#lineTo(canvas, corner)
              
            farCorners = farthestCorners(object, canvas)
            #lineTo(canvas, farCorners[0], "green")
            #lineTo(canvas, farCorners[1], "red")
            
            veryFar = [
              farCorners[0].subtract(I).norm().scale(1000).add(farCorners[0])
              farCorners[1].subtract(I).norm().scale(1000).add(farCorners[1])
            ]
            
            shadowCanvas.fillShape veryFar[0], farCorners[0], farCorners[1], veryFar[1]


        shadows = shadowCanvas.element()
        canvas.drawImage(shadows, 0, 0, shadows.width, shadows.height, 0, 0, shadows.width, shadows.height)
      else
        canvas.fillCircle(I.x, I.y, I.radius, radgrad)

( ->
  canvas = $("<canvas width=640 height=480 />").powerCanvas()
  Light.shadowCanvas = ->
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

