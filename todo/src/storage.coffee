class Storage
  constructor: (@key="demo") ->

  get: (index) ->
    items = @all()
    items[index]

  remove: (index) ->
    items = @all()
    items.splice index, 1
    @save(items)

  all: () ->
    raw_data = localStorage[@key]
    if raw_data then @_fromJSON(raw_data) else []

  save: (items) ->
    localStorage.setItem @key, @_toJSON(items)
    items

  _toJSON: (items) ->
    JSON.stringify items

  _fromJSON: (json) ->
    JSON.parse json

window.Storage = Storage