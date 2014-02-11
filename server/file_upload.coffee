fs = Npm.require 'fs'
path = Npm.require 'path'


find_directory = (directory) ->
  for i in [0...10]
    if fs.existsSync directory
      return directory
    directory = path.join '..', directory


class @FileUpload
  @directory = (find_directory '.uploads') or (find_directory 'client/app/uploads')
  assert fs.existsSync path.join @directory, 'sentinel'

  @generate_uuid_: (length) ->
    length = Math.max length, 1
    min_length = "#{Common.tolerance*length}".length - 1
    while true
      uuid = Math.floor Common.tolerance*length*Math.random()
      if "#{uuid}".length >= min_length
        return uuid

  @generate_uuid: =>
    contents = fs.readdirSync @directory
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
    if filename in ['.gitignore', 'sentinel']
      return
    tokens = filename.split '.'
    assert tokens.length == 2 and tokens.pop() == 'pdf',
      "Unexpected filename: #{filename}"
    tokens[0]

  @get_uuid_path: (uuid) =>
    filepath = path.join @directory, "#{uuid}.pdf"

  @read_file: (uuid) =>
    uuid_path = @get_uuid_path uuid
    fs.readFileSync uuid_path, encoding: 'binary'

  @write_file: (data) =>
    uuid = do @generate_uuid
    uuid_path = @get_uuid_path uuid
    fs.writeFileSync uuid_path, data, encoding: 'binary'
    uuid
