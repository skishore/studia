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
      Meteor.call 'insert_segment', last_cursor, @cursor


Session.set 'sketchpad_loaded', false
sketchpad = null


Template.sketchpad.events
  'touchstart .sketchpad': (e) ->
    if Mouse.touch_enabled
      sketchpad?.mousedown e

  'touchmove .sketchpad': (e) ->
    if Mouse.touch_enabled
      sketchpad?.mousemove e

  'mousedown .sketchpad': (e) ->
    if not Mouse.touch_enabled
      sketchpad?.mousedown e

  'mousemove .sketchpad': (e) ->
    if not Mouse.touch_enabled
      sketchpad?.mousemove e


Template.sketchpad.rendered = ->
  sketchpad = new Sketchpad $ @find '.sketchpad'
  Session.set 'sketchpad_loaded', true


Meteor.startup ->
  do Mouse.initialize

  Meteor.subscribe 'segments'

  Deps.autorun ->
    if Session.get 'sketchpad_loaded'
      Segments.find().observe
        'added': (segment) ->
          sketchpad?.draw_line segment.start, segment.end
        'removed': (old_segment) ->
          do sketchpad?.clear

  $('.clear-button')[0].onclick = ->
    Meteor.call 'clear_segments'
    return
