class @FileStore extends Collection
  @set_schema
    name: 'file_store'
    durable: Common.durable
    fields: [
      'uuid',
      'data',
    ]
    indices: [
      {columns: 'uuid', options: unique: true},
    ]

  @generate_uuid_: (length) ->
    length = Math.max length, 1
    min_length = "#{Common.tolerance*length}".length - 1
    while true
      uuid = Math.floor Common.tolerance*length*Math.random()
      if "#{uuid}".length >= min_length
        return uuid

  @generate_uuid: =>
    length = do @find().count
    while true
      uuid = @generate_uuid_ length
      if not @findOne(uuid: uuid)
        return uuid

  @read_file: (uuid) =>
    check uuid, Number
    result = @findOne uuid: uuid
    if not result
      throw new ValueError "Missing file: #{uuid}"
    result.data

  @write_file: (data) =>
    check data, String
    uuid = do @generate_uuid
    @insert {uuid: uuid, data: data}
    uuid
