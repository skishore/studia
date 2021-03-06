class Sketchpad extends Canvas
  constructor: (@page, @elt) ->
    super @elt
    @page_context = @page[0].getContext '2d'

  clear_page: (viewport) =>
    toolbar_height = do @elt.parent().find('.toolbar').height
    target_height = window.innerHeight - toolbar_height - 22
    target_height = Math.min target_height, viewport.height
    @elt.parent().height target_height + toolbar_height
    @elt.parent().width 1.0*target_height*viewport.width/viewport.height
    @page_context.canvas.height = @context.canvas.height = viewport.height
    @page_context.canvas.width = @context.canvas.width = viewport.width
    do @set_line_style

  get_cursor: (e) =>
    offset = do @elt.offset
    x: 1.0*(e.pageX - offset.left)*@context.canvas.width/do @elt.width
    y: 1.0*(e.pageY - offset.top)*@context.canvas.height/do @elt.height

  mousedown: (e) =>
    @cursor = @get_cursor e

  mousemove: (e) =>
    [last_cursor, @cursor] = [@cursor, @get_cursor e]
    if (Mouse.mouse_down or Mouse.touch_enabled) and do ready
      [hash, page] = [Session.get('hash'), Session.get('page')]
      Meteor.call 'insert_segment', hash, page, last_cursor, @cursor
      @draw_segment last_cursor, @cursor

  render_page: (page) =>
    viewport = page.getViewport 1.0
    @clear_page viewport
    page.render canvasContext: @page_context, viewport: viewport


current_hash = null
pdf = null
sketchpad = null


ready = -> Session.get('page_loaded') and Session.get('sketchpad_loaded')


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


prev_page = ->
  if do ready and Session.get('page') > 1
    Session.set 'page', Session.get('page') - 1
    Session.set 'page_loaded', false


next_page = ->
  if do ready and Session.get('page') < pdf?.numPages
    Session.set 'page', Session.get('page') + 1
    Session.set 'page_loaded', false


$(window).keydown (e) ->
  if do ready
    if e.keyCode in [37, 38]
      do prev_page
    else if e.keyCode in [39, 40]
      do next_page


Template.sketchpad.events
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


Template.sketchpad.rendered = ->
  [page, elt] = [$(@find '.page'), $(@find '.sketchpad')]
  if page[0] != sketchpad?.page[0] or elt[0] != sketchpad?.elt[0]
    sketchpad = new Sketchpad page, elt
  Session.set 'sketchpad_loaded', true


Template.toolbar.events =
  'click .previous': (e) -> do prev_page

  'click .next': (e) -> do next_page

  'click .clear': (e) ->
    if do ready
      [hash, page] = [Session.get('hash'), Session.get('page')]
      Meteor.call 'clear_segments', hash, page


Template.toolbar.page_count = ->
  return "#{Session.get('page')}/#{pdf?.numPages}"


Template.toolbar.ready = ready


Meteor.startup ->
  Deps.autorun ->
    do refresh_page

  Deps.autorun ->
    [hash, page] = [Session.get('hash'), Session.get('page')]
    if hash and do ready
      Segments.get_page(hash, page).observe
        'added': (segment) ->
          sketchpad?.draw_line segment.start, segment.end
        'removed': (segments) ->
          do sketchpad?.clear
