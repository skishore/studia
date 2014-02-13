class Uploader
  constructor: (@template) ->
    @progress = $ @template.find '.upload-progress-template'

  parse_url: (url) ->
    url.replace(/[\?\#].*$/, '').replace(/.*\//, '')

  show_progress: (path, delay) ->
    do @progress.hide
    @progress.find('.progress-bar, .status').removeClass 'error'
    @progress.find('.header').text "Uploading #{path}..."
    @progress.find('.progress-bar').width '0%'
    @progress.find('.status').text 'Starting upload...'
    @progress.find('.error.details').text ''
    @progress.slideDown delay

  update_progress: (progress, status) =>
    @progress.find('.progress-bar').animate
      width: "#{Math.floor 100*progress}%", 400
    @progress.find('.status').text status

  stall_progress: (message, err, show_error_details) =>
    @progress.find('.progress-bar, .status').addClass 'error'
    @progress.find('.status').text message
    if err
      console.log err
      if show_error_details
        @progress.find('.error.details').text err.error

  upload_file: (file) =>
    if not file
      return alert 'Choose a file to upload!'
    @show_progress file.name, 800
    @update_progress 0.25, 'Reading from local disk..'
    if file.type != Common.MIME_type
      return @stall_progress "Got #{file.type} (expected #{Common.MIME_type})"
    reader = new FileReader
    reader.onload = @finish_file_read
    reader.onerror = (err) =>
      @stall_progress 'There was an error reading the file.', err, false
    reader.readAsDataURL file

  finish_file_read: (e) =>
    result = e.target.result
    if result.length > Common.max_size
      return @stall_progress \
        "File was too large (maximum size: #{Common.max_size >> 20} MB)"
    @update_progress 0.50, "Sending #{result.length} bytes to server..."
    Meteor.call 'save_file', result, (err, result) =>
      @finish_upload err, result, 0.75

  upload_url: (url) =>
    if not url
      return alert 'Enter a URL to upload!'
    @show_progress @parse_url(url), 400
    @update_progress 0.33, 'Streaming remote file to server...'
    Meteor.call 'save_url', url, (err, result) =>
      @finish_upload err, result, 0.67

  finish_upload: (err, result, progress) =>
    if err
      return @stall_progress 'There was a server-side upload error:', err, true
    @update_progress progress, 'Validating uploaded PDF...'
    uuid = result
    Meteor.call 'get_file', uuid, (err, result) =>
      @validate_pdf err, result, uuid

  validate_pdf: (err, result, uuid) =>
    if err
      return @stall_progress 'There was a server-side retrieval error:', err, true
    console.log result.length
    PDFJS.getDocument('asdf').then((pdf) =>
      console.log 'here'
      window.pdf = pdf
      link = "#{window.location.origin}/#{uuid}"
      @update_progress 1.0, "Done! Got shareable link: #{link}"
    ).catch((err) =>
      console.log err
      @stall_progress 'The PDF was malformed!'
    )


uploader = null


Template.uploader.events
  'change input[name="file"]': (e) ->
    uploader?.upload_file e.currentTarget.files[0]

  'click .remote-file': (e) =>
    url_input = uploader?.template?.find 'input[name="url"]'
    uploader?.upload_url do $(url_input).val


Template.uploader.rendered = ->
  uploader = new Uploader @
