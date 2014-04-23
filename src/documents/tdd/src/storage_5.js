// The Storage closure. Keep your shit isolated.
//
// Please.
//
// For the love of javascript
// and everyone else's peace of mind.

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

  Storage.prototype.reset = function() {
    uniqueId = 0;
  }

  return Storage;
})();

// make the object global
window.Storage = Storage;