initEventHandler = (context) ->
  events = $({})
  events.publish = events.trigger

  context.on = (evt, callback) -> events.on(evt, callback)
  context.events = events

  events

class Todo
  constructor: (@title, @done=false, @id=null) ->
    initEventHandler(@)

  toJSON: -> {title: @title, done: @done, id: @id}

  toggle: => if @done then @setNotDone() else @setDone()

  setDone: ->
    @done = true
    @change()

  setNotDone: ->
    @done = false
    @change()

  remove: -> @events.publish "remove", @

  change: -> @events.publish "change", @

Todo.create = ({title: title, done: done, id: id}) ->
  new Todo(title, done, id)

class Todos
  constructor: ->
    @store = new Storage("todo")
    @items = []

    initEventHandler(@)

  update: (evtOrTodo, todo) =>
    todo ?= evtOrTodo
    @store.update(todo.toJSON())

  create: (todo_text) ->
    todo = new Todo(todo_text)
    @add(todo)

  size: -> @items.length

  add: (todo) ->
    @_bindItem(todo)

    todo.id = @store.add(todo.toJSON())
    @items.push(todo)

    @events.publish("add", todo)
    todo

  all: -> @items

  clear: ->
    @store.clear()
    @events.publish("all")
    @

  remove: (evtOrTodo, todo) =>
    todo ?= evtOrTodo
    @items = @store.remove todo

  refresh: () ->
    raw_items = @store.all()
    @items = (@_createFromRaw(item) for item in raw_items)

    @events.publish("all")
    @

  _createFromRaw: (raw_item) ->
    todo = Todo.create(raw_item)
    @_bindItem(todo)
    todo

  _bindItem: (todo) ->
    todo.on("change", @update)
    todo.on("remove", @remove)

# Things to note:
# - TodoView updates the model on action, waits for change signal from model to update.
#   This ensures our view stays in sync with the model

class TodoView extends Mustachio
  templateName: "item-template"

  constructor: (@todo) ->
    super @todo

    @todo.on("change", @render)

  render: =>
    html = super

    if @el
      @el.html(html)
    else
      @el = $("<li>#{html}</li>")
      @el.on("click", ".toggle", @toggle)
      @el.on("click", ".destroy", @remove)

    @el.toggleClass("done", @todo.done)
    @

  toggle: => @todo.toggle()

  remove: =>
    @todo.remove()
    @el.remove()

# Things to note:
# - The app manages all interaction. With the main elements
# - The sub-views (TodoView) manages anything related to the controls contained within
# - Actions move inward, never out. Subviews, never affect the parent,
#   but parent may affect the sub.

class TodoApp
  constructor: (el) ->
    @collection = new Todos()
    @el = $(el)

    @input = @el.find("#new-todo")
    @allCheckbox = @el.find("#toggle-all").first()
    @main = @el.find('#main')
    @list = @main.find("#todo-list")

    @collection.on("all", @render)
    @collection.on("add", @addOne)

    @input.on("keypress", @createOnEnter)
    @allCheckbox.on("click", @toggleAll)

    @collection.refresh()

  render: =>
    @list.html('')
    @addAll()
    if @collection.size() then @main.show() else @main.hide()

  addAll: ->
    @addOne(null, item) for item in @collection.all()

  addOne: (evt, todo) =>
    view = new TodoView(todo)
    @list.append(view.render().el)
    @main.show() unless @main.is(':visible')

  createOnEnter: (evt) =>
    return unless evt.keyCode == 13
    return unless @input.val()

    @collection.create @input.val()
    @input.val ''

  toggleAll: (evt) =>
    target = $(evt.currentTarget)

    (if target.is(':checked') then todo.setDone() else todo.setNotDone()) for todo in @collection.all()

BFG.each [Todo, Todos, TodoApp], (klass) -> window[klass.name] = klass
