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
    itemId = store.add({item: "Test"})

    item = store.get(itemId)

    expect(item.item).toEqual("Test")

  it "can remove items", ->
    id1 = store.add({item: "Test"})
    id2 = store.add({item: "Something"})

    item1 = store.get(id1)
    item2 = store.get(id2)

    store.remove(item2)
    expect(store.size()).toEqual 1
    expect(store.all()).toEqual [item1]

  it "can remove an item by guid", ->
    id1 = store.add({item: "Test"})
    id2 = store.add({item: "Something"})

    store.removeId(id1)
    item2 = store.get(id2)

    expect(store.size()).toEqual 1
    expect(store.all()[0]).toEqual item2