$(window).bind 'hashchange', (e) ->
  hash = window.location.hash.slice 1
  if hash != Session.get 'hash'
    Session.set 'hash', hash
    # pdf.js is 1-indexed =/
    Session.set 'page', 1
    Session.set 'sketchpad_loaded', false


$(window).trigger 'hashchange'


Template.main.hash = ->
  Session.get 'hash'


Meteor.startup ->
  do Mouse.initialize

  Deps.autorun ->
    hash = Session.get 'hash'
    if hash
      Meteor.subscribe 'segments', hash
