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

  create: (text) ->
    todo = new Todo(text)
    @add(todo)

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

class TodoView extends Mustachio
  # ignore the template and the constructor for now.
  templateName: "item-template"

  constructor: (@model) -> super @model

  # this is where the view gets gets put into a page
  render: ->
    # render the html from the template
    html = super  # this is Mustachio magic. I'll show you this one day.

    # if we have an element already, we just need to update the html
    if @el
      @el.html(html)

    # otherwise, we need to create the view and bind our click events
    # (the checkbox and the delete button)
    else
      @el = $("<li>#{html}</li>")  # wrap it li for styling
      @el.on("click", ".toggle", @toggle)
      @el.on("click", ".destroy", @remove)

    @  # return the view, not the HTML.

  # now we need the two methods we call on the `click` action
  toggle: => @model.toggle()

  remove: =>
    @model.remove()  # tell the todo to remove itself
    @el.remove()  # remove the view from the page

class TodoApp
  constructor: (el) ->
    # Create the new collection and set the views we will be binding to (el)
    @collection = new Todos()
    @el = $(el)

    # Get a reference to all the UI elements we care about...
    @input = @el.find("#new-todo")  # the input
    @main = @el.find('#main')  # the wrapper around the todo list
    @list = @main.find("#todo-list")  # the todo list

    # bind the events we care about
    @input.on("keypress", @createOnEnter)

    # get all of the existing elements
    @collection.refresh()

  addOne: (todo) ->
    view = new TodoView(todo)

    @list.append(view.render().el)
    @main.show() unless @main.is(":visible")

  addAll: -> @addOne(todo) for todo in @collection.all()

  render: ->
    @list.html('')
    @addAll()
    if @collection.size() then @main.show() else @main.hide()

  createOnEnter: (evt) =>
    return unless evt.keyCode == 13  # only respond to the enter keypress
    return unless @input.val()  # only respond if the input is not empty (cannot create empty todos)

    # create the new Todo via the collection
    @collection.create @input.val()

    # clear the input
    @input.val ''

BFG.each [Todo, Todos, TodoApp], (klass) -> window[klass.name] = klass

