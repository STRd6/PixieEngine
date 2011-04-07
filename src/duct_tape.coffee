# Just pasting things here until updating libraries is easier

`
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

