EngineSelector = 
  parse: (selector) ->
    selector.split(",").map (result) ->
      result.trim()

  process: (item) ->
    result = /^(\w+)?#?([\w\-]+)?\.?([\w\-]+)?/.exec(item)

    if result
      result.splice(1)
    else
      []

