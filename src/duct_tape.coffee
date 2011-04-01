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
      120: "f9", 121: "f10", 122: "f11", 123: "f12", 144: "numlock", 145: "scroll", 
      186: ";",
      187: "=",
      188: ",",
      189: "-",  
      190: ".",
      191: "/",
      219: "[",
      220: "\\",
      221: "]",
      222: "'",
      224: "meta"
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
 
if(false) {
  (function() {
    var soundPath = "http://pixie.strd6.com/production/projects/8/sounds/";
    
    function pathForPixieId(id) {
      return soundPath + id + ".mp3";
    }
  
    /**
    * Create SMSound instances.
    * @name Sound
    * @constructor
    *
    * @param {Number} pixieId The id of the sound to create.
    * @param [options] Options to pass to SoundManager
    *
    * @returns An SMSound instance for the given id.
    * @type SMSound
    */
    function Sound(pixieId, options) {
      options = options || {};
  
      options.id = pixieId;
      options.url = pathForPixieId(pixieId);
      options.multishot = true
      
      return soundManager.createSound(options);
    }
    
    /**
    * Loads initializes and plays the specified sound.
    * @name play
    * @methodOf Sound
    *
    * @param {Number} pixieId The id of the sound to play.
    * @param [options] Options to pass to SoundManager
    *
    * @returns An SMSound instance.
    * @type SMSound
    */
    Sound.play = function(pixieId, options) {
      var sound = Sound(pixieId, options);
      sound.play();
      
      return sound;
    };
    
    window.Sound = Sound;
  }());
} else {
  var Sound = (function($) {
    // TODO: detecting audio with canPlay is f***ed
    // Hopefully get more robust later
    // audio.canPlayType("audio/ogg") === "maybe" WTF?
    // http://ajaxian.com/archives/the-doctor-subscribes-html-5-audio-cross-browser-support
    var format = ".wav";
    var soundPath = "http://pixie.strd6.com/production/projects/8/sounds/";
    var sounds = {};
  
    function loadSoundChannel(name) {
      var sound = $('<audio />').get(0);
      sound.autobuffer = true;
      sound.preload = 'auto';
      sound.src = soundPath + name + format;
  
      return sound;
    }
    
    function Sound(id, maxChannels) {
      return {
        play: function() {
          Sound.play(id, maxChannels);
        },
  
        stop: function() {
          Sound.stop(id);
        }
      }
    }
  
    return $.extend(Sound, {
      play: function(id, maxChannels) {
        // TODO: Too many channels crash Chrome!!!1
        maxChannels = maxChannels || 4;
  
        if(!sounds[id]) {
          sounds[id] = [loadSoundChannel(id)];
        }
  
        var freeChannels = $.grep(sounds[id], function(sound) {
          return sound.currentTime == sound.duration || sound.currentTime == 0
        });
  
        if(freeChannels[0]) {
          try {
            freeChannels[0].currentTime = 0;
          } catch(e) {
          }
          freeChannels[0].play();
        } else {
          if(!maxChannels || sounds[id].length < maxChannels) {
            var sound = loadSoundChannel(id);
            sounds[id].push(sound);
            sound.play();
          }
        }
      },
                                  
      playFromUrl: function(url) {
        var sound = $('<audio />').get(0);
        sound.src = url;
      
        sound.play();
    
        return sound;
      },
  
      stop: function(id) {
        if(sounds[id]) {
          sounds[id].stop();
        }
      }
    });
  }(jQuery));
}
`

