class @Upload
  # The fraction of available UUIDs that can be taken.
  @tolerance = 1000000

  @directory = '../../../../../.uploads'
  @fs = Npm.require 'fs'
  @path = Npm.require 'path'

  @generate_uuid_: (length) =>
    length = Math.max length, 1
    min_length = "#{@tolerance*length}".length - 1
    while true
      uuid = Math.floor @tolerance*length*Math.random()
      if "#{uuid}".length >= min_length
        return uuid

  @generate_uuid: =>
    contents = @fs.readdirSync @directory
    uuid_set = {}
    for filename in contents
      uuid = @get_uuid_for_filename filename
      if uuid
        uuid_set[uuid] = true
    while true
      uuid = @generate_uuid_ contents.length
      if uuid not of uuid_set
        return uuid

  @get_uuid_for_filename: (filename) =>
    if filename[0] == '.'
      return
    tokens = filename.split '.'
    assert tokens.length == 2 and tokens.pop() == 'pdf',
      "Unexpected filename: #{filename}"
    tokens[0]

  @get_path_for_uuid: (uuid) =>
    @path.join @directory, "#{uuid}.pdf"


console.log do Upload.generate_uuid
