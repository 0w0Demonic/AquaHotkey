# <[Interfaces](./overview.md)/[Enumerable2](../../src/Interfaces/Enumerable2.ahk)>

- [Overview](#overview)

## Overview

`Enumerable2` is the base interface for all things that are enumerable with
exactly two parameters, such as maps. In general, methods work exactly as
specified in `Enumerable1`, except that their names end with `2` and they
take an additional parameter for the key.

```ahk
Array.ForEach2(  (Index, Value) => MsgBox(Index . ": " . Value)  )
```

Note that the functions passed to these methods are able to access `A_Index`.

`Enumerable2` also defines a "strict" version of itself (`Enumerable2.Strict`),
in which methods are not suffixed with `2` because the implementing class
*only* implements the two-parameter version of the method. This is the case
for [DoubleStream](../Stream/DoubleStream.md).

```ahk
Array(42, "foo").DoubleStream().Map((K, V) {
    ... ; `.Map()` implies `.Map2()`
})
```

In addition, `.ToMap()` lets you collect all elements into an
[IMap](../Interfaces/IMap.md).

```ahk
; --> Map { "a" => 1, "b" => 2 }

Map(1, "a", 2, "b").ToMap(
    (K, V) => V, ; key mapper
    (K, V) => K  ; value mapper
)
```

**Also See**:

- [<Interfaces/Enumerable1>](./Enumerable1.md)
