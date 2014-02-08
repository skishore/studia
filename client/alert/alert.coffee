ALERT_CLASS = 'custom-alert'

APPEAR_TIME = 200
HOLD_TIME = 1600
VANISH_TIME = 200


get_alert = ->
  if not $('.' + ALERT_CLASS).length
    result = $('<span>').addClass ALERT_CLASS
    container = $('<div>').addClass(ALERT_CLASS + '-container')
    $('body').prepend container.append result
  $('.' + ALERT_CLASS)


@alert = (message) ->
  elt = do get_alert
  elt.css('opacity', 0).stop(true).text(message)
  elt.animate({opacity: 1}, {duration: APPEAR_TIME})
     .animate({opacity: 1}, {duration: HOLD_TIME})
     .animate({opacity: 0}, {duration: VANISH_TIME})
