# <[Interfaces](./overview.md)/[IMap](../../src/Interfaces/IMap.ahk)>

- [\<Interfaces/IMap\>](#interfacesimap)
  - [Overview](#overview)
  - [Construction](#construction)
  - [Map Param](#map-param)
  - [Duck Type](#duck-type)
  - [Default Methods](#default-methods)
  - [Methods `.TryGet()` and `.TryDelete()`](#methods-tryget-and-trydelete)
  - [Stream Operations](#stream-operations)

## Overview

The base class of map classes. Implementing classes include Map,
[ImmutableMap](../Collections/ImmutableMap.md),
[GenericMap](../Collections/Generic/Map.md),
[HashMap](../Collections/HashMap.md), and
[SkipListMap](../Collections/SkipListMap.md).

Extending `IMap` gives you a skeletal implementation with many useful
default methods.

## Construction

Use `IMap#BasedFrom(M)` to create a copy of an existing `IMap` without copying
its elements. This is useful for stream-like operations where you want to
keep the same base object as previously.

## Map Param

Some methods like `.Frequency()` defined in [`Enumerable1`](./Enumerable1.md)
accept a *map param*, which represents the `IMap` that should be used
internally.

This is done by `IMap.Create()`, which constructs instances of `IMap` based on
a parameter, which may be one of the following:

- an existing map returned as-is;
- a callable object that produces a map;
- the case-sensitivity for a newly created map.

```ahk
IMap.Create(M := HashMap()) ; --> M
IMap.Create(SkipListMap)    ; --> SkipListMap()
IMap.Create(false)          ; --> (M := Map(), M.CaseSense := false, M)
```

`IMap.Create()` guaranteed that the returned map is
[instance of](../Base/DuckTypes.md) the calling class.

```ahk
M := Map()
HashMap.Create(M) ; Error! Expected a(n) HashMap.
```

## Duck Type

Any object that implements a subset of all Map methods can match the
[duck type](../Base/DuckTypes.md) imposed by `IMap`.

```ahk
Obj := {
    Clear: ...
    Delete: ...
    ...
}

Obj.Is(IMap) ; true
```

The following properties are required:

- `Clear()`
- `Delete()`
- `Get()`
- `Has()`
- `Set()`
- `__Enum()`
- `Count`
- `__Item[]`

However, it makes more sense to just extend `IMap`.

## Default Methods

IMap introduces a few default methods based on [`java.util.Map`](https://docs.oracle.com/en/java/javase/24/docs/api/java.base/java/util/Map.html):

```ahk
M := Map()
M.PutIfAbsent("foo", "bar")
```

As opposed to Java's implementation, there are no return values specified for
these methods because `unset` cannot be used as return value. This
might change in the future, using an [Optional](../Monads/Optional.md) or
something similar.

## Methods `.TryGet()` and `.TryDelete()`

Variations of `.Get()` and `.Delete()` that return a boolean indicating success
instead of throwing an error. The value is returned via an output parameter.

```ahk
if (M.TryGet("foo", &Value)) {
    ; use Value
}
```

## Stream Operations

IMap also provides a few stream-like operations like mapping and filtering:

```ahk
; return a new Map with only the entries that satisfy the predicate
M.RetainIf((K, V) {
    ; ...
})
```

For more information, see [<Stream/Stream>](../Stream/Stream.md).
