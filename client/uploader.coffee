upload = (file) ->
  if not file
    console.log 'Choose a file to upload!'
  reader = new FileReader
  reader.onload = finish_upload
  reader.readAsBinaryString file


finish_upload = (e) ->
  result = e.target.result
  console.log typeof result
  console.log result.length
  window.r = result


Template.uploader.events
  'click .upload-button': (e) =>
    file_input = $(e.target).parent().find 'input[name="pdf"]'
    upload file_input[0]?.files[0]
