# <[Stream](./overview.md)/[DoubleStream](../../src/Stream/DoubleStream.ahk)>

- [\<Stream/DoubleStream\>](#streamdoublestream)
  - [Overview](#overview)
  - [Construction](#construction)

## Overview

Represents a [stream](./Stream.md) of size two, such as a stream of key-value
pairs. It implements [Enumerable2](../Interfaces/Enumerable2.md) and all of its
methods work as specified in that interface. It implements the same methods
as [Stream](./Stream.md), but the functions passed to these methods take two
parameters instead of one.

Operations such as `.Map()` will convert a `DoubleStream` into a regular
`Stream`, since the two values are narrowed down to one.

```ahk
Array("foo", "bar")
        .DoubleStream()              ; --> <(1, "foo"), (2, "bar")>
        .Map(Format.Bind("#{}: {}")) ; --> <"#1: foo", "#2: bar">
```

For method `.Distinct()`, the key extractor used to retrieve a key for each
element is mandatory.

```ahk
; <{ x: 23 }, { x: 35 }>
Array({ x: 23 }, { x: 35 }, { x: 23 })
        .DoubleStream()
        .Distinct((Index, Obj) => Obj.X)
```

## Construction

Use `.DoubleStream()` to create a `DoubleStream` from any object that implements 
[Enumerable2](../Interfaces/Enumerable2.md).

Alternatively, use one of the static methods on `DoubleStream`, or
[`Zip()`](./Zip.md) to create a `DoubleStream` from two separate enumerables.

```ahk
; --> <(1, "a"), (2, "b"), (3, "c")>
Zip([1, 2, 3], ["a", "b", "c"])

; --> <(0, 10), (1, 11), ..., (20, 30)>
Zip(Range(0, 10), Range(10, 20))
```