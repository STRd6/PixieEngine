Light = (I) ->
  I ||= {}
  
  lightCanvas = $("<canvas width=640 height=480 />").powerCanvas()
  lightCanvas.context().globalAlpha = 0.5
  
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
      lightCanvas.clear()
      lightCanvas.fill Color(0, 0, 0, 0.5)
      
      #canvas.fill lightCanvas.element()

      canvas.fillCircle(I.x, I.y, 10, "orange")

      engine.eachObject (object) ->
        if(object.I.opaque)
          corners(object).each (corner) ->
            ;#lineTo(canvas, corner)
            
          farCorners = farthestCorners(object, canvas)
          lineTo(canvas, farCorners[0], "green")
          lineTo(canvas, farCorners[1], "red")

