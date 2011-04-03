Controller = (actions) ->
  actions ||=
    up: "up"
    right: "right"
    down: "down"
    left: "left"
    A: "home"
    B: "end"
    C: "pageup"
    D: "pagedown"

  actionDown: (triggers...) ->
    triggers.inject false, (down, action) ->
      down || keydown[actions[action]]

CONTROLLERS = []
# Dvorak Keyboard layout controllers
[{
  up: "up"
  right: "right"
  down: "down"
  left: "left"
  A: "end"
  B: "home"
  C: "pagedown"
  D: "pageup"
}, {
  up: "o"
  right: "q"
  down: ";"
  left: "a"
  A: "2"
  B: "1"
  C: ","
  D: "'"
}, {
  up: "u"
  right: "k"
  down: "j"
  left: "e"
  A: "4"
  B: "3"
  C: "p"
  D: "."
}, {
  up: "d"
  right: "b"
  down: "x"
  left: "i"
  A: "6"
  B: "5"
  C: "f"
  D: "y"
}, {
  up: "t"
  right: "w"
  down: "m"
  left: "h"
  A: "8"
  B: "7"
  C: "c"
  D: "g"
}, {
  up: "s"
  right: "z"
  down: "v"
  left: "n"
  A: "0"
  B: "9"
  C: "l"
  D: "r"
}, {
  up: "="
  right: "return"
  down: "-"
  left: "/"
  A: "]"
  B: "["
  C: "\\"
  D: "backspace"
}].each (actions, i) ->
  CONTROLLERS[i] = Controller(actions)

