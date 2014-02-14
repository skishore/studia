class Sketchpad extends Canvas
  constructor: (@page, @elt) ->
    super @elt
    @page_context = @page[0].getContext '2d'

  clear_page: =>
    @page_context.canvas.height = do @page.height
    @page_context.canvas.width = do @page.width

  get_cursor: (e) =>
    offset = do @elt.offset
    {x: e.pageX - offset.left, y: e.pageY - offset.top}

  mousedown: (e) =>
    @cursor = @get_cursor e

  mousemove: (e) =>
    [last_cursor, @cursor] = [@cursor, @get_cursor e]
    if (Mouse.mouse_down or Mouse.touch_enabled) and Session.get 'page_loaded'
      [hash, page] = [Session.get('hash'), Session.get('page')]
      Meteor.call 'insert_segment', hash, page, last_cursor, @cursor

  render_page: (page) =>
    viewport = page.getViewport 1.0
    @elt.parent().height viewport.height
    @elt.parent().width viewport.width
    @clear true
    do @clear_page
    page.render canvasContext: @page_context, viewport: viewport


current_hash = null
pdf = null
sketchpad = null


Template.sketchpad.events
  'click .clear-link': (e) ->
    Meteor.call 'clear_segments'

  'mousedown .sketchpad': (e) ->
    if not Mouse.touch_enabled
      sketchpad?.mousedown e

  'mousemove .sketchpad': (e) ->
    if not Mouse.touch_enabled
      sketchpad?.mousemove e

  'touchstart .sketchpad': (e) ->
    if Mouse.touch_enabled
      sketchpad?.mousedown e

  'touchmove .sketchpad': (e) ->
    if Mouse.touch_enabled
      sketchpad?.mousemove e


refresh_page = ->
  [hash, page] = [Session.get('hash'), Session.get('page')]
  if not hash
    return
  if hash == current_hash
    pdf.getPage(page).then (result) ->
      if hash == Session.get('hash') and page == Session.get('page')
        if Session.get 'sketchpad_loaded'
          sketchpad.render_page result
          Session.set 'page_loaded', true
  else
    Meteor.call 'get_file', hash, (err, result) ->
      buffer = Common.base64_decode result
      PDFJS.getDocument(buffer).then (result) ->
        if hash == Session.get 'hash'
          [current_hash, pdf] = [hash, result]
          do refresh_page


Template.sketchpad.rendered = ->
  sketchpad = new Sketchpad ($ @find '.page'), ($ @find '.sketchpad')
  Session.set 'sketchpad_loaded', true


Meteor.startup ->
  Deps.autorun ->
    do refresh_page

  Deps.autorun ->
    [hash, page] = [Session.get('hash'), Session.get('page')]
    if hash and Session.get('page_loaded') and Session.get('sketchpad_loaded')
      Segments.get_page(hash, page).observe
        'added': (segment) ->
          sketchpad?.draw_line segment.start, segment.end
        'removed': (old_segment) ->
          do sketchpad?.clear
