upload = (button, file) ->
  if not file
    console.log 'Choose a file to upload!'
  do button.disable
  reader = new FileReader
  reader.onload = (e) -> finish_upload button, e
  reader.readAsBinaryString file


finish_upload = (button, e) ->
  result = e.target.result
  alert 'Uploading ' + result.length + ' byte PDF..'
  do button.enable


Template.uploader.events
  'click .upload-button': (e) =>
    file_input = $(e.target).parent().find 'input[name="pdf"]'
    upload $(e.target), file_input[0]?.files[0]
