# Module `<Stream>`

- [All Modules](../api-overview.md)

## List of Features

- [BaseStream](./BaseStream.md)
- [DoubleStream](./DoubleStream.md)
- [Gatherer](./Gatherer.md)
- [Range](./Range.md)
- [Stream](./Stream.md)
- [Zip](./Zip.md)

## Summary

Streams are a powerful abstraction for working with sequences of data.
It consists of different "stages" (such as `.Map()`, `.RetainIf()` and
`.ForEach()`) that each "grabs" their elements from the previous stage, and
transform elements using function application.

```ahk
Times(A) => (B) => (A * B)

; --> <6, 8>
Array(1, 2, 3, 4).Stream()
        .Map(Times(2))   ; stage 1: Map
        .RetainIf(Gt(5)) ; stage 2: Filter
```

**Also See**:

- [Streams in Java](https://stackify.com/streams-guide-java-8/)
- [Enumerable1](../Interfaces/Enumerable1.md)
- [Enumerable2](../Interfaces/Enumerable2.md)

## Class Diagram

```ahk
Enumerator
`- BaseStream
   |- Stream (Enumerable1, Enumerable2)
   `- DoubleStream (Enumerable2)
```

## BaseStream

- [<Stream/BaseStream>](./BaseStream.md)

The base class of all streams. Implementing an own stream type requires you to
specify a `Size` property which determines how many parameters are used
simultaneously.

This class should not be used directly, but rather through its base classes
like [Stream](./Stream.md) and [DoubleStream](./DoubleStream.md).

## DoubleStream

- [<Stream/DoubleStream>](./DoubleStream.md)

A [Stream](./Stream.md) of size 2.

To create one, use `.DoubleStream()` on any enumerable object.

```ahk
M := Map("key1", "value1", "key2", "value2")

; --> DoubleStream <("key1", "value1"), ("key2", "value2")>
DS := M.DoubleStream()
```

Alternatively, you can [Zip()](./Zip.md) two different enumerable objects into
one:

```ahk
; --> DoubleStream <(1, 3), (2, 4), ("foo", "bar")>
DS := Zip([1, 2, "foo"], [3, 4, "bar"])
```

DoubleStream does *not* implement `Enumerable1`.

## Gatherer

- [<Stream/Gatherer>](./Gatherer.md)

Gatherers are a special type of intermediate operations that are used to
"gather" elements from a stream into another stream.

```ahk
; <[1, 2, 3], [2, 3, 4], [3, 4, 5]>
Range(5).Gather(WindowSliding(3))

; custom stream gatherer
TimesTwo(Upstream, Downstream) {
    if (!Upstream(&Value)) {
        return false ; terminate stream
    }
    Downstream(Value?, Value?) ; push value into output stream twice
    return true ; success
}
```

## Range

- [<Stream/Range>](./Range.md)

An arithmetic progression of numbers.

```ahk
for Value in Range(1, 10, 2) {
    ... ; 1, 3, 5, 7, 9
}
```

Even though ranges can be used basically anywhere, the `Range()` function
returns a [Stream](./Stream.md) of numbers.

```ahk
; Map { true: [2, 4, ..., 100], false, [1, 3, ..., 99]}
Range(100).Partition(Even)
```

## Stream

- [<Stream/Stream>](./Stream.md)

Streams are a powerful abstraction for processing sequences of data.

```ahk
Arr := Array(1, 2, 3, 4, 5, 6)

Arr.Stream()       ; <1, 2, 3, 4, 5, 6>
   .RetainIf(Even) ; <2, 4, 6>
   .Reduce(Sum)    ; 12
```

They work on anything that is enumerable. In AquaHotkeyX, that's also files
and strings.

```ahk
; <"line 1", "line 2", "...">
FileOpen("myFile.txt", "r").Stream()

; <"H", "e", "l", "l", "o">
"Hello".Stream()
```

Because they operate lazily, streams can be infinite in size.

```ahk
Increment(x) => (x + 1)

Stream.Iterate(0, Increment) ; <1, 2, 3, 4, ...> (infinite stream of numbers)
      .Limit(10) ; <1, 2, 3, ..., 10> (limit to 10 elements)
      .Sum() ; add all numbers together

; -> 55 (1 + 2 + ... + 10)
```

## Zip

- [<Stream/Zip>](./Zip.md)

This introduces the two functions `Zip()` and `ZipWith()`.

`Zip()` lets you "zip" two enumerable values into a
[DoubleStream](./DoubleStream.md).

```ahk
; DoubleStream <(1, 4), (2, 5), (3, 6)>
Zip([1, 2, 3], [4, 5, 6])
```

`.ZipWith()` does the same, but it returns a regular [Stream](./Stream.md),
where elements on both sides are merged by using the given mapper function.

```ahk
Sum(A, B) => (A + B)

; Stream <5, 7, 9>
ZipWith(Sum, [1, 2, 3], [4, 5, 6])
```
