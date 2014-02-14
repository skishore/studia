Meteor.publish 'segments', (hash) ->
  Segments.publish hash


Meteor.methods
  insert_segment: (hash, page, start, end) ->
    Segments.insert_segment hash, page, start, end

  clear_segments: ->
    Segments.remove {}

  get_file: (uuid) ->
    FileStore.get_file uuid

  save_file: (data) ->
    FileStore.save_file data

  save_url: (url) ->
    FileStore.save_url url


reset = ->
  MongoFileStore.remove {}
  Segments.remove {}
