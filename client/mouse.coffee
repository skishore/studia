# This file exports one global boolean, mouse_down, which is true if and
# only if the mouse is currently down.

@mouse_down = false


document.onmousedown = ->
  window.mouse_down = true
  return


document.onmouseup = ->
  window.mouse_down = false
  return


device = ->
  device_regex = /android|webos|iphone|ipad|ipod|blackberry|iemobile|opera mini/i
  device_regex.test navigator.userAgent.toLowerCase()


Meteor.startup ->
  window.touch_enabled = do device

  if window.touch_enabled
    document.body.addEventListener 'touchmove', ((e) ->
      do e.preventDefault
      false
    ), false
