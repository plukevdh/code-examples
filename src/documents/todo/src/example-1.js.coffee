initEventHandler = (context) ->
  events = $({})
  events.publish = events.trigger

  context.on = (evt, callback) -> events.on(evt, callback)
  context.events = events

  events

class Todo
  constructor: (@title, @done=false, @id=null) ->
    initEventHandler(@)

  toggle: ->
    @done = !@done
    @events.publish("change", @)

  toJSON: ->
    {title: @title, done: @done, id: @id}

Todo.create = ({title: title, done: done, id: id}) ->
  new Todo(title, done, id)

class Todos
  constructor: ->
    @store = new Storage("todo")
    @items = []

  all: ->
    @items

  size: ->
    @items.length

  clear: ->
    @store.clear()
    @items = []
    @

  add: (todo) ->
    @_bindItem(todo)

    todo.id = @store.add(todo.toJSON())
    @items.push todo
    todo

  remove: (todo) ->
    @store.remove(todo)
    @refresh()

  refresh: ->
    raw_items = @store.all()
    @items = (@_createFromRaw(item) for item in raw_items)
    @

  _createFromRaw: (item) ->
    todo = Todo.create(item)
    @_bindItem(todo)
    todo

  update: (evtOrTodo, todo) =>
    todo ?= evtOrTodo
    @store.update(todo.toJSON())

  _bindItem: (todo) ->
    todo.on("change", @update, todo)

BFG.each [Todo, Todos], (klass) -> window[klass.name] = klass

$ ->
  window.collection = new Todos().clear()
  collection.add(new Todo("test"))
  collection.add(new Todo("another"))