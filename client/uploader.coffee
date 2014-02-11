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
    @progress.slideDown delay

  update_progress: (progress, status) =>
    if progress != 1
      progress += 0.1*Math.random()
    @progress.find('.progress-bar').animate
      width: "#{Math.floor 100*progress}%", 400
    @progress.find('.status').text status

  stall_progress: (err, message) =>
    console.log err
    @progress.find('.progress-bar, .status').addClass 'error'
    @progress.find('.status').text message

  upload_file: (file) =>
    if not file
      return alert 'Choose a file to upload!'
    @show_progress file.name, 800
    @update_progress 0.25, 'Reading from local disk..'
    reader = new FileReader
    reader.onload = @finish_file_read
    reader.onerror = (err) =>
      @stall_progress err, 'There was an error reading the file.'
    reader.readAsBinaryString file

  finish_file_read: (e) =>
    result = e.target.result
    @update_progress 0.50, "Sending #{result.length} bytes to server..."
    Meteor.call 'write_file', result, @finish_file_send

  finish_file_send: (err, result) =>
    if err
      return @stall_progress err, 'There was a server-side upload error.'
    @update_progress 0.75, 'Validating PDF...'
    console.log result

  upload_url: (url) =>
    if not url
      return alert 'Enter a URL to upload!'
    @show_progress @parse_url(url), 400
    @update_progress 0.33, 'Streaming remote file...'


uploader = null


Template.uploader.events
  'change input[name="file"]': (e) ->
    uploader?.upload_file e.currentTarget.files[0]

  'click .remote-file': (e) =>
    url_input = uploader?.template?.find 'input[name="url"]'
    uploader?.upload_url do $(url_input).val


Template.uploader.rendered = ->
  uploader = new Uploader @
