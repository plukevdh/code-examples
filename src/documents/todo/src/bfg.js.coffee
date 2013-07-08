# **BFG** is the namespace for all helper methods which are generally of minimal consequence
# These methods are generally very small and extremely focused in their purpose. We'd like to
# keep this namespace as compact as possible to decrease load time in pages/libs that utilize it.

# This is the global namespace, setup on `window` so that we can access it externally elsewhere.
# Coffeescript likes to close compilations in a local, anonymous closure, so this gets us past that.
window.BFG = {}

#### Boolean test helpers ####

# Checks if arrays, strings or objects are empty.
BFG.isEmpty = (obj) ->
  return obj.length is 0 if BFG.isArray(obj) or BFG.isString(obj)
  return false for own key of obj
  true

# Check if this is an HTML element (not jquery specific)
BFG.isElement   = (obj) -> obj and obj.nodeType is 1

# Checks if the given object is an array. Attempts to use native array detection.
BFG.isArray     = nativeIsArray or (obj) -> !!(obj and obj.concat and obj.unshift and not obj.callee)

# Checks if the given object is an arguments array.
BFG.isArguments = (obj) -> obj and obj.callee


# Most of the following are fairly self explainitory
BFG.isFunction  = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)
BFG.isString    = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))
BFG.isNumber    = (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
BFG.isBoolean   = (obj) -> obj is true or obj is false
BFG.isDate      = (obj) -> !!(obj and obj.getTimezoneOffset and obj.setUTCFullYear)
BFG.isRegExp    = (obj) -> !!(obj and obj.exec and (obj.ignoreCase or obj.ignoreCase is false))
BFG.isNaN       = (obj) -> BFG.isNumber(obj) and window.isNaN(obj)
BFG.isNull      = (obj) -> obj is null
BFG.isUndefined = (obj) -> typeof obj is 'undefined'


# `.range` is a helper that gives you a range array for other
# iteration methods. It takes at least one parameter, the range end.
# Otherwise it can take a start value, an end value, and a
# step value (how far each iteration should move).
#
# Usage looks like
#
#     BFG.range(1, 5) # => [1, 2, 3, 4, 5]
#     BFG.range(1, 20, 3) # => [1, 4, 7, 10, 13, 16, 19]
#
BFG.range = (start, stop, step) ->
  a         = arguments
  solo      = a.length <= 1
  i = start = if solo then 0 else a[0]
  stop      = if solo then a[0] else a[1]
  step      = a[2] or 1
  len       = Math.ceil((stop - start) / step)
  return []   if len <= 0
  range     = new Array len
  idx       = 0
  loop
    return range if (if step > 0 then i - stop else stop - i) >= 0
    range[idx] = i
    idx++
    i+= step

# Return an array of the keys of an object
#
#     BFG.keys {one: 1, two: 2, three: 3 }
#     # returns ['one', 'two', 'three']
BFG.keys = nativeKeys or (obj) ->
  return BFG.range 0, obj.length if BFG.isArray(obj)
  key for key, val of obj


BFG.values = (obj) ->
  val for key, val of obj

# Return the array without the first one
#
#     BFG.rest([1,2,3])
#     # returns [2,3]
BFG.rest = (array, index, guard) ->
  slice.call(array, if BFG.isUndefined(index) or guard then 1 else index)

# Allows you to iterate over all elements in an array or object and act on them
#
#     BFG.each([1,2,3], (item) -> alert item*5)
#
# This will trigger 3 alerts with "5", "10" and "15" respectively.
# Returns the original object.
BFG.each = (obj, iterator, context) ->
  try
    if nativeForEach and obj.forEach is nativeForEach
      obj.forEach iterator, context
    else if BFG.isNumber obj.length
      iterator.call context, obj[i], i, obj for i in [0...obj.length]
    else
      iterator.call context, val, key, obj  for own key, val of obj
  catch e
    throw e if e isnt breaker
  obj

# Allows you to iterate over all elements in an array or object and perform
# operations and get back an array of the modified results
#
#     changed = BFG.each([1,2,3], (item) -> item*5)
#     # changed == [5,10,15]
#
# This and `.each` both allow you to pass an explicit context to bind `this` to.
BFG.map = (obj, iterator, context) ->
  return obj.map(iterator, context) if nativeMap and obj.map is nativeMap
  results = []
  BFG.each obj, (value, index, list) ->
    results.push iterator.call context, value, index, list
  results


# Filter results based on an arbitrary test
#
#     # Even numbers only
#     BFG.filter [1,2,3,4,5,6], (item) -> (item % 2 == 0)
#     # returns [2,4,6]
#
BFG.filter = (obj, iterator, context) ->
  return obj.filter iterator, context if nativeFilter and obj.filter is nativeFilter
  results = []
  BFG.each obj, (value, index, list) ->
    results.push value if iterator.call context, value, index, list
  results

BFG.identity = (value) ->
  value

any = BFG.any = (obj, iterator, context) ->
  iterator || (iterator = BFG.identity)
  result = false

  return result if obj == null
  return obj.some(iterator, context) if (nativeSome && obj.some == nativeSome)
  BFG.each obj, (value, index, list) ->
    return breaker if (result || (result = iterator.call(context, value, index, list)))

  !!result

BFG.find = (obj, iterator, context) ->
  result = null
  any obj, (value, index, list) ->
    if (iterator.call(context, value, index, list))
      result = value
      return true

  result

# `.bind` acts like jquery's proxy helper, in which we can explicitly set the
# `this` in the bound context.
BFG.bind = (func, context) ->
  return nativeBind.apply(func, BFG.rest(arguments)) if nativeBind and func.bind is nativeBind
  args = BFG.rest arguments, 2
  -> func.apply context, args.concat(BFG.rest(args))

# `.bindAll` allows us to bind all methods of a given object to a context. You can either
# specify an object, or string keys for method names:
#
#     BFG.bindAll(anObject, 'one', 'two', 'three')
#     BFG.bindAll(anObject, anotherObject)
#
# The second example will bind all methods from `anotherObject` to
# the context of anObject
BFG.bindAll = (obj) ->
  funcs = if arguments.length > 1 then BFG.rest(arguments) else functions(obj)
  BFG.each funcs, (f) -> obj[f] = BFG.bind obj[f], obj
  obj

#### Private scope (not in the BFG namespace) ####

functions = (obj) ->
  BFG.filter(BFG.keys(obj), (key) -> BFG.isFunction(obj[key])).sort()

breaker = if typeof(StopIteration) is 'undefined' then '__break__' else StopIteration

FuncProto     = Function.prototype
ArrayProto    = Array.prototype
ObjProto      = Object.prototype

nativeBind    = FuncProto.bind
nativeIsArray = Array.isArray
slice         = ArrayProto.slice
nativeForEach = ArrayProto.forEach
nativeMap     = ArrayProto.map
nativeSome    = ArrayProto.some
nativeKeys    = Object.keys
toString      = ObjProto.toString
