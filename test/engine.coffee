test "Engine", ->
  ok(Engine)

test "save and restore", ->
  engine = Engine()
  
  engine.add {}
  engine.add {}
  
  equals(engine.objects().length, 2)
  
  engine.saveState()
  
  engine.add {}
  
  equals(engine.objects().length, 3)
  
  engine.loadState()
  
  equals(engine.objects().length, 2)

asyncTest "Running Engine", ->
  engine = Engine()
  engine.start()
  
  milliseconds = 2000
  
  setTimeout ->
    engine.pause()
    age = engine.age()
    ok(64 <= age <= 68, "Engine ran #{age} steps in #{milliseconds}ms")

    start()
  , milliseconds

