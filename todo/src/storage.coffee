class Storage
  constructor: (@key="demo") ->
    @items = @_refresh()

  add: (item) ->
    item.id = @_guid()
    @items[item.id] = item

    @save()
    item

  get: (guid) ->
    @items[guid]

  remove: (item) ->
    @removeId(item.id)

  removeId: (guid) ->
    throw "Item not found" unless BFG.any BFG.keys(@items), (id) -> id == guid
    delete @items[guid]

    @save()

  all: () ->
    BFG.values @items

  save: (items=@items) ->
    localStorage.setItem @key, @_toJSON(items)
    @all()

  size: ->
    @all().length

  _refresh: () ->
    raw_data = localStorage[@key] || {}
    if BFG.isEmpty(raw_data) then raw_data else @_fromJSON(raw_data)

  clear: ->
    delete localStorage[@key]

  _toJSON: (items=@items) ->
    JSON.stringify items

  _fromJSON: (json) ->
    JSON.parse json

  # Generate four random hex digits.
  _S4: ->
   (((1+Math.random())*0x10000)|0).toString(16).substring(1)

  # Generate a pseudo-GUID by concatenating random hexadecimal.
  _guid: ->
    (@_S4()+@_S4()+"-"+@_S4()+"-"+@_S4()+"-"+@_S4()+"-"+@_S4()+@_S4()+@_S4())

window.Storage = Storage