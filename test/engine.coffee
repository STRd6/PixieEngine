test "Engine", ->
  ok(Engine)

asyncTest "Running Engine", ->
  engine = Engine()
  engine.play()
  
  milliseconds = 2000
  
  setTimeout ->
    engine.pause()
    age = engine.age()
    ok(64 <= age <= 68, "Engine ran #{age} steps in #{milliseconds}ms")

    start()
  , milliseconds

test "save and restore", ->
  engine = Engine()
  
  engine.add {}
  engine.add {}
  
  
