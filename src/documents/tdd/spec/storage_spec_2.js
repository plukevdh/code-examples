describe("Storage", function() {
  var store;

  beforeEach(function() {
    store = new Storage()
  });

  it("can store an item", function() {
    var data = {item: "Test"};

    store.add(data);
    expect(localStorage[1]).toEqual(data);
  });
});