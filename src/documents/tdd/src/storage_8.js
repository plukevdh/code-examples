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

  // JSON helpers...
  Storage.prototype._toJSON = function(items) {
    return JSON.stringify(items);
  }

  Storage.prototype._fromJSON = function(json) {
    return JSON.parse(json);
  }

  return Storage;
})();

// make the object global
window.Storage = Storage;