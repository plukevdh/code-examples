# Things to note:
# - Mocking boundaries (we have no control over Math.random())
# - Not testing everything, just what we care about Storage doing for us (domain)

describe "Storage", ->
  store = null

  beforeEach ->
    store = new Storage()

  afterEach ->
    store.clear()

  it "can store and retreive items", ->
    index = 0

    spyOn(store, '_guid').andCallFake ->
      index++

    store.add({item: "Test"})
    store.add({item: "Something"})

    expect(store.size()).toEqual(2)
    expect(store.all()).toEqual([{item: "Test", id: 0}, {item: "Something", id: 1}])

  it "can lookup items by guid", ->
    item = store.add({item: "Test"})

    expect(item).toEqual(store.get(item.id))

  it "can remove items", ->
    item1 = store.add({item: "Test"})
    item2 = store.add({item: "Something"})

    store.remove(item2)
    expect(store.size()).toEqual 1
    expect(store.all()).toEqual [item1]

  it "can remove an item by guid", ->
    item1 = store.add({item: "Test"})
    item2 = store.add({item: "Something"})

    store.removeId(item1.id)

    expect(store.size()).toEqual 1
    expect(store.all()[0]).toEqual item2