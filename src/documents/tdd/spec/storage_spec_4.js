describe("Storage", function() {
  var store;

  beforeEach(function() {
    store = new Storage()
  });

  it("can generate unique ids", function() {
    // quickly generate a bunch of ids
    var ids = [
      store.generateId(),
      store.generateId(),
      store.generateId(),
      store.generateId()
    ];

    expect(ids).toEqual([1,2,3,4]);
  });

  it("can reset the id counter", function() {
    store.generateId();
    var last = store.generateId();

    // test our generator is still generating
    expect(last).toEqual(2);

    // run a reset
    store.reset();
    var last = store.generateId();

    // now expect the first id to have rolled back.
    expect(last).toEqual(1);
  });

  it("can store an item", function() {
    var data = {item: "Test"};

    store.add(data);
    expect(localStorage[1]).toEqual(data);
  });
});