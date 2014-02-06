class @Segments extends Collection
  @set_schema
    name: 'segments'
    durable: false
    fields: [
      'start',
      'end',
    ]

  @publish: =>
    @find {}

  @insert_segment: (start, end) =>
    check start.x, Number
    check start.y, Number
    check end.x, Number
    check end.y, Number
    @insert {start: start, end: end}
