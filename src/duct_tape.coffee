# Just pasting things here until updating libraries is easier
 
`Array.prototype.wrap = function(start, length) {
  if(length != null) {
    var end = start + length;
    var result = [];
  
    for(var i = start; i < end; i++) {
      result.push(this[i.mod(this.length)]);
    }
  
    return result;
  } else {
    return this[start.mod(this.length)];
  }
};

/*
 * jQuery Hotkeys Plugin
 * Copyright 2010, John Resig
 * Dual licensed under the MIT or GPL Version 2 licenses.
 *
 * Based upon the plugin by Tzury Bar Yochay:
 * http://github.com/tzuryby/hotkeys
 *
 * Original idea by:
 * Binny V A, http://www.openjs.com/scripts/events/keyboard_shortcuts/
*/

(function(jQuery){
  
  jQuery.hotkeys = {
    version: "0.8",

    specialKeys: {
      8: "backspace", 9: "tab", 13: "return", 16: "shift", 17: "ctrl", 18: "alt", 19: "pause",
      20: "capslock", 27: "esc", 32: "space", 33: "pageup", 34: "pagedown", 35: "end", 36: "home",
      37: "left", 38: "up", 39: "right", 40: "down", 45: "insert", 46: "del", 
      96: "0", 97: "1", 98: "2", 99: "3", 100: "4", 101: "5", 102: "6", 103: "7",
      104: "8", 105: "9", 106: "*", 107: "+", 109: "-", 110: ".", 111 : "/", 
      112: "f1", 113: "f2", 114: "f3", 115: "f4", 116: "f5", 117: "f6", 118: "f7", 119: "f8", 
      120: "f9", 121: "f10", 122: "f11", 123: "f12", 144: "numlock", 145: "scroll", 188: ",", 191: "/", 224: "meta"
    },
  
    shiftNums: {
      "\`": "~", "1": "!", "2": "@", "3": "#", "4": "$", "5": "%", "6": "^", "7": "&", 
      "8": "*", "9": "(", "0": ")", "-": "_", "=": "+", ";": ": ", "'": "\"", ",": "<", 
      ".": ">",  "/": "?",  "\\": "|"
    }
  };

  function keyHandler( handleObj ) {
    // Only care when a possible input has been specified
    if ( typeof handleObj.data !== "string" ) {
      return;
    }
    
    var origHandler = handleObj.handler,
      keys = handleObj.data.toLowerCase().split(" ");
  
    handleObj.handler = function( event ) {
      // Don't fire in text-accepting inputs that we didn't directly bind to
      if ( this !== event.target && (/textarea|select/i.test( event.target.nodeName ) ||
         event.target.type === "text" || event.target.type === "password") ) {
        return;
      }
      
      // Keypress represents characters, not special keys
      var special = event.type !== "keypress" && jQuery.hotkeys.specialKeys[ event.which ],
        character = String.fromCharCode( event.which ).toLowerCase(),
        key, modif = "", possible = {};

      // check combinations (alt|ctrl|shift+anything)
      if ( event.altKey && special !== "alt" ) {
        modif += "alt+";
      }

      if ( event.ctrlKey && special !== "ctrl" ) {
        modif += "ctrl+";
      }
      
      // TODO: Need to make sure this works consistently across platforms
      if ( event.metaKey && !event.ctrlKey && special !== "meta" ) {
        modif += "meta+";
      }

      if ( event.shiftKey && special !== "shift" ) {
        modif += "shift+";
      }

      if ( special ) {
        possible[ modif + special ] = true;

      } else {
        possible[ modif + character ] = true;
        possible[ modif + jQuery.hotkeys.shiftNums[ character ] ] = true;

        // "$" can be triggered as "Shift+4" or "Shift+$" or just "$"
        if ( modif === "shift+" ) {
          possible[ jQuery.hotkeys.shiftNums[ character ] ] = true;
        }
      }

      for ( var i = 0, l = keys.length; i < l; i++ ) {
        if ( possible[ keys[i] ] ) {
          return origHandler.apply( this, arguments );
        }
      }
    };
  }

  jQuery.each([ "keydown", "keyup", "keypress" ], function() {
    jQuery.event.special[ this ] = { add: keyHandler };
  });

})( jQuery );
`
( ($) ->
  $.fn.powerCanvas = (options) ->
    options ||= {}

    canvas = this.get(0)
    context = undefined

    ###*
     * @name PowerCanvas
     * @constructor
    ###
    $canvas = $(canvas).extend
      ###*
       * Passes this canvas to the block with the given matrix transformation
       * applied. All drawing methods called within the block will draw
       * into the canvas with the transformation applied. The transformation
       * is removed at the end of the block, even if the block throws an error.
       *
       * @name withTransform
       * @methodOf PowerCanvas#
       *
       * @param {Matrix} matrix
       * @param {Function} block
       * @returns this
      ###
      withTransform: (matrix, block) ->
        context.save()

        context.transform(
          matrix.a,
          matrix.b,
          matrix.c,
          matrix.d,
          matrix.tx,
          matrix.ty
        )

        try
          block(this)
        finally
          context.restore()

        return this

      clear: ->
        context.clearRect(0, 0, canvas.width, canvas.height)

        return this
      
      context: ->
        context
      
      element: ->
        canvas
      
      createLinearGradient: (x0, y0, x1, y1) ->
        context.createLinearGradient(x0, y0, x1, y1)
      
      createRadialGradient: (x0, y0, r0, x1, y1, r1) ->
        context.createRadialGradient(x0, y0, r0, x1, y1, r1)
        
      buildRadialGradient: (c1, c2, stops) ->
        gradient = context.createRadialGradient(c1.x, c1.y, c1.radius, c2.x, c2.y, c2.radius)

        for position, color of stops
          gradient.addColorStop(position, color)

        return gradient

      createPattern: (image, repitition) ->
        context.createPattern(image, repitition)

      drawImage: (image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight) ->
        context.drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)

        return this

      drawLine: (x1, y1, x2, y2, width) ->
        if arguments.length == 3
          width = x2
          x2 = y1.x
          y2 = y1.y
          y1 = x1.y
          x1 = x1.x


        width ||= 3

        context.lineWidth = width
        context.beginPath()
        context.moveTo(x1, y1)
        context.lineTo(x2, y2)
        context.closePath()
        context.stroke()
        
        return this

      fill: (color) ->
        $canvas.fillColor(color)
        context.fillRect(0, 0, canvas.width, canvas.height)

        return this

      ###*
       * Fills a circle at the specified position with the specified
       * radius and color.
       *
       * @name fillCircle
       * @methodOf PowerCanvas#
       *
       * @param {Number} x
       * @param {Number} y
       * @param {Number} radius
       * @param {Number} color
       * @see PowerCanvas#fillColor 
       * @returns this
      ###
      fillCircle: (x, y, radius, color) ->
        $canvas.fillColor(color)
        context.beginPath()
        context.arc(x, y, radius, 0, Math.TAU, true)
        context.closePath()
        context.fill()

        return this

      ###*
       * Fills a rectangle with the current fillColor
       * at the specified position with the specified
       * width and height 
      
       * @name fillRect
       * @methodOf PowerCanvas#
       *
       * @param {Number} x
       * @param {Number} y
       * @param {Number} width
       * @param {Number} height
       * @see PowerCanvas#fillColor 
       * @returns this
      ###
      
      fillRect: (x, y, width, height) ->
        context.fillRect(x, y, width, height)

        return this

      ###*
      * Adapted from http://js-bits.blogspot.com/2010/07/canvas-rounded-corner-rectangles.html
      ###
      
      fillRoundRect: (x, y, width, height, radius, strokeWidth) ->
        radius ||= 5
        
        context.beginPath()
        context.moveTo(x + radius, y)
        context.lineTo(x + width - radius, y)
        context.quadraticCurveTo(x + width, y, x + width, y + radius)
        context.lineTo(x + width, y + height - radius)
        context.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
        context.lineTo(x + radius, y + height)
        context.quadraticCurveTo(x, y + height, x, y + height - radius)
        context.lineTo(x, y + radius)
        context.quadraticCurveTo(x, y, x + radius, y)
        context.closePath()

        if strokeWidth
          context.lineWidth = strokeWidth
          context.stroke()
        
        context.fill()

        return this

      fillText: (text, x, y) ->
        context.fillText(text, x, y)

        return this

      centerText: (text, y) ->
        textWidth = $canvas.measureText(text)

        $canvas.fillText(text, (canvas.width - textWidth) / 2, y)

      fillWrappedText: (text, x, y, width) ->
        tokens = text.split(" ")
        tokens2 = text.split(" ")
        lineHeight = 16

        if $canvas.measureText(text) > width
          if tokens.length % 2 == 0
            tokens2 = tokens.splice(tokens.length / 2, (tokens.length / 2), "")
          else
            tokens2 = tokens.splice(tokens.length / 2 + 1, (tokens.length / 2) + 1, "")

          context.fillText(tokens.join(" "), x, y)
          context.fillText(tokens2.join(" "), x, y + lineHeight)
        else
          context.fillText(tokens.join(" "), x, y + lineHeight)

      fillColor: (color) ->
        if color
          if color.channels
            context.fillStyle = color.toString()
          else
            context.fillStyle = color
          
          return this
        else
          return context.fillStyle

      font: (font) ->
        if font?
          context.font = font
          
          return this
        else
          context.font

      measureText: (text) ->
        context.measureText(text).width

      putImageData: (imageData, x, y) ->
        context.putImageData(imageData, x, y)

        return this

      strokeColor: (color) ->
        if color
          if color.channels
            context.strokeStyle = color.toString()
          else
            context.strokeStyle = color

          return this
        else
          return context.strokeStyle
      
      strokeRect: (x, y, width, height) ->
        context.strokeRect(x, y, width, height)

        return this

      textAlign: (textAlign) ->
        context.textAlign = textAlign
        
        return this

      height: ->
        canvas.height

      width: ->
        return canvas.width

    if canvas?.getContext
      context = canvas.getContext('2d')

      if options.init
        options.init($canvas)

      return $canvas

)(jQuery)
