# OOP: A Simple Introduction

As we talk about breaking requirements down in our application, generally we talk about principles defined by the principles of object-oriented programming (OOP). These principles are mostly setup to help define the way code is organized in order to help allow code to change without affecting how other parts work.

So let's think of an example that has many parts that all work together in the real world. A vehicle is generally the "Hello World" of the OOP examples, so we'll start there.

What's in a basic vehicle?
- Engine
- Wheels
- Doors
- Seats

Sure, there's a lot more. Vehicles are complicated pieces of engineering. But let's start there. So let's design a prototypical vehicle in code: Something that has all the pieces, but is not really specific enough to describe any one vehicle.

First, though, lets talk about some core components of most object-oriented languages.

## The Class

Classes define things. They tell someone who wants to use your code what it can do and shapes information can take. Classes are do not actually exist as the thing, they merely describe what it can do. For example, a recipie tells you how to bake a cake, what a cake is made of, but it is *not* a cake. The actual cake, going back to OOP is called an *instance* of the class Cake, or a Cake object. For example, in code this might look like this (CoffeeScript):

```coffeescript
# the class
class Cake
  constructor: (flour, eggs, sugar) ->
    @ingredients = [flour, eggs, sugar]

  # returns batter
  mix: -> 
    stir(@ingredients)

  # returns cake!
  bake: (batter, degrees, time) -> 
    heat(batter, degrees, time)
		
# the instance
cake = new Cake()

# using the insance like the class defines it can be used
batter = cake.mix()
cake.bake(batter, "350 deg", "45 min")
```

## Constructors
As seen in the CoffeeScript example, there is an explicit constructor. Constructors are methods that are called automatically when a new object is instantiated. They are generally used to do setup work on the new object at creation time. JavaScript doesn't have an explicit constructor, but using the right patterns, we can use a method with the same name as our "class" to do the work of a constructor. For example:

```javascript
var Cake = function(flour, eggs, sugar) {
  this.ingredients = [flour, eggs, sugar]
};

// or more properly, with better encapsulation via a closure

var Cake = (function() {
  function Cake(flour, eggs, sugar) {
    this.ingredients = [flour, eggs, sugar];
  }

  return Cake;
})();
```
The method `Cake()` is the constructor. We call `new Cake(…)` to create a new instance of a `Cake` or to get back a `Cake` object. It's basically just a way for us to do initialization tasks whenever we create a new object.

## Abstraction

Classes are an example of the principle of abstraction. It basically means that we define how something exists, a pattern or template of sorts, but not the thing itself. If we talk strictly JavaScript here, JavaScript doesn't have "classes" per say. Everything is an object. Eveything just exists and can be used as an entity. A motor is actually an instance of a motor. However, JavaScript provides us with the idea of prototypes or prototypical objects. This is almost a cleaner way to explain things. Imagine a prototype car. It isn't the version people can buy at a dealership, but it helps define what the car will look like once the manufacturer starts building them.

Why is this important? Abstraction helps us hide the details of how something works from the rest of the world. This means that anything that uses an instance of the abstraction only needs to know about the outside of that thing. 

For example, our Vehicle has wheels. the Wheel class might hold information about the air pressure levels or the tire manufacture or the hubcap design, but the Vehicle doesn't need to know any of that information. It just needs to know that it has four wheels and that they are all in working order for the car to move. The details are hidden from the Vehicle so that if we change the type of Wheel to be, say a RacingWheel or ColdWeatherWheel, the car won't need to change how it works with wheels, even if the Wheel changes type or how it works. Let's see a quick example.

```javascript
var Vehicle = function (wheels) {
    this.wheels = wheels;
};

Vehicle.numberOfWheels = 4;

Vehicle.prototype.drive = function () {
    if (this._hasWheels()) {
        this.wheels.forEach(function (wheel) {
            wheel.roll();
        });
    }
};

Vehicle.prototype._hasWheels = function () {
    return this.wheels.length === Vehicle.numberOfWheels;
};

var Wheel = function () {
    this.tread = "generic";
    this.hubcapDesign = "standard";
    this.airPressure = 35; // psi
};

Wheel.prototype.roll = function () {
    if (this.airPressure < 5) {
        throw "Air pressure too low to roll!";
    }
    this.rotate();
};

var wheels = [];
for (var i = 0; i < Vehicle.numberOfWheels; i++) {
    wheels.push(new Wheel());
}

var vehicle = new Vehicle(wheels);
vehicle.drive(); // away we go!
```

This shows us creating a `Vehicle` object and giving it wheels. The vehicle doesn't need to understand that a wheel has air pressure of 35, or that it has generic tread type. All it cares about is that a wheel can roll. You can see an example of this [here](http://jsfiddle.net/plukevdh/Q76th/). 

This hiding of details is important because now, I could create a new type of wheel with entirely different attributes that work in different ways, and so long as this new wheel can still roll, the vehicle can still use it!

```javascript
// The new wheel
var OffRoadWheel = function() {
  this.tread = "rough terrain";
  this.canRollWhenFlat = true;
};

OffRoadWheel.prototype = new Wheel();  // "inherit" from the basic wheel

// here we're overriding the parent's version to check if it can roll when flat.
OffRoadWheel.prototype.roll = function() {
  if(!this.canRollWhenFlat && this.airPressure < 5)  { throw "Tire is too flat to roll!"; }
  this.rotate(); // inherited from the parent object, Wheel
};

var wheels = [];
for (var i = 0; i < Vehicle.numberOfWheels; i++) {
  wheels.push(new OffRoadWheel());
}

var vehicle = new Vehicle(wheels);
vehicle.drive(); // now we can drive offroad!!
```

Notice how nothing changed in the `Vehicle` class. We still call `drive()`  on the vehicle which in turn calls `roll()` on the wheels. The wheels are entirely different and they can drive offroad now, but vehicle doesn't care. It just knows it can drive. See it [in action](http://jsfiddle.net/plukevdh/kAyF7/). Note too that in the `OffRoadWheel` object, we didn't define the `airPressure` or `rotate` method, but yet we can still reference them. We'll explain shortly.

This is the power of abstraction. If we keep details localized to the groupings that care about those details, we can change the inner workings of the pieces without affecting everyone else.

## Inheritance

In the second example, we demonstrated another principle: Inheritance. Inheritance is when you create something that gets its properties from another thing, generally referered to as a parent. Much like you *inherited* your eye and hair color, or facial structure from your parents, classes can inherit properties from other classes. We did this when we created the `OffRoadWheel` and setting the object's `prototype` to be the generic `Wheel`. This allowed the `airPressure` and the `rotate` method to exist on the child object, even though we didn't create them on the child. In CoffeeScript, this can be done using the `extends` keyword:

```coffeescript
class OffRoadWheel extends Wheel
```

This is a slightly more clean way of expressing what we are doing when we set the prototype of one object to another.

Inheritance is a powerful tool when mixed with abstraction, because we can create generic things (wheels, engines, doors, seats, etc) and explain what will exist for any of those object. For agency work, this might be a generic carousel or image gallery or file uploader. Then when we need a custom carousel, we don't have to rebuild an entire carousel from scratch, we take a basic one and extend it with the custom pieces.

## Encapsulation

Encapsulation is a part of abstraction. If abstraction is concerned with hiding the details from the world and providing a standard interface, the encapsulation deals with what is contained inside of that hiding. From the book Object Oriented Analysis and Design: 

> Abstraction and encapsulation are complementary concepts: abstraction focuses on the observable behavior of an object... encapsulation focuses upon the implementation that gives rise to this behavior... encapsulation is most often achieved through information hiding, which is the process of hiding all of the secrets of object that do not contribute to its essential characteristics.

In other words, abstraction is what the module does, encapsulation deals with the how it does it. Let's turn this into code with the vehicle again.

```javascript
var CombustionEngine = function () {};

CombustionEngine.prototype = {
  getFuel: function() { /* ... */ },
  chokeOn: function() { /* ... */ },
  chokeOff: function() { /* ... */ },
  fireStarter: function() { /* ... */ }
};


var Vehicle = function (engine) {
  this.engine = engine;
};

Vehicle.prototype.start = function () {};
```

At this point, we have a choice to make. We could make the vehicle responsible for getting fuel, setting the choke, firing the starter, etc. But think about the maintainence costs if we changed the engine type. Let's look at what it might look like.

```javascript
Vehicle.prototype.start = function () {
  this.engine.chokeOn();
  this.engine.getFuel();
  this.engine.fireStarter();
  this.engine.chokeOff();
};

var engine = new CombustionEngine();
var vehicle = new Vehicle(engine);

vehicle.start(); // Vroom...
```

What happens to this when if we wanted to change the engine type? Suppose we have an electrical engine?

```javascript
var ElectricalEngine = function () {};

ElectricalEngine.prototype = {
  powerOn: function() { /* ... */ },
  powerOff: function() { /* ... */ }
};

var engine = new ElectricalEngine();
var vehicle = new Vehicle(engine);

vehicle.start();  // Error: engine has no method "chokeOn"
```

Ut oh. Now we have to modify _both_ the engine ***and*** the vehicle just to change the engine type. This is because, as we've written it, the vehicle knows too much about how a specific type of engine is supposed to work. We've **leaked** details of the engine into the vehicle and thus **coupled** our classes very tightly (you can't change one without also changing the other). That's bad because it escalates maintanence costs in your code. What if we could just create a new engine and have the car still know how to operate it? How could that be done? Simple: Just make the engine responsible for knowing the startup sequence and provide a simple interface the the vehicle to run that sequence. Like so.

```javascript
CombustionEngine.prototype = {
  getFuel: function() { /* ... */ },
  chokeOn: function() { /* ... */ },
  chokeOff: function() { /* ... */ },
  fireStarter: function() { /* ... */ },

  start: function() {
    this.chokeOn();
    this.getFuel();
    this.fireStarter();
    this.chokeOff();
  }
};

Vehicle.prototype.start = function () {
  this.engine.start();
};

var engine = new CombustionEngine();
var vehicle = new Vehicle(engine);

vehicle.start();  // Vroom...
```

So now the `CombustionEngine` has *encapsulated* the knowledge of how to start the engine within itself and hidden the details of what is done to start an engine from the `Vehicle`.

So if we wanted to switch engine types, the new engine would just need to provde a `start()` method:

```javascript
ElectricalEngine.prototype = {
  powerOn: function() { /* ... */ },
  powerOff: function() { /* ... */ },

  start: function() {
    this.powerOn();
  }
};

var engine = new ElectricalEngine();
var vehicle = new Vehicle(engine);

vehicle.start();  // Very quiet vroom...
```

Now see that there were zero changes needed to the Vehicle in the last example. It just calls `this.engine.start()` and the engine handles the details of starting.

## Other Information

- A detailed look at how JavaScript does objects and how it compares with classical Class-based languages: [MDN - Details of the object model](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Details_of_the_Object_Model?redirectlocale=en-US&redirectslug=JavaScript%2FGuide%2FDetails_of_the_Object_Model#Class-Based_vs._Prototype-Based_Languages)