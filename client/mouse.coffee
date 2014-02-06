# This file exports one global boolean, mouse_down, which is true if and
# only if the mouse is currently down.

@mouse_down = false


document.onmousedown = ->
  window.mouse_down = true
  return


document.onmouseup = ->
  window.mouse_down = false
  return
