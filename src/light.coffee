Light = (I) ->
  I ||= {}
  
  $.reverseMerge I,
    intensity: 1
    color: "orange"
    radius: 500
    shadows: true
  
  shadowCanvas = $("<canvas width=640 height=480 />").powerCanvas()
  
  lineTo = (canvas, dest, color) ->
    canvas.strokeColor color || "black"
    canvas.drawLine(I.x, I.y, dest.x, dest.y, 1)
    
  fillShape = (context, p1, p2, p3, p4) ->
    context.fillStyle = "rgba(0, 0, 0, 1)"
    context.beginPath()
    context.moveTo(p1.x, p1.y)
    context.lineTo(p2.x, p2.y)
    context.lineTo(p3.x, p3.y)
    context.lineTo(p4.x, p4.y)
    context.lineTo(p1.x, p1.y)
    context.fill()

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
    
  generateRadialGradient = (I, context, quadratic) ->
    ###
      c1 = x: I.x, y: I.y, radius: 0
      c2 = x: I.x, y: I.y, radius: I.radius
      
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
    
    radgrad = context.createRadialGradient(I.x, I.y, 0, I.x, I.y, I.radius)
    
    radgrad.addColorStop(0, "#000")

    if quadratic
      radgrad.addColorStop(0.25, "rgba(0, 0, 0, 0.5625)")
      radgrad.addColorStop(0.5, "rgba(0, 0, 0, 0.25)")
      radgrad.addColorStop(0.75, "rgba(0, 0, 0, 0.0625)")

    radgrad.addColorStop(1, "rgba(0, 0, 0, 0)")
    
    radgrad
    

  self = GameObject(I).extend
    draw: (canvas) ->
      #canvas.fillCircle(I.x, I.y, 10, I.color)
      
    illuminate: (canvas) ->
      shadowContext = shadowCanvas.context()
      shadowContext.globalAlpha = I.intensity
      shadowContext.globalCompositeOperation = "source-over"
      shadowCanvas.clear()

      radgrad = generateRadialGradient(I, shadowContext, true)
      shadowCanvas.fillCircle(I.x, I.y, I.radius, radgrad)

      if I.shadows
        shadowContext.globalAlpha = 1
        shadowContext.globalCompositeOperation = "destination-out"
  
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
            
            fillShape(shadowContext, veryFar[0], farCorners[0], farCorners[1], veryFar[1])
          
          
      shadows = shadowCanvas.element()
      canvas.drawImage(shadows, 0, 0, shadows.width, shadows.height, 0, 0, shadows.width, shadows.height)

