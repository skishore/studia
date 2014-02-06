class Sketchpad
  constructor: (@elt) ->
    container = elt.parent()
    elt.width container.width()
    elt.height container.height()
    @context = elt[0].getContext '2d'
    @offset = @elt.offset()
    @reset_context true

  reset_context: (force) =>
    if @changed or force
      # Set the context's internal width and height based on the canvas.
      @context.canvas.height = @elt.height()
      @context.canvas.width = @elt.width()
      # Set the line style. For some reason, modifying @context.canvas after
      # making these changes clears them... wtf.js
      @context.lineCap = 'round'
      @context.lineJoin = 'round'
      @context.lineWidth = 4
      @context.strokeStyle = 'red'
      @changed = false

  set_cursor: (e) =>
    @cursor = {x: e.pageX - @offset.left, y: e.pageY - @offset.top}

  draw_segment: (start, end) =>
    @changed = true
    continuation = (start.x == @last_end?.x and start.y == @last_end?.y)
    if not continuation
      do @context.beginPath
    @context.moveTo start.x, start.y
    @context.lineTo end.x, end.y
    do @context.stroke
    @last_end = end

  mousedown: (e) =>
    @set_cursor e
    #if not mouse_down
    #  do @context.beginPath
    #  @context.moveTo @cursor.x, @cursor.y

  mousemove: (e) =>
    last_cursor = @cursor
    @set_cursor e
    if mouse_down
      Meteor.call 'insert_segment', last_cursor, @cursor
      #@context.lineTo @cursor.x, @cursor.y
      #do @context.stroke


Session.set 'sketchpad_loaded', false
sketchpad = null


Template.sketchpad.events
  'mousedown .sketchpad': (e) ->
    sketchpad?.mousedown e

  'mousemove .sketchpad': (e) ->
    sketchpad?.mousemove e


Template.sketchpad.rendered = ->
  sketchpad = new Sketchpad $ @find '.sketchpad'
  Session.set 'sketchpad_loaded', true


Meteor.startup ->
  Meteor.subscribe 'segments'

  Deps.autorun ->
    if Session.get 'sketchpad_loaded'
      Segments.find().observe
        'added': (segment) ->
          sketchpad?.draw_segment segment.start, segment.end
        'removed': (old_segment) ->
          do sketchpad?.reset_context

  $('.clear-button').click -> Meteor.call 'clear_segments'
