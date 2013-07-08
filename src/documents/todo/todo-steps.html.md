---
title: Todo App Tutorial
layout: 'default'
---

# The Todo App: Requirements to Product

The goal of this exercise is to think more modularly about how we break down requirements at a high level into individual components or modules that can make up the whole. There are mixtures of experience levels this is meant to reach, so if parts of it already fit what you know, skip down and hit other high points. This is also not a CoffeeScript tutorial, even though it is written in CoffeeScript and some pains are taken to explain how it works. Understand the process and how the product is being built from the requirements first, then try to make sense of the CoffeeScript.

### Goals:
- Think modularly around requirements and their representation in code
- Learn new patterns for how object communicate
- See some CoffeeScript in action

## Step 1: Break it Apart

<img src="/todo/todo-app.png" style="width:45%;" alt="todo app image">

What are the main parts of a todo app? A title, a checkbox, and a method of entering new items and keeping them around. What do these parts represent?

- State
- Display
- Persistance

How can we break the pieces of this app apart in code?

```coffeescript
class Todo
```

**cares about**: title string, done state (boolean)
This represents the state of the program.

```coffeescript
class Todos
```

**cares about**: todos (basically an array ot Todo items)
This covers the persistance of todos

```coffeescript
class TodoView
```

**cares about**: a single todo
This handles the display

```coffeescript
class TodoApp
```

**cares about**: a collection of todos (via Todos) and the page (where these things get rendered)
This piece brings all of the above pieces together

### Leading questions

- Where should the persistance be managed?
Two options:
    - the model
    - the collection

- How does our structuring determine the way interactions between the UI elements occur?
    - The app may modify/change the subviews, subviews should never affect the parent view.
    - Actions move inwards, never out.

## Step 2: Constructing

So what do all those pieces look like initially based on how we broke them up earlier? How do they start? What information do we feed each piece?

```coffeescript
class Todo
  constructor: (@title, @done=false) ->

# Create methods from an object, using destructuring! This is important later
Todo.create = ({title: title, done: done, id: id}) ->
  new Todo(title, done, id)

class Todos
  constructor: ->
    @store = new Storage("todo")  # our magic storage box
    @items = []

class TodoView extends Mustachio  # our magic view tool
  templateName: "item-template"  # magic attr identifying the template to use

  constructor: (@model) ->
    super @model  # ignore, initialization for Mustachio

class TodoApp
  constructor: (selector) ->
    @collection = new Todos()
    @el = $(selector)
```

There's some unfortunate magic in there, but treat the magic as a black box that just gives you what you want.

## Step 3: Persistance

Collection is handling persistance. So how do we reference Storage?

The structure is a little bit tricky. Storage stores the basic data, (title, done state and ID)
Todos wants to handle Todo objects. So whenever we cross the boundary of collection <-> storage,
we have to recreate the Todo object from the attributes. The Todos/Storage combination is like a super stupid ORM. This is also more commonly called the **repository pattern** of data access. The model or business logic is separate from the persistance logic.

<table class="table table table-bordered table-striped">
<thead>
  <tr>
    <th>Storage</th>
    <th>Todos</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>{title: "Test", done: false, id: 123}</td>
    <td>**Todo** - id: 123, done: false, title: "Test"</td>
  </tr>
  <tr>
    <td>{title: "Other", done: true, id: 321}</td>
    <td>**Todo** - id: 321, done: true, title: "Other"</td>
  </tr>
</tbody>
</table>

Therefore, Todo need a way to convert itself into an object literal. We'll call this method
`toJSON`

```coffeescript
class Todo
  toJSON: ->
    {title: @title, done: @done, id: @id}
```

Then the methods that Todos needs to create can serialize with this method.

```coffeescript
class Todos
  add: (todo) ->
    # add to storage, which returns a new id
    # assign the id to the todo
    # add to our local collection
    # return the updated todo

    todo.id = @store.add(todo.toJSON())
    @items.push todo
    todo

  remove: (todo) ->
    @store.remove(todo)

  all: ->
    @items

  refresh: () ->
    # getting all from storage returns the raw objects,
    # not Todo objects, so we need to convert. Let's move the converter to a separate
    # method

    raw_items = @store.all()

    # explain loops in CoffeeScript...
    @items = (@_createFromRaw(item) for item in raw_items)

    # return self, we could return the `@items` here, but we don't really want to
    # reference `@items` on its own. We want to access @items through the Todos object
    @

  # in JS, we pretend that methods prefixed with _ are private.
  _createFromRaw: (item) ->
    Todo.create(item)

  update: (todo) ->
    @store.update(todo.toJSON())
```

Why do we wrap so many of the Storage methods instead of just using Storage directly as needed? First, it's a design pattern called Single Responsiblity Principle (SRP). It states that each class should encapsulate a single responsibility. If Todos worried about collections of Todo objects and also dealing with the logic of persisting them to localStorage, it would be performing two responsibilities.

Secondly, it helps us keep the low-level details about the data structure required for persisting to a simple key-value storage mechanism like localStorage out of our application. If we decided to change our backend storage to use Memcached or even another .NET web API that worked with SQL or MongoDB, the Storage class is the only thing that would need to change. Our application would require **ZERO CHANGES**. This is why SRP is important.

And with that, we have a simple object, collection and persistance layer! In one fell swoop, we've completed one of our three goals: persistance. What about state?

Let's [try it](/todo/example-0.html)!

## Step 4: States and Events

```coffeescript
class Todo
  toggle: ->
    @done = !@done  # flipflop the state
```

Well that was easy! But wait... How do we persist state changes when the collection is responsible for persisting? How do we communicate changes?

Another concern we have along with SRP is keeping code coupling low. Low or loose coupling allows us to make changes in one class without affecting code in another class while allowing them to communicate changes and events. Enter jQuery Events.

```coffeescript
initEventHandler = (context) ->
  # Create an object for our event bindings.
  events = $({})

  # alias trigger to publish (for clarity)
  events.publish = events.trigger

  # alias the `on` function on the context to the event's `on`
  context.on = events.on

  # add this event handler to the context and return the events object.
  context.events = events
  events
```

This is a fun bit of code. What it's doing is creating an event handler on the given context. This scopes our event handlers to the objects that we pass to this initializer. Here's how it ties into our Todo class as we update the constructor:

```coffeescript
class Todo
  constructor: (@title, @done=false, @id=null) ->
    initEventHandler(@)
```

So we're passing the newly created Todo object (`@` == `this`) to the event handler initializer, which creates a @events handler within each instance of Todo. Again, as noted before, we never want to access this @events object outside of the Todo, which is why we "alias" the `on` on the event handler to an `on` method on the object. What does this give us?

Let's use this new functionality in a couple of places:

```coffeescript
class Todo
  toggle: ->
    @done = !@done
    @events.publish("change", @)

class Todos
  _createFromRaw: (raw_item) ->
    todo = Todo.create(raw_item)

    @_bindItem(todo)  # new...

    todo

  add: (todo) ->
    @_bindItem(todo)  # new ...

    todo.id = @store.add(todo.toJSON())
    @items.push todo
    todo

  # and here it is...
  _bindItem: (todo) ->
    todo.on("change", @update)

  # Note the change in the arrow type (fat arrow) and the method signature / arity
  update: (evtOrTodo, todo) =>
    todo ?= evtOrTodo  # conditional assignment
    @store.update(todo.toJSON())
```

First some notes. Whenever we do event binding, the method being called (`update` in this case) will need to change from the normal `->` to `=>` to ensure the "this" (`@`) context is preserved. If we didn't do this, `@` would reference the calling context (`Todo`), instead of the context we are acting in (`Todos`) and we would get an error saying that there is no method "update" on Todo, which is true, albeit somewhat confusing.

The other note is that the first argument in a method being called when using jQuery events is the event that was triggered. Therefore our first argument is the event and the second one is the argument we passed when we published the event (the todo object that was updated). Because we still want to be able to call the update in the form of `todos.update(todo)`, we also allow for the first argument to be a todo. Then we use the conditional assignment operator to say "if the `todo` var is not set, then the first argument (`evtOrTodo`) must be a todo object and not an event". A little confusing and there are clearer ways to do the same thing, but for brevity and simplicity, we'll do this.

And with that, we can change the item and have it automatically updated in the collection and therefore in storage. [Whaaaaa?!](/todo/example-1.html)

This is what makes eventing so powerful. Actions within Todos can happen independently of the Todo worrying about the actual state change. In fact, Todos doesn't care about what state a given Todo is in.

So just how easy is it to add more events? For example, let's say we want a `remove` method to the todo, so that we could call `todo.remove()` and not worry about about removing it from the collection. Well let's do it.

```coffeescript
class Todo
  # a single method added, which does nothing but publish an event.
  remove: -> @events.publish("remove", @)

class Todos
  # remember the arrow change and the signature difference
  remove: (evtOrTodo, todo) =>
    todo ?= evtOrTodo
    @items = @store.remove todo

  _bindItem: (todo) ->
    todo.on("change", @update)
    todo.on("remove", @remove)  # added...
```

A mere 10 lines of code. Lovely. And this completes goal #2 for us: State. One more to go.

Let's bring it all together as it stands:

```coffeescript
initEventHandler = (context) ->
  events = $({})
  events.publish = events.trigger

  context.on = (evt, callback) -> events.on(evt, callback)
  context.events = events

  events

class Todo
  constructor: (@title, @done=false, @id=null) -> initEventHandler(@)

  toggle: ->
    @done = !@done
    @events.publish("change", @)

  toJSON: -> {title: @title, done: @done, id: @id}

Todo.create = ({title: title, done: done, id: id}) ->
  new Todo(title, done, id)

class Todos
  constructor: ->
    @store = new Storage("todo")
    @items = []

  all: -> @items

  size: -> @items.length

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
```

Barely 60 lines of code and we've got most of the heavy work done. Now we just need some UI for this bad boy.

## Step 5: Views

**Introduce the HTML / templates**

First, let's deal with the input side of things: The TodoApp This is a little more complicated, but nothing unexpected. This app/view owns the collection of todos and the views and helps them talk together. Let's set it up.

The actions the view can do is:

- Type in a new todo title, and hit enter to submit.
- Render all the existing todos
- Check the "toggle all" checkbox and have all the todos toggle.

```coffeescript
class Todos
  # shortcut method so that we can create a todo with just the text of the input box
  create: (text) ->
    todo = new Todo(text)
    @add(todo)

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

  createOnEnter: (evt) =>
    return unless evt.keyCode == 13  # only respond to the enter keypress
    return unless @input.val()  # only respond if the input is not empty (cannot create empty todos)

    # create the new Todo via the collection
    @collection.create @input.val()

    # clear the input
    @input.val ''
```

This step lets us input new todos from the text box, even though it doesn't insert the new todo elements into the page yet. Take [a look](/todo/example-2.html).

Since we're cheating with our views a bit with some template magic (via handlebars), the rest is pretty simple. Let's create a Todo view. These views do three basic things:

- Display the todo's title
- Have a checkbox that toggles the state
- Have a delete button that deletes the item

All of those actions are handled by the code we've already written. So all we need to do is have a view that takes a todo (or model) and ties the click actions to the actions on our model.

```coffeescript
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
```

A few things of note. The render function sets a variable called `@el` which keeps a reference to the element on the page. This is important if we want to be able to update this later on as the model changes. This means that if we need to re-render the element, we don't want to replace the element altogether, we just want to replace the HTML.

So now we have a view, let's go back and wire it into the app.

```coffeescript
class TodoApp
  addOne: (todo) ->
    # create a view object
    view = new TodoView(todo)

    # append the html from the view to our list
    @list.append(view.render().el)

    # show the todo list (initially hidden) if it is hidden, this will be the case if this is the first element
    @main.show() unless @main.is(":visible")

  addAll: -> @addOne(todo) for todo in @collection.all()

  render: ->
    # clear any existing todos when we do a full refresh
    @list.html('')

    # add all the todos
    @addAll()

    # show the collection view if there are items in our collection.
    if @collection.size() then @main.show() else @main.hide()
```

And bam, we have all the pieces wired together! We can take a look at it, even though we have to handle the rendering ourselves. [Here it is](/todo/example-3.html).

# Step 5: Everything in Sync

As the demo shows, there are a few missing pieces yet, namely, how the view renders and updates itself when things happen. What did we decide was means of communicating change between objects? Events! So let's think about the signals we need to generate.

- Todos refreshed or recreated from Storage = update the full view
- Todo created = add it to the TodoApp view
- Todo removed = remove the TodoView
- Todo changed = update the TodoView

Some of these signals already exist from the model in the form of the "change" and "remove" signals. Can bind those in the view and use the signals to update the view, rather than the click actions.

```coffeescript
class TodoView
  constructor: (@model) ->
    super @model

    # bind to the events the todo generates
    @model.on("change", @render)
    @model.on("remove", @remove)

  # destroy tells the element to delete itself. this will cause the "remove" event to fire
  # which will now call the "remove" event below
  destroy: =>
    @model.remove()

  # remove now just removes the element from the page
  remove: =>
    @el.remove()

  render: =>
    html = super

    if @el
      @el.html(html)
    else
      @el = $("<li>#{html}</li>")
      @el.on("click", ".toggle", @toggle)
      @el.on("click", ".destroy", @destroy)  # change this method...

    # add in the UI strike through toggle for kicks, based on the todo's done state state
    @el.toggleClass("done", @model.done)
    @
```

Why are we splitting up `destroy` and `remove` and adding more callbacks? Well imagine we have a the console open and we want to delete elements there. If I call `todo.remove()`, the element will be removed from the collection but will still remain in the view. However, if we rely on the events to trigger the actual UI removal, we ensure the view and the model's state stay in sync.

So now we have the updates and removals taken care of. How about the initial render and collection adds? Well now we need to handle events that trigger on the collection, which means adding an event handler to the Todos class. With our magic `initEventHandler()` helper, we can do this in a single line. Here's what we end up with.

```coffeescript
class Todos
  constructor: ->
    # ...
    initEventHandler(@)

  add: (todo) ->
    # ...
    @events.publish("add", todo)  # our new "add" event

  clear: ->
    # ...
    @events.publish("refresh")  # our new "the collection has been refreshed" event

  refresh: () ->
    # ...
    @events.publish("refresh")  # also needed here
```

So these two new events on the collection tell us two things about the collection, when a new item has been added and when the collection as a whole has been changed (either cleared out or refreshed from storage). What should these events trigger? Updates to the TodoApp view of course! If the collection is refreshed, we basically need to re-render the entire list. But we already have the code for that (`render`). What about "add"? We have a method for this too (`addOne`)! Lets wire it up.

```coffeescript
class TodoApp
  constructor: (el) ->
    # ...
    @collection.on("refresh", @render)
    @collection.on("add", @addOne)

    @collection.refresh()


  # the only thing needing changing here is the fat arrow because this is now a triggered method.
  render: =>

  # change our method signature here like we did for the others, but no other changes needed
  addOne: (evtOrTodo, todo) =>
    todo ?= evtOrTodo
    # ... rest of the add code
```

And that's all that changes required to communicate these changes! Let's see it [in action](/todo/example-4.html).

Wow! A working Todo app! All the pieces are in place, everybody is communicating and all that in less than 160 lines of code! Let's see the whole thing all together.

```coffeescript
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

  create: (text) ->
    todo = new Todo(text)
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
    @events.publish("refresh")
    @

  remove: (evtOrTodo, todo) =>
    todo ?= evtOrTodo
    @items = @store.remove todo

  refresh: ->
    raw_items = @store.all()
    @items = (@_createFromRaw(item) for item in raw_items)

    @events.publish("refresh")
    @

  _createFromRaw: (raw_item) ->
    todo = Todo.create(raw_item)
    @_bindItem(todo)
    todo

  _bindItem: (todo) ->
    todo.on("change", @update)
    todo.on("remove", @remove)

class TodoView extends Mustachio
  templateName: "item-template"

  constructor: (@model) ->
    super @model

    @model.on("change", @render)
    @model.on("remove", @remove)

  render: =>
    html = super

    if @el
      @el.html(html)
    else
      @el = $("<li>#{html}</li>")
      @el.on("click", ".toggle", @toggle)
      @el.on("click", ".destroy", @destroy)

    @el.toggleClass("done", @model.done)
    @

  toggle: => @model.toggle()

  destroy: =>
    @model.remove()

  remove: =>
    @el.remove()

class TodoApp
  constructor: (el) ->
    @collection = new Todos()
    @el = $(el)

    @input = @el.find("#new-todo")
    @allCheckbox = @el.find("#toggle-all").first()
    @main = @el.find('#main')
    @list = @main.find("#todo-list")

    @collection.on("refresh", @render)
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

    if target.is(':checked')
      todo.setDone()
    else
      todo.setNotDone() for todo in @collection.all()
```

You may notice some changes for the toggle all checkbox. Review the code to see the changes required to make it happen. Overall, pretty simple. This is why we want to write code like this. The smaller and more focused we can divide up our code, the easier it is to make changes to the parts where they need to interact.