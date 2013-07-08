(function() {
  var ArrayProto, FuncProto, ObjProto, any, breaker, functions, nativeBind, nativeForEach, nativeIsArray, nativeKeys, nativeMap, nativeSome, slice, toString,
    __hasProp = {}.hasOwnProperty;

  window.BFG = {};

  BFG.isEmpty = function(obj) {
    var key;
    if (BFG.isArray(obj) || BFG.isString(obj)) {
      return obj.length === 0;
    }
    for (key in obj) {
      if (!__hasProp.call(obj, key)) continue;
      return false;
    }
    return true;
  };

  BFG.isElement = function(obj) {
    return obj && obj.nodeType === 1;
  };

  BFG.isArray = nativeIsArray || function(obj) {
    return !!(obj && obj.concat && obj.unshift && !obj.callee);
  };

  BFG.isArguments = function(obj) {
    return obj && obj.callee;
  };

  BFG.isFunction = function(obj) {
    return !!(obj && obj.constructor && obj.call && obj.apply);
  };

  BFG.isString = function(obj) {
    return !!(obj === '' || (obj && obj.charCodeAt && obj.substr));
  };

  BFG.isNumber = function(obj) {
    return (obj === +obj) || toString.call(obj) === '[object Number]';
  };

  BFG.isBoolean = function(obj) {
    return obj === true || obj === false;
  };

  BFG.isDate = function(obj) {
    return !!(obj && obj.getTimezoneOffset && obj.setUTCFullYear);
  };

  BFG.isRegExp = function(obj) {
    return !!(obj && obj.exec && (obj.ignoreCase || obj.ignoreCase === false));
  };

  BFG.isNaN = function(obj) {
    return BFG.isNumber(obj) && window.isNaN(obj);
  };

  BFG.isNull = function(obj) {
    return obj === null;
  };

  BFG.isUndefined = function(obj) {
    return typeof obj === 'undefined';
  };

  BFG.range = function(start, stop, step) {
    var a, i, idx, len, range, solo;
    a = arguments;
    solo = a.length <= 1;
    i = start = solo ? 0 : a[0];
    stop = solo ? a[0] : a[1];
    step = a[2] || 1;
    len = Math.ceil((stop - start) / step);
    if (len <= 0) {
      return [];
    }
    range = new Array(len);
    idx = 0;
    while (true) {
      if ((step > 0 ? i - stop : stop - i) >= 0) {
        return range;
      }
      range[idx] = i;
      idx++;
      i += step;
    }
  };

  BFG.keys = nativeKeys || function(obj) {
    var key, val, _results;
    if (BFG.isArray(obj)) {
      return BFG.range(0, obj.length);
    }
    _results = [];
    for (key in obj) {
      val = obj[key];
      _results.push(key);
    }
    return _results;
  };

  BFG.values = function(obj) {
    var key, val, _results;
    _results = [];
    for (key in obj) {
      val = obj[key];
      _results.push(val);
    }
    return _results;
  };

  BFG.rest = function(array, index, guard) {
    return slice.call(array, BFG.isUndefined(index) || guard ? 1 : index);
  };

  BFG.each = function(obj, iterator, context) {
    var e, i, key, val, _i, _ref;
    try {
      if (nativeForEach && obj.forEach === nativeForEach) {
        obj.forEach(iterator, context);
      } else if (BFG.isNumber(obj.length)) {
        for (i = _i = 0, _ref = obj.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          iterator.call(context, obj[i], i, obj);
        }
      } else {
        for (key in obj) {
          if (!__hasProp.call(obj, key)) continue;
          val = obj[key];
          iterator.call(context, val, key, obj);
        }
      }
    } catch (_error) {
      e = _error;
      if (e !== breaker) {
        throw e;
      }
    }
    return obj;
  };

  BFG.map = function(obj, iterator, context) {
    var results;
    if (nativeMap && obj.map === nativeMap) {
      return obj.map(iterator, context);
    }
    results = [];
    BFG.each(obj, function(value, index, list) {
      return results.push(iterator.call(context, value, index, list));
    });
    return results;
  };

  BFG.filter = function(obj, iterator, context) {
    var results;
    if (nativeFilter && obj.filter === nativeFilter) {
      return obj.filter(iterator, context);
    }
    results = [];
    BFG.each(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) {
        return results.push(value);
      }
    });
    return results;
  };

  BFG.identity = function(value) {
    return value;
  };

  any = BFG.any = function(obj, iterator, context) {
    var result;
    iterator || (iterator = BFG.identity);
    result = false;
    if (obj === null) {
      return result;
    }
    if (nativeSome && obj.some === nativeSome) {
      return obj.some(iterator, context);
    }
    BFG.each(obj, function(value, index, list) {
      if (result || (result = iterator.call(context, value, index, list))) {
        return breaker;
      }
    });
    return !!result;
  };

  BFG.find = function(obj, iterator, context) {
    var result;
    result = null;
    any(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) {
        result = value;
        return true;
      }
    });
    return result;
  };

  BFG.bind = function(func, context) {
    var args;
    if (nativeBind && func.bind === nativeBind) {
      return nativeBind.apply(func, BFG.rest(arguments));
    }
    args = BFG.rest(arguments, 2);
    return function() {
      return func.apply(context, args.concat(BFG.rest(args)));
    };
  };

  BFG.bindAll = function(obj) {
    var funcs;
    funcs = arguments.length > 1 ? BFG.rest(arguments) : functions(obj);
    BFG.each(funcs, function(f) {
      return obj[f] = BFG.bind(obj[f], obj);
    });
    return obj;
  };

  functions = function(obj) {
    return BFG.filter(BFG.keys(obj), function(key) {
      return BFG.isFunction(obj[key]);
    }).sort();
  };

  breaker = typeof StopIteration === 'undefined' ? '__break__' : StopIteration;

  FuncProto = Function.prototype;

  ArrayProto = Array.prototype;

  ObjProto = Object.prototype;

  nativeBind = FuncProto.bind;

  nativeIsArray = Array.isArray;

  slice = ArrayProto.slice;

  nativeForEach = ArrayProto.forEach;

  nativeMap = ArrayProto.map;

  nativeSome = ArrayProto.some;

  nativeKeys = Object.keys;

  toString = ObjProto.toString;

}).call(this);
