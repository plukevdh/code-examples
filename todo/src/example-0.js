(function() {
  var Todo, Todos;

  Todo = (function() {
    function Todo(title, done, id) {
      this.title = title;
      this.done = done != null ? done : false;
      this.id = id != null ? id : null;
    }

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

    Todos.prototype.add = function(todo) {
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
      return Todo.create(item);
    };

    Todos.prototype.update = function(todo) {
      return this.store.update(todo.toJSON());
    };

    return Todos;

  })();

  BFG.each([Todo, Todos], function(klass) {
    return window[klass.name] = klass;
  });

  $(function() {
    window.collection = new Todos().clear();
    collection.add(new Todo("test"));
    return collection.add(new Todo("another"));
  });

}).call(this);
