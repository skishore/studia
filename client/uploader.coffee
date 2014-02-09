upload = (file) ->
  if not file
    return alert 'Choose a file to upload!'
  reader = new FileReader
  reader.onload = finish_upload
  reader.readAsBinaryString file


finish_upload = (e) ->
  result = e.target.result
  alert 'Uploaded ' + result.length + ' byte PDF.'


upload_url = (url) =>
  if not url
    return alert 'Enter a URL to upload!'
  console.log url


Template.uploader.events
  'change input[name="file"]': (e) ->
    upload e.currentTarget.files[0]

  'click .remote-file': (e) =>
    url_input = $(e.currentTarget).parent().find 'input[name="url"]'
    upload_url do $(url_input).val
