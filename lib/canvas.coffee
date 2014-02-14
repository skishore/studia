class @Canvas
  constructor: (@elt) ->
    @context = elt[0].getContext '2d'

  set_line_style: =>
    @context.lineCap = 'round'
    @context.lineJoin = 'round'
    @context.lineWidth = 2
    @context.strokeStyle = 'red'

  clear: =>
    if @dirty
      @context.clearRect 0, 0, @context.canvas.width, @context.canvas.height
      @dirty = false

  draw_line: (start, end) =>
    @dirty = true
    do @context.beginPath
    @context.moveTo start.x, start.y
    @context.lineTo end.x, end.y
    do @context.stroke
    do @context.closePath
