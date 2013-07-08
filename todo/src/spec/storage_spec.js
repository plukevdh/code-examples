(function() {
  describe("Storage", function() {
    var store;
    store = null;
    beforeEach(function() {
      return store = new Storage();
    });
    afterEach(function() {
      return store.clear();
    });
    it("can store and retreive items", function() {
      var index;
      index = 0;
      spyOn(store, '_guid').andCallFake(function() {
        return index++;
      });
      store.add({
        item: "Test"
      });
      store.add({
        item: "Something"
      });
      expect(store.size()).toEqual(2);
      return expect(store.all()).toEqual([
        {
          item: "Test",
          id: 0
        }, {
          item: "Something",
          id: 1
        }
      ]);
    });
    it("can lookup items by guid", function() {
      var item, itemId;
      itemId = store.add({
        item: "Test"
      });
      item = store.get(itemId);
      return expect(item.item).toEqual("Test");
    });
    it("can remove items", function() {
      var id1, id2, item1, item2;
      id1 = store.add({
        item: "Test"
      });
      id2 = store.add({
        item: "Something"
      });
      item1 = store.get(id1);
      item2 = store.get(id2);
      store.remove(item2);
      expect(store.size()).toEqual(1);
      return expect(store.all()).toEqual([item1]);
    });
    return it("can remove an item by guid", function() {
      var id1, id2, item2;
      id1 = store.add({
        item: "Test"
      });
      id2 = store.add({
        item: "Something"
      });
      store.removeId(id1);
      item2 = store.get(id2);
      expect(store.size()).toEqual(1);
      return expect(store.all()[0]).toEqual(item2);
    });
  });

}).call(this);
