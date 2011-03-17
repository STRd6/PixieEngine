Moogle = (I) ->
  I ||= {}
  
  GRAVITY = Point(0, 2)
  
  $.reverseMerge I,
    color: "blue"
    speed: 6
    acceleration: Point(0, 0)
    solid: false
    width: 16
    height: 16
    velocity: Point(0, 0)
    excludedModules: ["Movable"]

  # Cast acceleration and velocity to points
  I.acceleration = Point(I.acceleration.x, I.acceleration.y)
  I.velocity = Point(I.velocity.x, I.velocity.y)

  jumping = false
  falling = true
  lastDirection = 1
  shooting = false
  laserEndpoint = null
  
  PHYSICS =
    platform: () ->
      if jumping
        I.velocity.y += GRAVITY.scale(0.5).y
      else if falling
        I.velocity.y += GRAVITY.y
      else

        if keydown.up
          jumping = true
          I.velocity.y = -7 * GRAVITY.y - 2
        
      # Move around based on input
      if keydown.right
        I.velocity.x += 2
      if keydown.left
        I.velocity.x -= 2
      unless keydown.left || keydown.right
        I.velocity.x = 0
      unless keydown.up
        jumping = false
        
      shooting = keydown.space
        
      if I.velocity.x.sign()
        lastDirection = I.velocity.x.sign() 
        
      I.velocity.x = I.velocity.x.clamp(-8, 8)
      
    arena: () ->
      I.velocity.y = I.velocity.y.approach(0, 1)
      I.velocity.x = I.velocity.x.approach(0, 1)
      
      if Game.keydown("right")
        I.velocity.x += 2
      if Game.keydown("left")
        I.velocity.x -= 2
      if Game.keydown("up")
        I.velocity.y -= 2
      if Game.keydown("down")
        I.velocity.y += 2

      I.velocity.y = I.velocity.y.clamp(-I.speed, I.speed)
      I.velocity.x = I.velocity.x.clamp(-I.speed, I.speed)
  
  physics = PHYSICS.platform
    
  self = GameObject(I).extend
    draw: (canvas) ->
      if laserEndpoint
        canvas.strokeColor("#008")
        canvas.drawLine(I.x, I.y, laserEndpoint.x, laserEndpoint.y, 2)

      canvas.fillColor I.color
      canvas.fillRect I.x, I.y, I.width, I.height

  
    before:
      update: ->
        if engine.collides(self.bounds(0, 1))
          falling = false
        else
          falling = true

        physics()

        #TODO Reduct the # of calls to collides
        I.velocity.x.abs().times ->
          if !engine.collides(self.bounds(I.velocity.x.sign(), 0))
            I.x += I.velocity.x.sign()
          else 
            I.velocity.x = 0
    
        #TODO Reduct the # of calls to collides
        I.velocity.y.abs().times ->
          if !engine.collides(self.bounds(0, I.velocity.y.sign()))
            I.y += I.velocity.y.sign()
          else 
            I.velocity.y = 0
            jumping = false

        if Mouse.left
          shootDirection = Mouse.location.subtract(I)
        else if shooting
          shootDirection = Point(lastDirection, 0)

        laserEndpoint = null
          
        if shootDirection
          if nearestHit = engine.rayCollides(I, shootDirection)
            laserEndpoint = nearestHit
            object = nearestHit.object

          if laserEndpoint
            engine.add
              class: "Emitter"
              duration: 10
              sprite: Sprite.EMPTY
              velocity: Point(0, 0)
              particleCount: 2
              batchSize: 5
              x: laserEndpoint.x
              y: laserEndpoint.y
              generator:
                color: "rgba(255, 128, 255, 0.7)"  
                duration: 3
                maxSpeed: 5
                velocity: (n) ->
                  Point.fromAngle(Random.angle()).scale(rand(5) + 1)
          else
            laserEndpoint = shootDirection.norm().scale(1000).add(I)
                  
        if object?.I.wizard
          killWizard object
      
        engine.eachObject (object) ->
          if object.I.open && Collision.rectangular(I, object.bounds())
            if I.active
              I.active = false
              engine.queue(nextLevel)
    
  self

