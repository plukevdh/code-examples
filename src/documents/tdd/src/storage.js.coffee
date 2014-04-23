# Storage.coffee is a simple wrapper and normalizer for storing objects
# in HTML5's localStorage. This could easily be extended to be a polyfill for
# localStorage and switch off to cookies if needed. For now, we only care about
# using localStorage.
#
# Dependencies:
# - underscore.js

class Storage
  constructor: (@key="demo") ->
    @items = @_refresh()

  # Allows us to persist an item via an object.
  # Returns the ID of the new object.
  #
  add: (item) ->
    id = @_guid()

    item.id = id
    @items[id] = item

    @save()
    id

  # Find an item by its ID
  # Returns the attributes of an object
  #
  get: (guid) ->
    @items[guid]

  # Update an item
  # Raises error if item has not be persisted before now
  #
  update: (item) ->
    throw "Item not found" unless @_itemExists(item.id)
    @items[item.id] = item
    @save()


  # Removes the passed item from storage
  #
  remove: (item) ->
    @removeId(item.id)

  # Remove an item by ID
  #
  removeId: (guid) ->
    throw "Item not found" unless @_itemExists(guid)
    delete @items[guid]

    @save()

  # Returns all the items in storage.
  #
  all: () ->
    _.values @items

  # Saves the in-memory collection of items to localStorage
  #
  save: ->
    localStorage.setItem @key, @_toJSON(@items)
    @all()

  # Returns an integer representing the number of items
  # we are storing
  #
  size: ->
    @all().length

  # Clears out all of the itmes in localStorage
  #
  clear: ->
    delete localStorage[@key]
    @items = {}

  # Private methods...
  #

  # Returns true if the item exists in the collection
  #
  _itemExists: (guid) ->
    _.any _.keys(@items), (id) -> id == guid

  # Refreshes the in-memory collection from localstorage
  #
  _refresh: () ->
    raw_data = localStorage[@key] || {}
    if _.isEmpty(raw_data) then raw_data else @_fromJSON(raw_data)

  # JSON helpers...
  #
  _toJSON: (items) ->
    JSON.stringify items

  _fromJSON: (json) ->
    JSON.parse json

  _guid: _.uniqueId

window.Storage = Storage