class Sketchpad extends Canvas
  constructor: (@elt) ->
    super @elt
    @offset = @elt.offset()

  get_cursor: (e) =>
    {x: e.pageX - @offset.left, y: e.pageY - @offset.top}

  mousedown: (e) =>
    @cursor = @get_cursor e

  mousemove: (e) =>
    [last_cursor, @cursor] = [@cursor, @get_cursor e]
    if Mouse.mouse_down or Mouse.touch_enabled
      [hash, page] = [Session.get('hash'), Session.get('page')]
      Meteor.call 'insert_segment', hash, page, last_cursor, @cursor


Session.set 'sketchpad_loaded', false
sketchpad = null


Template.sketchpad.events
  'click .clear-link': (e) ->
    Meteor.call 'clear_segments'

  'mousedown canvas': (e) ->
    if not Mouse.touch_enabled
      sketchpad?.mousedown e

  'mousemove canvas': (e) ->
    if not Mouse.touch_enabled
      sketchpad?.mousemove e

  'touchstart canvas': (e) ->
    if Mouse.touch_enabled
      sketchpad?.mousedown e

  'touchmove canvas': (e) ->
    if Mouse.touch_enabled
      sketchpad?.mousemove e


Template.sketchpad.rendered = ->
  sketchpad = new Sketchpad $ @find 'canvas'
  Session.set 'sketchpad_loaded', true


Meteor.startup ->
  Deps.autorun ->
    [hash, page] = [Session.get('hash'), Session.get('page')]
    if hash and Session.get 'sketchpad_loaded'
      Segments.get_page(hash, page).observe
        'added': (segment) ->
          sketchpad?.draw_line segment.start, segment.end
        'removed': (old_segment) ->
          do sketchpad?.clear
