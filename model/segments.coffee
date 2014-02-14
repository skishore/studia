class @Segments extends Collection
  @set_schema
    name: 'segments'
    durable: Common.durable
    fields: [
      'hash',
      'page',
      'start',
      'end',
      'mts',
    ]
    indices: [
      {columns: ['hash', 'page', 'mts']},
    ]


  @publish: (hash) =>
    @find {hash: hash}

  @get_page: (hash, page) =>
    @find hash: hash, page: page

  @insert_segment: (hash, page, start, end) =>
    check hash, String
    check page, Number
    check start.y, Number
    check end.x, Number
    check end.y, Number
    @insert
      hash: hash
      page: page
      start: start
      end: end
      mts: do Date.now
