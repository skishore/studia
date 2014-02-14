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
  @durable = true #not dev

  # The maximum allowed size, in bytes, of an uploaded file.
  @max_size = 0x1000000
  # The reciprocal of the fraction of possible UUIDs that are valid.
  @tolerance = 1000000

  # The only file type that we currently support in this app.
  @MIME_type = 'application/pdf'

  # Function that takes a base64-encoded DataURI string and returns an
  # ArrayBuffer containing its decoded bytes.
  @base64_decode: (dataURI) ->
    bytes = atob dataURI.split(',')[1]
    buffer = new ArrayBuffer bytes.length
    int_array = new Uint8Array buffer
    for i in [0...bytes.length]
      int_array[i] = bytes.charCodeAt i
    buffer
