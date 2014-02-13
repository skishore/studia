Meteor.publish 'segments', ->
  do Segments.publish


Meteor.methods
  insert_segment: (start, end) ->
    Segments.insert_segment start, end

  clear_segments: ->
    Segments.remove {}

  get_file: FileStore.get_file

  save_file: FileStore.save_file

  save_url: FileStore.save_url
