describe("Storage", function() {
  var store;

  beforeEach(function() {
    store = new Storage()
    store.reset();
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

  it("can encode content", function(){
    // some test data
    data = {one: 1, two: 2}

    // lets call the method _toJSON, using underscore to represent the
    // idea that this is a "private method"
    encoded = store._toJSON(data)
    expect(encoded).toEqual('{"one":1,"two":2}')
  });

  it("can decode content", function(){
    data = '{"one":1,"two":2}'
    encoded = store._fromJSON(data)
    expect(encoded).toEqual({one: 1, two: 2})
  });

  it("can store an item", function() {
    var data = {item: "Test"};

    store.add(data);
    expect(localStorage[1]).toEqual(data);
  });
});