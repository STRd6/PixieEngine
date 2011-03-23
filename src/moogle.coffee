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
  
  laserColors = [
    "rgba(255, 0, 128, 0.75)"
    "rgba(255, 0, 128, 0.75)"
    "rgba(255, 0, 128, 0.75)"
    "rgba(255, 255, 255, 0.25)"
    "rgba(32, 190, 230, 0.25)"
  ]
  
  particleSizes = [2, 8, 4, 6]
    
  self = GameObject(I).extend
    before:
      draw: (canvas) ->
        laserStart = self.centeredBounds()
        if laserEndpoint
          5.times ->
            canvas.strokeColor laserColors.rand()
            canvas.drawLine(laserStart.x, laserStart.y, laserEndpoint.x, laserEndpoint.y, 2)
            
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
          if nearestHit = engine.rayCollides(self.centeredBounds(), shootDirection)
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
              duration: 1
              x: laserEndpoint.x
              y: laserEndpoint.y

          else
            laserEndpoint = shootDirection.norm().scale(1000).add(I)
                  
        if object?.I.destructable
          object.I.active = false
          engine.add
            class: "Emitter"
            duration: 10
            sprite: Sprite.EMPTY
            velocity: Point(0, 0)
            particleCount: 15
            batchSize: 5
            x: object.I.width / 2 + object.I.x
            y: object.I.height / 2 + object.I.y
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
      
        engine.eachObject (object) ->
          if object.I.open && Collision.rectangular(I, object.bounds())
            if I.active
              I.active = false
              engine.queue(nextLevel)
    
  self

