# Choose between different Upload backends here.
Upload = FileUpload


Meteor.publish 'segments', ->
  do Segments.publish


Meteor.methods
  'insert_segment': (start, end) ->
    Segments.insert_segment start, end

  'clear_segments': ->
    Segments.remove {}

  'read_file': (uuid) ->
    Upload.read_file uuid

  'write_file': (contents) ->
    Upload.write_file contents
