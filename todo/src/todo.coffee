class Pubsub
Pubsub = $({})
Pubsub.publish = Pubsub.trigger;

class Todo
  constructor: (@title, @done=false) ->
    @events = $({})

  toJSON: ->
    {title: @title, done: @done}

  toggle: =>
    @done = !@done
    @events.trigger("done")

  on: (evt, callback) ->
    @events.on(evt, callback)

Todo.create = ({title: title, done: done}) ->
  new Todo(title, done)

class Todos
  constructor: () ->
    @store = new Storage("todo")
    @refresh()

  save: =>
    @store.save @toRaw()
    @

  create: (todo_text) ->
    @add new Todo(todo_text)

  add: (todo) ->
    @items.push todo
    @save()
    Pubsub.publish("add", todo)

  refresh: () ->
    raw_items = @store.all()
    @items = (@createAndBind(item) for item in raw_items)
    @items = [@items] unless $.isArray @items
    @length = @items.length

    Pubsub.publish("all")

  createAndBind: (todo) ->
    todo = Todo.create(todo)
    todo.on("done", @save)
    todo

  toRaw: () ->
    attrs = []
    attrs.push(item.toJSON()) for item in @items
    attrs

class TodoApp
  constructor: (el) ->
    @collection = new Todos()
    @el = $(el)

    @input = @el.find("#new-todo")
    @allCheckbox = @el.find("#toggle-all")[0]
    @main = @el.find('#main')

    Pubsub.on("all", @render)
    Pubsub.on("add", @addOne)

    @input.on("keypress", @createOnEnter)

    @collection.refresh()

  render: =>
    @addAll()
    if @collection.length then @main.show() else @main.hide()

  addAll: ->
    @addOne(null, item) for item in @collection.items

  addOne: (evt, todo) =>
    view = new TodoItemView(todo)
    @el.find("#todo-list").append(view.render().el)

  createOnEnter: (evt) =>
    return unless evt.keyCode == 13
    return unless @input.val()

    @collection.create @input.val()
    @input.val ''

class TodoItemView extends Mustachio
  templateName: "item-template"

  constructor: (@model) ->
    super @model

    @model.on("done", @render)

  render: =>
    if !@el
      @el = $(super)
      @el.find(".toggle").on("click", @toggle)
      @input = @el.find('.edit')

    @el.toggleClass("done", @model.done)
    @

  toggle: =>
    @model.toggle()

$ ->
  window.app = new TodoApp("#todoapp")