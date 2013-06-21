class Storage
  constructor: (@key="demo") ->
    @items = @_refresh()

  add: (item) ->
    id = @_guid()

    item.id = id
    @items[id] = item

    @save()
    id

  get: (guid) ->
    @items[guid]

  update: (item) ->
    throw "Item not found" unless @_itemExists(item.id)
    @items[item.id] = item
    @save()

  remove: (item) ->
    @removeId(item.id)

  removeId: (guid) ->
    throw "Item not found" unless @_itemExists(guid)
    delete @items[guid]

    @save()

  all: () ->
    BFG.values @items

  save: ->
    localStorage.setItem @key, @_toJSON(@items)
    @all()

  size: ->
    @all().length

  _itemExists: (guid) ->
    BFG.any BFG.keys(@items), (id) -> id == guid

  _refresh: () ->
    raw_data = localStorage[@key] || {}
    if BFG.isEmpty(raw_data) then raw_data else @_fromJSON(raw_data)

  clear: ->
    delete localStorage[@key]

  _toJSON: (items) ->
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