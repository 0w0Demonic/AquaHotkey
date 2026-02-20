# <[Interfaces](./overview.md)/[IArray](../../src/Interfaces/IArray.ahk)>

## Overview

The base class for any array-like class. This includes `Array`,
[`LinkedList`](../Collections/LinkedList.md) and
[`ImmutableArray`](../Collections/ImmutableArray.md).

Extending `IArray` gives you a skeletal implementation with many useful
default methods.

## Duck Typing

`IArray` can be used as a [duck type](../Base/DuckTypes.md). Any object
that implements all of the array properties (except `.__New()` and
`.Default`) will be considered instance of `IArray`.

## Construction

To create a copy of an existing `IArray` object without copying elements, use
`IArray.BasedFrom(Arr)`. Useful for stream-like operations where you want to
keep the same base object as previously, but don't clone any elements.

## Default Operations

Default operations of IArray include...

- **Binary Search**

  ```ahk
  Arr(1, 1, 3, 3, 3, 5, 5, 5, 5, 6, 7, 8, 9)
  Arr.BinarySearch(7) ; 11
  ```

- **Clearing the Array**:

  ```ahk
  Arr.Clear()
  ```

- **Repeats**:

  ```ahk
  [ [3].Repeat(3) ].Repeat(3) ; [[3, 3, 3], [3, 3, 3], [3, 3, 3]]
  ```

- **Distinct Elements**:

  ```ahk
  ; --> [{ Value: 1}, { Value: 2 }]    (also see <Collections/HashSet>)
  ; 
  Arr := Array({ Value: 1 }, { Value: 1 }, { Value: 2 }).Distinct(, HashSet)
  ```

- **Filling**:

  ```ahk
  Arr := Array()
  Arr.Length := 10

  ; fill with concrete value
  ; --> [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
  Arr.Fill(2)                 

  ; fill with generator function
  ; --> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  Arr.FillWith(() => A_Index)
  ```

- **Swap, Shuffle, Reverse**:

  ```ahk
  Arr := Array(1, 2, 3, 4, 5)

  Arr.Swap(2, 4) ; --> [1, 4, 3, 2, 5]
  Arr.Reverse()  ; --> [5, 2, 3, 4, 1]

  Arr.Shuffle()  ; --> [5, 3, 4, 1, 2]    (random)
  ```

- **Slicing**:

  ```ahk
  A := Array(1, 2, 3, 4, 5)
  A.Slice(3)                  ; --> [3, 4, 5]
  A.Slice(1, 4)               ; --> [1, 2, 3, 4]
  A.Slice(1, 5, 2)
  ```

- **Sorting**:

  ```ahk
  ; also see: <Func/Comparator>
  ; 
  Array(1, 4, 2, 3, 5).Sort() ; --> [1, 2, 3, 4, 5]
  ```

### Deque Methods

- **Remove First Element**:

  ```ahk
  Arr := Array(1, 2, 3, 4)
  Arr.Poll()       ; 1
  Arr.Join(", ")   ; "2, 3, 4"
  ```

- **`.Slurp()` and `.Drain()`**:

  Creates a stream of elements being repeatedly `.Pop()`-ed and `.Poll()`-ed
  from the array, respectively.

  ```ahk
  A := Array(1, 2, 3)
  A.Drain().Join(", ") ; "3, 2, 1"
  A.ToString()    ; "[]"
  ```

### Filtering & Mapping

IArray offers you a variety of stream-like methods. For more information, see
[<Stream/Stream>](../Stream/Stream.md).

```ahk
Even(x) => !(x & 1)

Range(10).ToArray(LinkedList).RetainIf(Even) ; LinkedList(2, 4, 6, 8, 10)
```
