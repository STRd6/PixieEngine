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

# Dvorak Keyboard layout controllers
[{
  up: "up"
  right: "right"
  down: "down"
  left: "left"
  A: "end"
  B: "home"
  C: "pageup"
  D: "pagedown"
}, {
  up: "o"
  right: "q"
  down: ";"
  left: "a"
  A: "2"
  B: "1"
  C: "'"
  D: ","
}, {
  up: "u"
  right: "k"
  down: "j"
  left: "e"
  A: "4"
  B: "3"
  C: "."
  D: "p"
}, {
  up: "d"
  right: "b"
  down: "x"
  left: "i"
  A: "6"
  B: "5"
  C: "y"
  D: "f"
}, {
  up: "t"
  right: "w"
  down: "m"
  left: "h"
  A: "8"
  B: "7"
  C: "g"
  D: "c"
}, {
  up: "s"
  right: "z"
  down: "v"
  left: "n"
  A: "0"
  B: "9"
  C: "r"
  D: "l"
}, {
  up: "="
  right: "return"
  down: "-"
  left: "/"
  A: "]"
  B: "["
  C: "backspace"
  D: "\\"
}].each (actions, i) ->
  Controller[i] = Controller(actions)

