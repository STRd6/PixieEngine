Moogle = (I) ->
  I ||= {}
  
  GRAVITY = Point(0, 2)
  SCREEN_WIDTH = 640
  MAX_SHIELD = 64
  INVULNERABILITY_DURATION = 32
  PLAYER_COLORS = [
    "#00F"
    "#F00"
    "#0F0"
    "#FF0"
    "orange"
    "#F0F"
    "#0FF"
  ]

  $.reverseMerge I,
    acceleration: Point(0, 0)
    controller: 0
    cooldown: 0
    destructable: true
    disabled: 0
    excludedModules: ["Movable"]
    height: 24
    invulnerable: INVULNERABILITY_DURATION
    mobile: true
    opaque: true
    score: 0
    shielding: false
    shieldStrength: MAX_SHIELD
    speed: 6
    solid: true
    velocity: Point(0, 0)
    width: 16

  # Cast acceleration and velocity to points
  I.acceleration = Point(I.acceleration.x, I.acceleration.y)
  I.velocity = Point(I.velocity.x, I.velocity.y)
  
  # I.sprite = Sprite.fromPixieId(12525)
  I.sprite = null

  I.color = PLAYER_COLORS[I.controller]
  actionDown = CONTROLLERS[I.controller].actionDown

  jumping = false
  falling = true
  lastDirection = 1
  shooting = false
  
  PHYSICS =
    platform: () ->
      I.shielding = false
      shooting = false

      if jumping
        I.velocity.y += GRAVITY.scale(0.5).y
      else if falling
        I.velocity.y += GRAVITY.y
      else
        if actionDown "A"
          jumping = true
          I.velocity.y = -7 * GRAVITY.y - 2
        else if actionDown "C"
          if I.shieldStrength > 0
            I.shielding = true
            I.shieldStrength -= 1
          else
            I.disabled = 96

      unless I.shielding || I.disabled
        I.shieldStrength = I.shieldStrength.approach(MAX_SHIELD, 0.25)

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
  
  drawHud = (canvas) ->
    screenPadding = 5
    hudWidth = 80
    hudHeight = 40
    hudMargin = 10
  
    canvas.withTransform Matrix.translation(I.controller * (hudWidth + hudMargin) + screenPadding, 0), (canvas) ->
      canvas.clearRect(0, 0, hudWidth, hudHeight)

      color = Color(I.color)
      color.a 0.5
      
      canvas.fillColor color
      canvas.fillRoundRect 0, -5, hudWidth, hudHeight
      
      canvas.fillColor "#FFF"
      canvas.fillText "PLAYER #{I.controller + 1}", 5, 12
      canvas.fillText "SCORE: #{I.score}", 5, 28
  
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
      if hitObject.I.shielding || hitObject.I.invulnerable
        fireBeam(endPoint, Point.fromAngle(Random.angle()), hitObject)
        hitObject.I.shieldStrength -= 5
      else if hitObject.I.destructable
        if hitObject == self
          I.score -= 1
        else if hitObject.I.class == I.class
          I.score += 1

        hitObject.destroy()
        
  shieldGradient = (strength, context) ->
    radgrad = context.createRadialGradient(4, -4, 0, 0, 0, 16)

    a = 0.75 * strength / MAX_SHIELD
    edgeAlpha = 0.75 + 0.25 * strength / MAX_SHIELD

    radgrad.addColorStop(0, "rgba(255, 255, 255, #{a})")
  
    radgrad.addColorStop(0.25, "rgba(0, 255, 0, #{a})")
    radgrad.addColorStop(0.9, "rgba(0, 255, 0, #{a})")
  
    radgrad.addColorStop(1, "rgba(0, 200, 0, #{edgeAlpha})")
    
    radgrad

  self = GameObject(I).extend
    illuminate: (canvas) ->
      center = self.centeredBounds()

      if I.invulnerable
        center.radius = Math.sin(I.age * Math.TAU / 36) * 16 + 24
      else if I.disabled
        center.radius = rand(16) + 16
      else
        center.radius = 32

      if I.shielding || I.disabled || I.invulnerable
        canvas.fillCircle(center.x, center.y, center.radius, Light.radialGradient(center, canvas.context()))

      beams.each (beam) ->
        canvas.strokeColor("#000")
        canvas.drawLine(beam[0].x, beam[0].y, beam[1].x, beam[1].y, 2.25)
    
    after:
      draw: (canvas, hud) ->
        center = self.centeredBounds()
        if I.shielding
          canvas.withTransform Matrix.translation(center.x, center.y), (canvas) ->
            canvas.fillCircle(0, 0, 16, shieldGradient(I.shieldStrength, canvas.context()))

        # TODO: Move beams to top layer
        beams.each (beam) ->
          canvas.strokeColor(I.color)
          canvas.drawLine(beam[0].x, beam[0].y, beam[1].x, beam[1].y, 2)
          
        drawHud hud
  
    before:
      update: ->
        beams = []
        I.cooldown -= 1 if I.cooldown > 0
        I.disabled -= 1 if I.disabled > 0
        I.invulnerable -= 1 if I.invulnerable > 0

        if I.disabled
          I.velocity = I.velocity.add(Point.fromAngle(Random.angle()).scale(rand(4)))

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
            intensity: 0.75
            radius: 100
            x: I.x + I.width/2 + I.velocity.x
            y: I.y + I.height/2 + I.velocity.y
            duration: 6
            shadows: false
            step: "I.radius = I.radius / 4"

          center = self.centeredBounds()
          fireBeam(center, shootDirection, self)

        if (I.disabled % 4) == 3
          engine.add
            class: "Emitter"
            duration: 5
            sprite: Sprite.EMPTY
            velocity: Point(0, 0)
            particleCount: 9
            batchSize: 5
            x: I.x
            y: I.y
            generator:
              color: I.color
              duration: 15
              height: (n) ->
                particleSizes.rand()
              maxSpeed: 5
              velocity: (n) ->
                Point.fromAngle(Random.angle()).scale(rand(3) + 2)
              width: (n) ->
                particleSizes.rand()

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
        duration: 3
        height: (n) ->
          particleSizes.wrap(n) * 3
        maxSpeed: 35
        velocity: (n) ->
          Point.fromAngle(Random.angle()).scale(rand(5) + 5)
        width: (n) ->
          particleSizes.wrap(n) * 3

    # Respawn
    engine.add $.extend({}, I,
      x: [0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, 480, 512, 544, 576, 608].rand()
      y: [0, -2 * I.height, -4 * I.height, -6 * I.height, -8 * I.height, -10 * I.height].rand()
      disabled: 0
      invulnerable: INVULNERABILITY_DURATION
      shieldStrength: MAX_SHIELD
    )

    I.active = false

  self

