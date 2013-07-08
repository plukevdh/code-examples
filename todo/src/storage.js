(function() {
  var Storage;

  Storage = (function() {
    function Storage(key) {
      this.key = key != null ? key : "demo";
      this.items = this._refresh();
    }

    Storage.prototype.add = function(item) {
      var id;
      id = this._guid();
      item.id = id;
      this.items[id] = item;
      this.save();
      return id;
    };

    Storage.prototype.get = function(guid) {
      return this.items[guid];
    };

    Storage.prototype.update = function(item) {
      if (!this._itemExists(item.id)) {
        throw "Item not found";
      }
      this.items[item.id] = item;
      return this.save();
    };

    Storage.prototype.remove = function(item) {
      return this.removeId(item.id);
    };

    Storage.prototype.removeId = function(guid) {
      if (!this._itemExists(guid)) {
        throw "Item not found";
      }
      delete this.items[guid];
      return this.save();
    };

    Storage.prototype.all = function() {
      return BFG.values(this.items);
    };

    Storage.prototype.save = function() {
      localStorage.setItem(this.key, this._toJSON(this.items));
      return this.all();
    };

    Storage.prototype.size = function() {
      return this.all().length;
    };

    Storage.prototype.clear = function() {
      delete localStorage[this.key];
      return this.items = {};
    };

    Storage.prototype._itemExists = function(guid) {
      return BFG.any(BFG.keys(this.items), function(id) {
        return id === guid;
      });
    };

    Storage.prototype._refresh = function() {
      var raw_data;
      raw_data = localStorage[this.key] || {};
      if (BFG.isEmpty(raw_data)) {
        return raw_data;
      } else {
        return this._fromJSON(raw_data);
      }
    };

    Storage.prototype._toJSON = function(items) {
      return JSON.stringify(items);
    };

    Storage.prototype._fromJSON = function(json) {
      return JSON.parse(json);
    };

    Storage.prototype._S4 = function() {
      return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
    };

    Storage.prototype._guid = function() {
      return this._S4() + this._S4() + "-" + this._S4() + "-" + this._S4() + "-" + this._S4() + "-" + this._S4() + this._S4() + this._S4();
    };

    return Storage;

  })();

  window.Storage = Storage;

}).call(this);
