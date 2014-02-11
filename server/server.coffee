# Choose between different Upload backends here.
Upload = FileStore


Meteor.publish 'segments', ->
  do Segments.publish


write_file = (data) ->
  if data.length > Common.max_size
    throw new ValueError "File was too large (was #{data.length >> 20} MB)"
  Upload.write_file data


save_url = (url) ->
  result = HTTP.get url
  if result.statusCode != 200
    throw new ValueError "Unexpected status code: #{result.statusCode}"
  write_file result.content


Meteor.methods
  insert_segment: (start, end) ->
    Segments.insert_segment start, end

  clear_segments: ->
    Segments.remove {}

  read_file: (uuid) ->
    Upload.read_file uuid

  write_file: write_file

  save_url: save_url
