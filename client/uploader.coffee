class Uploader
  constructor: (@template) ->
    @progress = $ @template.find '.upload-progress-template'

  parse_url: (url) ->
    url.replace(/[\?\#].*$/, '').replace(/.*\//, '')

  show_progress: (path, delay, status) ->
    do @progress.hide
    @progress.find('.header').text "Uploading #{path}..."
    @progress.find('.progress-bar').width '0%'
    @progress.find('.status').text 'Starting upload...'
    @progress.slideDown delay
    @update_progress 0.25, status

  update_progress: (progress, status) =>
    if progress != 1
      progress += 0.1*Math.random()
    @progress.find('.progress-bar').animate
      width: "#{parseInt 100*progress}%", 400
    @progress.find('.status').text status

  upload_file: (file) =>
    if not file
      return alert 'Choose a file to upload!'
    @show_progress file.name, 800, 'Reading from local disk..'
    reader = new FileReader
    reader.onload = @finish_file_upload
    reader.readAsBinaryString file

  finish_file_upload: (e) =>
    result = e.target.result
    @update_progress 0.50, "Sending #{result.length} bytes to server..."

  upload_url: (url) =>
    if not url
      return alert 'Enter a URL to upload!'
    @show_progress @parse_url(url), 400, 'Streaming remote file...'


uploader = null


Template.uploader.events
  'change input[name="file"]': (e) ->
    uploader?.upload_file e.currentTarget.files[0]

  'click .remote-file': (e) =>
    url_input = uploader?.template?.find 'input[name="url"]'
    uploader?.upload_url do $(url_input).val


Template.uploader.rendered = ->
  uploader = new Uploader @
