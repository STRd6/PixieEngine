Light = (I) ->
  I ||= {}
  
  lightCanvas = $("<canvas width=640 height=480 />").powerCanvas()
  lightCanvas.context().globalAlpha = 0.5
  
  lineTo = (canvas, dest, color) ->
    canvas.strokeColor color || "black"
    canvas.drawLine(I.x, I.y, dest.x, dest.y, 1)
    
  fillShape = (context, p1, p2, p3, p4) ->
    context.fillColor = "rgba(0, 0, 0, 0.5)"
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

  self = GameObject(I).extend
    draw: (canvas) ->
      lightCanvas.clear()
      lcContext = lightCanvas.context()

      canvas.fillCircle(I.x, I.y, 10, "orange")

      engine.eachObject (object) ->
        if(object.I.opaque)
          corners(object).each (corner) ->
            ;#lineTo(canvas, corner)
            
          farCorners = farthestCorners(object, canvas)
          #lineTo(canvas, farCorners[0], "green")
          #lineTo(canvas, farCorners[1], "red")
          
          veryFar = [
            farCorners[0].subtract(I).norm().scale(1000)
            farCorners[1].subtract(I).norm().scale(1000)
          ]
          
          fillShape(lcContext, veryFar[0], farCorners[0], farCorners[1], veryFar[1])
          
          
      lighting = lightCanvas.element()
      canvas.drawImage(lighting, 0, 0, lighting.width, lighting.height, 0, 0, lighting.width, lighting.height)

