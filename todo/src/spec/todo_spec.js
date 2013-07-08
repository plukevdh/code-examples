(function() {
  describe("Todo", function() {
    var todo;
    todo = null;
    beforeEach(function() {
      return todo = new Todo("test");
    });
    it("can toggle todo state", function() {
      expect(todo.done).toBeFalsy();
      todo.toggle();
      expect(todo.done).toBeTruthy();
      todo.toggle();
      return expect(todo.done).toBeFalsy();
    });
    it("can generate object representation (for JSON)", function() {
      return expect(todo.toJSON()).toEqual({
        title: "test",
        done: false,
        id: null
      });
    });
    it("triggers a change event on done toggle", function() {
      spyOn(todo.events, "publish");
      todo.setDone();
      todo.setNotDone();
      expect(todo.events.publish).toHaveBeenCalledWith("change", todo);
      return expect(todo.events.publish.callCount).toEqual(2);
    });
    return it("triggers a remove event on remove toggle", function() {
      spyOn(todo.events, "publish");
      todo.remove();
      return expect(todo.events.publish).toHaveBeenCalledWith("remove", todo);
    });
  });

  describe("Todos", function() {
    var todos;
    todos = null;
    beforeEach(function() {
      return todos = new Todos();
    });
    afterEach(function() {
      return todos.clear();
    });
    it("can create and persist a record", function() {
      var todo;
      todo = todos.create("item");
      expect(todos.size()).toEqual(1);
      expect(todos.all()).toEqual([todo]);
      return expect(todo.id).not.toBeNull();
    });
    it("can add a record object", function() {
      var todo;
      todo = new Todo("item");
      todo = todos.add(todo);
      expect(todos.size()).toEqual(1);
      expect(todos.all()).toEqual([todo]);
      return expect(todo.id).not.toBeNull();
    });
    it("saves records when internals are updated change", function() {
      var todo;
      spyOn(todos, "update");
      todo = new Todo("item");
      todos.add(todo);
      todo.toggle();
      return expect(todos.update).toHaveBeenCalled();
    });
    it("can get all records", function() {
      var todo1, todo2;
      todo1 = todos.create("item");
      todo2 = todos.create("item 2");
      return expect(todos.all()).toEqual([todo1, todo2]);
    });
    it("can remove a record", function() {
      var todo1, todo2;
      todo1 = todos.create("item");
      todo2 = todos.create("item 2");
      todos.remove(todo1);
      return expect(todos.all()[0]).toEqual(todo2.toJSON());
    });
    it("removes a record on record deletion", function() {
      var todo;
      todo = todos.create("item 1");
      expect(todos.size()).toEqual(1);
      todo.remove();
      return expect(todos.size()).toEqual(0);
    });
    return it("refresh triggers update", function() {
      spyOn(todos.events, "publish");
      todos.refresh();
      return expect(todos.events.publish).toHaveBeenCalledWith("all");
    });
  });

}).call(this);
