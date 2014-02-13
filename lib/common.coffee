# Various core configuration variables accessible to all modules.
# Among these variable is a 'dev' boolean that is true on my local machine
# but not in Meteor's hosting environment. Sorry about the way this boolean
# is implemented... -skishore


if Meteor.isServer
  dev = process.env.USER == 'skishore'
else
  dev = window.location.hostname == 'localhost'


class @Common
  @dev = dev
  @durable = not dev

  # The maximum allowed size, in bytes, of an uploaded file.
  @max_size = 0x1000000
  # The reciprocal of the fraction of possible UUIDs that are valid.
  @tolerance = 1000000

  @MIME_type = 'application/pdf'
