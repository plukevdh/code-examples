---
title: "TDD | Tutorial"
layout: "default"
isPage: true
---

# How to TDD

This tutorial is for those of you who hear the term "testing" or "test-driven development", think it's a great idea, and then try to do it and it turns into this:

![](http://mlkshk.com/r/97VP#.jpg)

TDD **is** a great idea, and while it seems counter-productive, ultimately it can be one of the greatest design tools in your development skillset. It allows you to think through how you want your program to work and what kind of code you want to be able to write before you write it. The best code you will write is the code you know and understand _before you even write it_.

![](http://monosnap.com/image/bELg6FxposjtsS6v1KnYPzvU0FIUnv.png)

With that in mind, let's get started.

## What does a TDD Workflow Look Like?

> Red. Green. Refactor.

First you write tests (hence "test-driven"). Because you write them first, they are already failing because the code to make them pass isn't written yet. Hence "Red". Step two is to write the code to make those tests pass ("Green"). Once you have that, you know your code works to specification, and you can refactor the code with ease of mind because you know that if you mess up or break something, the tests will tell you. There are a couple of ground rules:

- The goal is to only ever be writing tests **OR** code. Never both at the same time, otherwise you introduce uncertainty into why tests start to fail (was it a broken test or broken code?). 
- Don't write **ALL** your tests at once. Just enough to get started. Then get those tests to pass. Then write more failing tests, then more code to make them pass, and on...
- Don't write tests you _don't know can_ fail. In other words, don't write tests for code you have, or if you do, remove the code briefly to ensure the test fails in the absence of your code. Otherwise, you can't be sure your test actually works.

With that in mind, let's try our hand at an example. 

## The Example

If you remember from our [ToDo App example](/todo/todo-steps.html), we backended the todo items to localStorage, using a simple wrapper. While I hid the implementation of that wrapper from you during the example, we're going to look at how to implement that mini-library for use anywhere. Here are some generic requirements:

- Can store new items
- Each item stored gets a unique id
- Can retrieve item stored by ID
- Can remove item by ID
- Can remove item by an item
- Can remove all items
- Can return number of items
- Can retrieve all items
- Can update items
- Can have multiple storage sets that are isolated

Not too complicated and pretty easy to map to tests.

## Setup

For these examples, I'm going to write the code in flat javascript (as much as I love CoffeeScript) using no dependencies. The tests will use [Jasmine 2.0](http://jasmine.github.io/2.0/introduction.html). It's a fairly minimal testing suite and pretty easy to learn. 

## Let's go: Test one.

So in order to test most of the other things (retreival, removal, etc) we need a way to **add** items. So let's start there. Remember, with TDD, we get to imagine the code we want to be able to use on the other end, so while we could do:

```js
var object = storage.createAnObject({thing: "one"})
object.id = storage.generateUniqueId()
storage.storeThisThingIHave(object)
storage.save()
```

that seems a bit obtuse. Maybe we'd like to just say:

```js
var object = {thing: "one"}
storage.store(object)
```

and be done with it. So let's write a test that specifies that. However, the first thing we need to be able to do is create an instance of `Storage`. But, remember, tests first.

```js
// our first Jasmine test!
describe("Storage", function() {
  // this will be the store object we are testing. need to initialize it here
  // so that we have access to it throughout the tests
  var store;	

  // beforeEach is a jasmine function that gets run before every test that 
  // gets run.
  beforeEach(function() {

		// now we initialize the new storage object
    store = new Storage()
  });
});
```

If we run this by opening up the [spec runner](spec_runner_1.html), we'll see it doesn't really do much yet, but at least it looks like Jasmine is running. So far, we don't have any test, but the test runner is firing up. So let's give it a test to run.

```js
describe("Storage", function() {
	var store;

  beforeEach(function() {
    store = new Storage()
  });
  
  it("can store an item", function() {
		// some test data
    var data = {item: "Test"};

    // store the data
    store.add(data);

    // tell jasmine what we expect to be in localStorage after we save it
    // notice that we are looking up by the id "1". remember our specification
    // from above mentions that we expect each key to be stored with a unique 
    // id so we can reference later
    expect(localStorage[1]).notToBeUndefined();
    expect(localStorage[1]).toEqual(data);
  });
});
```

So let's look at our [spec runner](spec_runner_2.html) now. You'll see two errors now. One that tells us we have an illegal constructor, the other telling us there is no property "add" of undefined. What happened?

Two things: The first is the `beforeEach` statement is now being called, so it's trying to call `new Storage()`, but because there is no such `Storage` object yet (because we haven't defined it), it tells us we can't call it's constructor yet. The second error stems from the first. Because we can't create a new `Storage` object, we also can't call `add()` on it because it's undefined.

The first tip for doing TDD here is learn to understand what the errors mean simply from the error message if you can before having to trace back to the line giving you the error. It helps to guess whether or not the tests are going to pass or fail _before_ you run the tests. If you guessed wrong, understand why before continuing. Guessing incorrectly means you don't understand what the test is doing or how your code is responding to the tests.

![](http://24.media.tumblr.com/tumblr_me9r0pE0BH1qzjax2o1_500.jpg)

With that in mind, we should have expected this failure because we haven't written any code for `Storage` yet. So let's do that.

## First Code

What do we need to make this single test pass? So far we're testing two of our requirements: 

- Can store new items
- Each item stored gets a unique id

So we need to write the code to perform those two actions. Let's create a storage.js file and add it to the spec runner.

```js
// The Storage closure. Keep your shit isolated.
//
// Please.
//
// For the love of javascript
// and everyone else's peace of mind.

var Storage = (function() {
  // our constructor, where we can initialize everything needed
	function Storage() {

	}

  // our add method, takes a single item
  Storage.prototype.add = function(item) {
    // ???
  }

	return Storage;
})();

// make the object global
window.Storage = Storage;
```

At this point, we should have resolved the first two errors: Missing constructor and no method `add` for undefined. So if we run the tests, will it pass? We could try, but remember, I told you to guess first. My guess is that it won't pass because `add()` doesn't do anything and we're expecting `localStorage` to contain something at this point. Let's [check the tests](spec_runner_2.html).

And hey! New errors. Just as we (err, **I**) guessed, our old errors are now solved and we get a "Expected undefined to equal { item : 'Test' }" message. This is because, as hinted, we're not storing anything in localStorage yet, so when we tell jasmine that we expect a value to be in localStorage, jasmine can't find it and throws a new error.

This leads me to the next tip for good TDD: Only write code to solve the errors you currently see. I _could_ have written the localStorage code, but we didn't have an error for that yet, so we didn't write the code for it yet. _Now_ that we have an error, we should write the code to make it pass.

Adding things to localStorage is pretty easy. If you run this in a console, it should print "someValue";

```js
localStorage["someKey"] = "someValue";
console.log(localStorage["someKey"]);
```

But we have one requirement: That it has a unique id. For our purposes, a unique value can just be an incrementing number. 1, 2, 3, 4... However, we should keep the details of that id generator separate from the `add` method, so that if it needs to change later, we can change it and not break more code. And _because_ we're adding a sepearate method for the id generator, we should have what? **A test!**


```js
describe("Storage", function() {
  var store;

  beforeEach(function() {
    store = new Storage()
  });

  // gonna add this test here since it's a requirement to 
  // make the test below pass as well really up to you where 
  // you want to put this test
  it("can generate unique ids", function() {
    // quickly generate a bunch of ids
    var ids = [
      store.generateId(),
      store.generateId(),
      store.generateId(),
      store.generateId()
    ];

    // test that they're all unique
    expect(ids).toEqual([1,2,3,4]);
  });

  it("can store an item", function() {
    var data = {item: "Test"};

    store.add(data);
    expect(localStorage[1]).toEqual(data);
  });
});
```

Now we still won't have made the first failing test pass, but we've also added a failing test. So my expectation is that we will have two failures, the new one stating that there is no method 'generateId()'. [Let's run and see](spec_runner_3.html).

Good, so let's write that method. Remember, only write enough to fix the error we've seen, which is that the method doesn't exist.

``` js
Storage.prototype.generateId = function() {
  // ???
}
```

That should fix the error we saw. And give us a new error, stating that we expected `[1,2,3,4]` but actually got `[undefined,undefined,undefined,undefined]`. This is because our `generateId()` is not returning anything yet. **Now** we cah write some code and get our first passing test!

```js
var Storage = (function() {

	// unique id within the storage scope. note: this is hidden to the outside world
	// which ultimately is what we want
  var uniqueId = 0;

  // our constructor, where we can initialize everything needed
  function Storage() {}

  // our add method, takes a single item
  Storage.prototype.add = function(item) {
    // ???
  }

  Storage.prototype.generateId = function() {
		// one liner to increment the id, then return it
    return ++uniqueId;
  }

  return Storage;
})();
```

[Run the tests again](spec_runner_5.html) to check if that implementation satisfies the conditions we expect. OH SNAP. We now have a green dot and one red X and only one error message, meaning we have a passing test! Congratulations! You are now a test-driven developer!

## The End

Just kidding. We have a whole crapload of functionality to write. Lets finish this first round up by getting the second test to pass using the new functionality we added.

```js
var Storage = (function() {
  // our constructor, where we can initialize everything needed
  var uniqueId = 0;
  function Storage() {}

  // our add method, takes a single item
  Storage.prototype.add = function(item) {
    localStorage[this.generateId()] = item;
  }

  Storage.prototype.generateId = function() {
    return ++uniqueId;
  }

  return Storage;
})();
```

And how does the [test suite fare now](spec_runner_6.html)? Still failing eh? That was unexpected. I wonder why... If you open up a console and enter `localStorage`, it will give you back the contents of all of localStorage. If you don't use localStorage for much, it should be pretty empty, but notice the item with the key '5'. It's [object Object]. Given the data we're storing and our key generator, that looks a lot like our data... But why the key 5?

The answer is in the first test:

```
var ids = [
  store.generateId(),
  store.generateId(),
  store.generateId(),
  store.generateId()
];
```	

We've incremented the counter 4 times before we hit this test! So 5 _really is_ the next value. That's sort of expected-but-not-really-expected behavior, and those kinds of behaviors are bad. But we have tests! It caught this strange behavior and flagged it as an error. So now we can be more explicit about how we expect our ID generator to behave. Let's add the ability to reset the counter. But don't just add it, write the test first.

```js
it("can reset the id counter"), function() {
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
```

[Run the tests](spec_runner_7.html). And now we have two new errors. Expected 6 to equal 2 and undefined is not a function. The second one should be expected, since we haven't written a `reset()` method yet. But the first one is the same issue we saw before: The counter is still not reset. Since we really want each test to run in isolation with a clean slate, we can actually add a call to `reset()` in the `beforeEach()` function at the beginning of the test suite to solve the first error. While we're at it, let's also fix the `undefined error`.

**Spec**
```js
beforeEach(function() {
  store = new Storage()
  store.reset();
});
```

**Code**
```js
Storage.prototype.reset = function() {
  uniqueId = 0;
}
```

And [run tests again](spec_runner_8.html). **Woot!** Passing test again! But we still have one failure, albiet a different one: "Expected '[object Object]' to equal { item : 'Test' }.". What would cause that? Our investigation into the way localStorage stores data should have tipped you off on that one. LocalStorage only stores strings. Hmm... how do we solve that? What if we encoded the objects as JSON before storing in localStorage? We could just try it an see, something like the following: 

```js
localStorage[this.generateID()] = JSON.stringify(item);
```

However, that causes us to depend directly on JSON without a clean way to change how we encode something if we wanted to change it later. In the spirit of being good software architects, the encoding functionality too, should be testable independently of the `add()` method.

## An Aside

As you may have noticed, every time I've said we need something new in the system, it's been a) tested first b) separated from the rest of the code. In fact testing helps lead to better separation of the units of functionality, so that if one part needs to change, it only changes in one place. Then you can compose these functions into larger groupings of functionaliy. This is called [function composition][1]. This way, we can build complicated functionality from smaller units of much simpler functionality. For example, our add is a composite function because it takes in three methods and makes them run in sequence:

- Generate a unique ID.
- Encode the content as JSON
- Store it in localStorage

So we can test each of those components independently and be ensured that the composite works as well. So let's do that.

## Back to the Code

Since we're going to need to encode and then decode the content coming back out, let's write tests for both encoding and decoding at the same time. Simple:

```js
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
```

And [run them](spec_runner_10.html) with the expectation we'll get two more failures of 'undefined' methods. Now let's write those methods:

```js
// JSON helpers...
Storage.prototype._toJSON = function(items) {
  return JSON.stringify(items);
}

Storage.prototype._fromJSON = function(json) {
  return JSON.parse(json);
}
```

[Run again](spec_runner_11.html). Okay, green lights. __Finally__ we can setup the add and we should have a fully-passing test suite!

```js
Storage.prototype.add = function(item) {
	// restructured a little bit to show how the function
	// is composed of the other methods.
  var id = this.generateId()
    , data = this._toJSON(item);

  localStorage[id] = data;
}
```

[One more time!](spec_runner_12.html) Ack, not quite. Remember we are looking at localStorage, which is returning a string where we are expecting an object. So while we can see the data is the same, ultimately, jasmine says there are some slight differences. This is a case of us writing a test incorrectly, not a code error. So we can either expect the string, or decode using our json method. Totally your call.

```js
it("can store an item", function() {
  var data = {item: "Test"};

  store.add(data);
  expect(localStorage[1]).toEqual(JSON.stringify(data));
});
```

[And boom](spec_runner_13.html). 5 passing tests zero failure. Now look at all the beautiful code we've written! So simple, self-contained, and fully functional!

Let's look at the code we have in it's entirety so far:

**Code**
```js
var Storage = (function() {
  var uniqueId = 0;
  function Storage() {}

  Storage.prototype.add = function(item) {
    var id = this.generateId()
      , data = this._toJSON(item);

    localStorage[id] = data;
  }

  Storage.prototype.generateId = function() {
    return ++uniqueId;
  }

  Storage.prototype.reset = function() {
    uniqueId = 0;
  }

  Storage.prototype._toJSON = function(items) {
    return JSON.stringify(items);
  }

  Storage.prototype._fromJSON = function(json) {
    return JSON.parse(json);
  }

  return Storage;
})();

window.Storage = Storage;
```

**Tests**
```js
describe("Storage", function() {
  var store;

  beforeEach(function() {
    store = new Storage()
    store.reset();
  });

  it("can generate unique ids", function() {
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

    expect(last).toEqual(2);

    store.reset();
    var last = store.generateId();

    expect(last).toEqual(1);
  });

  it("can encode content", function(){
    data = {one: 1, two: 2}

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
    expect(localStorage[1]).toEqual(JSON.stringify(data));
  });
});

```

How hard do you think it would be now to add the rest of the requirements?

[1]: http://en.wikipedia.org/wiki/Function_composition_(computer_science)