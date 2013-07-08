(function() {
  var Todo, TodoApp, TodoView, Todos, initEventHandler,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  initEventHandler = function(context) {
    var events;
    events = $({});
    events.publish = events.trigger;
    context.on = function(evt, callback) {
      return events.on(evt, callback);
    };
    context.events = events;
    return events;
  };

  Todo = (function() {
    function Todo(title, done, id) {
      this.title = title;
      this.done = done != null ? done : false;
      this.id = id != null ? id : null;
      initEventHandler(this);
    }

    Todo.prototype.toggle = function() {
      this.done = !this.done;
      return this.events.publish("change", this);
    };

    Todo.prototype.toJSON = function() {
      return {
        title: this.title,
        done: this.done,
        id: this.id
      };
    };

    return Todo;

  })();

  Todo.create = function(_arg) {
    var done, id, title;
    title = _arg.title, done = _arg.done, id = _arg.id;
    return new Todo(title, done, id);
  };

  Todos = (function() {
    function Todos() {
      this.update = __bind(this.update, this);
      this.store = new Storage("todo");
      this.items = [];
    }

    Todos.prototype.all = function() {
      return this.items;
    };

    Todos.prototype.size = function() {
      return this.items.length;
    };

    Todos.prototype.clear = function() {
      this.store.clear();
      this.items = [];
      return this;
    };

    Todos.prototype.create = function(text) {
      var todo;
      todo = new Todo(text);
      return this.add(todo);
    };

    Todos.prototype.add = function(todo) {
      this._bindItem(todo);
      todo.id = this.store.add(todo.toJSON());
      this.items.push(todo);
      return todo;
    };

    Todos.prototype.remove = function(todo) {
      this.store.remove(todo);
      return this.refresh();
    };

    Todos.prototype.refresh = function() {
      var item, raw_items;
      raw_items = this.store.all();
      this.items = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = raw_items.length; _i < _len; _i++) {
          item = raw_items[_i];
          _results.push(this._createFromRaw(item));
        }
        return _results;
      }).call(this);
      return this;
    };

    Todos.prototype._createFromRaw = function(item) {
      var todo;
      todo = Todo.create(item);
      this._bindItem(todo);
      return todo;
    };

    Todos.prototype.update = function(evtOrTodo, todo) {
      if (todo == null) {
        todo = evtOrTodo;
      }
      return this.store.update(todo.toJSON());
    };

    Todos.prototype._bindItem = function(todo) {
      return todo.on("change", this.update, todo);
    };

    return Todos;

  })();

  TodoView = (function(_super) {
    __extends(TodoView, _super);

    TodoView.prototype.templateName = "item-template";

    function TodoView(model) {
      this.model = model;
      this.remove = __bind(this.remove, this);
      this.toggle = __bind(this.toggle, this);
      TodoView.__super__.constructor.call(this, this.model);
    }

    TodoView.prototype.render = function() {
      var html;
      html = TodoView.__super__.render.apply(this, arguments);
      if (this.el) {
        this.el.html(html);
      } else {
        this.el = $("<li>" + html + "</li>");
        this.el.on("click", ".toggle", this.toggle);
        this.el.on("click", ".destroy", this.remove);
      }
      return this;
    };

    TodoView.prototype.toggle = function() {
      return this.todo.toggle();
    };

    TodoView.prototype.remove = function() {
      this.todo.remove();
      return this.el.remove();
    };

    return TodoView;

  })(Mustachio);

  TodoApp = (function() {
    function TodoApp(el) {
      this.createOnEnter = __bind(this.createOnEnter, this);
      this.collection = new Todos();
      this.el = $(el);
      this.input = this.el.find("#new-todo");
      this.main = this.el.find('#main');
      this.list = this.main.find("#todo-list");
      this.input.on("keypress", this.createOnEnter);
      this.collection.refresh();
    }

    TodoApp.prototype.createOnEnter = function(evt) {
      if (evt.keyCode !== 13) {
        return;
      }
      if (!this.input.val()) {
        return;
      }
      this.collection.create(this.input.val());
      return this.input.val('');
    };

    return TodoApp;

  })();

  BFG.each([Todo, Todos, TodoApp], function(klass) {
    return window[klass.name] = klass;
  });

}).call(this);
