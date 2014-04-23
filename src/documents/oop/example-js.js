"use strict";

var CombustionEngine = function () {};

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

var ElectricalEngine = function () {};

ElectricalEngine.prototype = {
  powerOn: function() { /* ... */ },
  powerOff: function() { /* ... */ },

  start: function() {
    this.powerOn();
  }
};


var Vehicle = function (engine) {
  this.engine = engine;
};

Vehicle.prototype.start = function () {
  this.engine.start();
};
