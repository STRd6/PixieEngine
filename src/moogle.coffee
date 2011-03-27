Moogle = (I) ->
  I ||= {}
  
  GRAVITY = Point(0, 2)
  
  $.reverseMerge I,
    controller: 0
    color: "blue"
    cooldown: 0
    destructable: true
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

  jumping = false
  falling = true
  lastDirection = 1
  shooting = false
  laserEndpoint = null

  actions = [{
    up: "up"
    right: "right"
    down: "down"
    left: "left"
    A: "enter"
    B: "space"
  }, {
    up: ","
    right: "e"
    down: "o"
    left: "a"
    A: "2"
    B: "1"
  }][I.controller]

  actionDown = (actions...) ->
    actions.inject false, (down, action)
      down || keydown[actions[action]]
  
  PHYSICS =
    platform: () ->
      if jumping
        I.velocity.y += GRAVITY.scale(0.5).y
      else if falling
        I.velocity.y += GRAVITY.y
      else

        if actionDown "up", "A"
          jumping = true
          I.velocity.y = -7 * GRAVITY.y - 2
        
      # Move around based on input
      if actionDown "right"
        I.velocity.x += 2
      if actionDown "left"
        I.velocity.x -= 2
      unless actionDown("left") || actionDown("right")
        I.velocity.x = 0
      unless actionDown("up")
        jumping = false
        
      shooting = actionDown("B")
        
      if I.velocity.x.sign()
        lastDirection = I.velocity.x.sign() 
        
      I.velocity.x = I.velocity.x.clamp(-8, 8)
  
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
          canvas.strokeColor I.color
          canvas.drawLine(laserStart.x, laserStart.y, laserEndpoint.x, laserEndpoint.y, 2)
            
      update: ->
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
          shootDirection = Point(lastDirection, 0)

        laserEndpoint = null
          
        if shootDirection && (I.cooldown == 0)
          I.cooldown += 15
          engine.add
            class: "Light"
            color: "rgba(255, 0, 0, 0.25)"
            intensity: 0.5
            radius: 100
            x: I.x + I.width/2 + I.velocity.x
            y: I.y + I.height/2 + I.velocity.y
            duration: 3
            shadows: false
            step: ->
              I.radius = I.radius / 2
        
          center = self.centeredBounds()
          if nearestHit = engine.rayCollides(center, shootDirection, self)
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
              color: "rgba(255, 0, 0, 0.25)"
              radius: 50
              x: laserEndpoint.x
              y: laserEndpoint.y
              duration: 1

          else
            laserEndpoint = shootDirection.norm().scale(1000).add(I)
                  
        if object?.I.destructable
          object.destroy()
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
    
    
  self.bind 'destroy', ->
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

