class @Canvas
  constructor: (@elt) ->
    @context = elt[0].getContext '2d'
    @clear true

  clear: (force) =>
    if @dirty or force
      # Set the context's internal width and height based on the canvas.
      @context.canvas.height = do @elt.height
      @context.canvas.width = do @elt.width
      # Set the line style. Modifying @context.canvas after making these
      # changes will undo them.
      @context.lineCap = 'round'
      @context.lineJoin = 'round'
      @context.lineWidth = 2
      @context.strokeStyle = 'red'
      @dirty = false

  draw_line: (start, end) =>
    @dirty = true
    do @context.beginPath
    @context.moveTo start.x, start.y
    @context.lineTo end.x, end.y
    do @context.stroke
    do @context.closePath
