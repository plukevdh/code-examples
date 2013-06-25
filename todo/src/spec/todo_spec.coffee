# Things to note:
# - handles no persistence. simply signals actions
#

describe "Todo", ->
  todo = null

  beforeEach ->
    todo = new Todo("test")

  it "can toggle todo state", ->
    expect(todo.done).toBeFalsy()
    todo.toggle()
    expect(todo.done).toBeTruthy()
    todo.toggle()
    expect(todo.done).toBeFalsy()

  it "can generate object representation (for JSON)", ->
    expect(todo.toJSON()).toEqual({title: "test", done: false, id: null})

  it "triggers a change event on done toggle", ->
    spyOn(todo.events, "publish")

    todo.setDone()
    todo.setNotDone()
    expect(todo.events.publish).toHaveBeenCalledWith("change", todo)
    expect(todo.events.publish.callCount).toEqual(2)

  it "triggers a remove event on remove toggle", ->
    spyOn(todo.events, "publish")
    todo.remove()

    expect(todo.events.publish).toHaveBeenCalledWith("remove", todo)


# Things to note:
# - doesn't care about the internals of the Todo. just handles the persistence and aggregation
# - is really only testing where things come in and go out (boundaries)

describe "Todos", ->
  todos = null

  beforeEach ->
    todos = new Todos()

  afterEach ->
    todos.clear()

  it "can create and persist a record", ->
    todo = todos.create("item")

    expect(todos.size()).toEqual(1)
    expect(todos.all()).toEqual([todo])
    expect(todo.id).not.toBeNull()

  it "can add a record object", ->
    todo = new Todo("item")
    todo = todos.add(todo)

    expect(todos.size()).toEqual(1)
    expect(todos.all()).toEqual([todo])
    expect(todo.id).not.toBeNull()

  it "saves records when internals are updated change", ->
    spyOn(todos, "save")

    todo = new Todo("item")
    todos.add(todo)
    todo.toggle()

    expect(todos.save).toHaveBeenCalled()

  it "can get all records", ->
    todo1 = todos.create("item")
    todo2 = todos.create("item 2")

    expect(todos.all()).toEqual [todo1, todo2]

  it "can remove a record", ->
    todo1 = todos.create("item")
    todo2 = todos.create("item 2")

    todos.remove(todo1)

    expect(todos.all()[0]).toEqual todo2.toJSON()

  it "removes a record on record deletion", ->
    todo = todos.create("item 1")

    expect(todos.size()).toEqual(1)
    todo.remove()
    expect(todos.size()).toEqual(0)

  it "refresh triggers update", ->
    spyOn(todos.events, "publish")

    todos.refresh()
    expect(todos.events.publish).toHaveBeenCalledWith("all")


# Other things to note:
# - we never test the constructors. needing tests for custructors mean they're doing too much