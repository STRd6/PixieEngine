Moogle = (I) ->
  I ||= {}
  
  GRAVITY = Point(0, 2)
  SCREEN_WIDTH = 640
  
  $.reverseMerge I,
    controller: 0
    color: "blue"
    cooldown: 0
    destructable: true
    shielding: false
    speed: 6
    acceleration: Point(0, 0)
    solid: true
    width: 16
    height: 24
    velocity: Point(0, 0)
    excludedModules: ["Movable"]

  # Cast acceleration and velocity to points
  I.acceleration = Point(I.acceleration.x, I.acceleration.y)
  I.velocity = Point(I.velocity.x, I.velocity.y)
  I.sprite = Sprite.fromPixieId(12525)

  jumping = false
  falling = true
  lastDirection = 1
  shooting = false

  actions = [{
    up: "up"
    right: "right"
    down: "down"
    left: "left"
    A: "return"
    B: "space"
    C: "pageup"
  }, {
    up: ","
    right: "e"
    down: "o"
    left: "a"
    A: "2"
    B: "1"
    C: "'"
  }][I.controller]

  actionDown = (triggers...) ->
    triggers.inject false, (down, action) ->
      down || keydown[actions[action]]
  
  PHYSICS =
    platform: () ->
      I.shielding = false
    
      if jumping
        I.velocity.y += GRAVITY.scale(0.5).y
      else if falling
        I.velocity.y += GRAVITY.y
      else
        if actionDown "A"
          jumping = true
          I.velocity.y = -7 * GRAVITY.y - 2
        else if actionDown "C"
          I.shielding = true
        
      unless I.shielding
        # Move around based on input
        if actionDown "right"
          I.velocity.x += 2
          lastDirection = 1
        if actionDown "left"
          I.velocity.x -= 2
          lastDirection = -1
        unless actionDown("A")
          jumping = false
          
        shooting = actionDown("B")

        ###
          if actionDown "up"
            shooting = true
          if actionDown "down"
            shooting = true
        ###

      if I.shielding || !(actionDown("left") || actionDown("right"))
        I.velocity.x = I.velocity.x.approach(0, 2)

      I.velocity.x = I.velocity.x.clamp(-8, 8)

  physics = PHYSICS.platform
  
  particleSizes = [2, 8, 4, 6]
  
  laserParticleEffects = (target) ->
    engine.add
      class: "Emitter"
      duration: 10
      sprite: Sprite.EMPTY
      velocity: Point(0, 0)
      particleCount: 2
      batchSize: 5
      x: target.x
      y: target.y
      generator:
        color: Color(255, 0, 0, 0.5)
        duration: 3
        height: (n) ->
          particleSizes.wrap(n)
        maxSpeed: 5
        velocity: (n) ->
          Point.fromAngle(Random.angle()).scale(rand(5) + 1)
        width: (n) ->
          particleSizes.wrap(n)
          
    engine.add
      class: "Light"
      radius: 50
      x: target.x
      y: target.y
      duration: 3
      shadows:false
      step: "I.radius = I.radius / 2"
      
  beams = []

  fireBeam = (sourcePoint, direction, sourceObject) ->
    if nearestHit = engine.rayCollides(sourcePoint, direction, sourceObject)
      endPoint = nearestHit
      hitObject = nearestHit.object

    if endPoint
      laserParticleEffects(endPoint)
    else
      endPoint = direction.norm().scale(1000).add(sourcePoint)

    beams.push [sourcePoint, endPoint]

    if hitObject?.I
      if hitObject.I.shielding
        ;
      else if hitObject.I.destructable
        hitObject.destroy()

  self = GameObject(I).extend
    illuminate: (canvas) ->
      center = self.centeredBounds()
      center.radius = 32
      
      if I.shielding
        canvas.fillCircle(center.x, center.y, center.radius, Light.radialGradient(center, canvas.context()))
    
      beams.each (beam) ->
        canvas.strokeColor("#000")
        canvas.drawLine(beam[0].x, beam[0].y, beam[1].x, beam[1].y, 2)
    
    after:
      draw: (canvas) ->
        center = self.centeredBounds()
        if I.shielding
          canvas.fillCircle(center.x, center.y, 16, "rgba(0, 255, 0, 0.75)")
  
    before:
      draw: (canvas) ->
        beams.each (beam) ->
          canvas.strokeColor(I.color)
          canvas.drawLine(beam[0].x, beam[0].y, beam[1].x, beam[1].y, 2)
            
      update: ->
        beams = []
        I.cooldown -= 1 if I.cooldown > 0

        if engine.collides(self.bounds(0, 1), self)
          falling = false
        else
          falling = true

        physics()

        #TODO Reduct the # of calls to collides
        I.velocity.x.abs().times ->
          if !engine.collides(self.bounds(I.velocity.x.sign(), 0), self)
            I.x += I.velocity.x.sign()
          else 
            I.velocity.x = 0
    
        #TODO Reduct the # of calls to collides
        I.velocity.y.abs().times ->
          if !engine.collides(self.bounds(0, I.velocity.y.sign()), self)
            I.y += I.velocity.y.sign()
          else 
            I.velocity.y = 0
            jumping = false

        if Mouse.left
          shootDirection = Mouse.location.subtract(I)
        else if shooting
          shootX = 0
          shootY = 0

          if actionDown "left"
            shootX += -1
          if actionDown "right"
            shootX += 1
          
          if actionDown "up"
            shootY += -1
          if actionDown "down"
            shootY += 1
          
          if shootY == 0 && shootX == 0
            shootDirection = Point(lastDirection, 0)
          else
            shootDirection = Point(shootX, shootY)
          
        if shootDirection && (I.cooldown == 0)
          I.cooldown += 15
          Sound.play("laser")
          I.velocity = I.velocity.add(shootDirection.norm().scale(-8))
          
          engine.add
            class: "Light"
            intensity: 0.66
            radius: 100
            x: I.x + I.width/2 + I.velocity.x
            y: I.y + I.height/2 + I.velocity.y
            duration: 4
            shadows: false
            step: "I.radius = I.radius / 4"

          center = self.centeredBounds()
          fireBeam(center, shootDirection, self)
      
        engine.eachObject (object) ->
          if object.I.open && Collision.rectangular(I, object.bounds())
            if I.active
              I.active = false
              engine.queue(nextLevel)

        I.x = I.x.clamp(0, SCREEN_WIDTH - I.width)
            
  self.bind 'destroy', ->
    Sound.play("hit")

    engine.add
      class: "Emitter"
      duration: 10
      sprite: Sprite.EMPTY
      velocity: Point(0, 0)
      particleCount: 15
      batchSize: 5
      x: I.width / 2 + I.x
      y: I.height / 2 + I.y
      generator:
        color: "rgba(200, 140, 235, 0.7)"
        duration: 15
        height: (n) ->
          particleSizes.wrap(n) * 3
        maxSpeed: 35
        velocity: (n) ->
          Point.fromAngle(Random.angle()).scale(rand(5) + 5)
        width: (n) ->
          particleSizes.wrap(n) * 3
          
    engine.add $.extend({}, I,
      x: [64, 256, 320, 512].rand()
      y: -I.height
    )
    
    I.active = false

  self

