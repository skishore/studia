Meteor.publish 'segments', ->
  do Segments.publish

Meteor.methods
  'insert_segment': (start, end) ->
    Segments.insert_segment start, end
