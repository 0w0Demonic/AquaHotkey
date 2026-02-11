# Collections - Overview

- [All Modules](../api-overview.md)

## List of Features

- [Generic](./Generic/overview.md)
  - [Array](./Generic/Array.md)
  - [Map](./Generic/Map.md)
- [Array](./Array.md)
- [Map](./Map.md)
- [HashMap](./HashMap.md)
- [HashSet](./HashSet.md)
- [ImmutableArray](./ImmutableArray.md)
- [ImmutableMap](./ImmutableMap.md)
- [ImmutableSet](./ImmutableSet.md)
- [LinkedList](./LinkedList.md)
- [SkipListMap](./SkipListMap.md)
- [SkipListSet](./SkipListSet.md)
- [Set](./Set.md)

## Summary

An assortment of collection types for storing groups of values. Together with
the [Interfaces](../Interfaces/overview.md) module, they form the basis for
data structures in AquaHotkeyX.

To indicate that a type should be treated as a Map - regardless of its base
object - it must implement the [IMap](../Interfaces/IMap.md) interface. The
same applies to arrays and sets with the [IArray](../Interfaces/IArray.md)
and [ISet](../Interfaces/ISet.md) interfaces, respectively.

This allows for flexible and extensible collection types that can be used
interchangeably in many contexts.

## Class Diagram

```ahk
Object
|- IArray
|  |- Array
|  |- GenericArray
|  |- ImmutableArray
|  `- LinkedList
|
|- IMap
|  |- Map
|  |- GenericMap
|  |- HashMap
|  |- ImmutableMap
|  `- SkipListMap
|
`- ISet
   |- Set
   |  `- HashSet
   |- ImmutableSet
   `- SkipListSet
```

## Generic Collections

- [GenericArray](./GenericArray.md)
- [GenericMap](./GenericMap.md)

Generic collection classes like `GenericArray` and `GenericMap` provide
type-safe wrappers around native collections. They enforce element types and
support nested generics, making it easy to work with collections of specific
types.

```ahk
Arr := Integer[](1, 2, 3) ; Generic array of integers
M := Map.OfType(String, Integer)("a", 1, "b", 2)

; works with duck types (see <Base/DuckTypes>)
ArrClass := Array.OfType({ name: String, age: Integer})
```

**See Also**:

- [Duck Types](../Base/DuckTypes.md)
- [IArray](../Interfaces/IArray.md)
- [IMap](../Interfaces/IMap.md)

## Hash-Based Collections

- [HashMap](./HashMap.md)
- [HashSet](./HashSet.md)

Hash table-based collections with extremely flexible key/value semantics.
They rely on [<Base/Hash>](../Base/Hash.md) and [<Base/Eq>](../Base/Eq.md)
to determine value presence.

```ahk
Arr1 := [1, 2, 3]
Arr2 := [1, 2, 3]

S := HashSet(Arr1, Arr2)
MsgBox(S.Size) ; 1 (because `Arr1` and `Arr2` are equivalent)
```

**See Also**:

- [IMap](../Interfaces/IMap.md)
- [ISet](../Interfaces/ISet.md)

## Immutable Collections

- [ImmutableArray](./ImmutableArray.md)
- [ImmutableMap](./ImmutableMap.md)
- [ImmutableSet](./ImmutableSet.md)

Immutable collections wrap around existing collections like arrays, maps and
sets to prevent modification after creation.

**Create Immutable Collections Directly**:

```ahk
; create immutable collections directly
I := ImmutableArray(1, 2, 3, 4)
I := Tuple(1, 2, 3, 4) ; same as ImmutableArray(...)
```

**Wrap Around Existing Collections**:

```ahk
M := Map(1, 2, 3, 4).Freeze()
M.Set(5, 6) ; Error!
```

**Works on any Implementing Type**:

```ahk
L := LinkedList(...).Freeze() ; because `LinkedList extends IArray`
```

**See Also**:

- [Interfaces](../Interfaces/overview.md)

## SkipListMap and SkipListSet

- [<Collections/SkipListMap>](./SkipListMap.md)
- [<Collections/SkipListSet>](./SkipListSet.md)

Probabilistic and ordered maps and sets using skip lists. Relies on `<Base/Eq>`
and `<Base/Ord>` to determine value presence and to order its elements.

Note: Go ahead and check them out, these are really interesting... I promise.

```ahk
SkipListSet(23, 12, 44, 2).Join(", ").MsgBox() ; "2, 12, 23, 44"
```

**See Also**:

- [<Base/Eq>](../Base/Eq.md)
- [<Base/Hash>](../Base/Hash.md)

## Stream-Like Operations

- [<Collections/Array>](./Array.md)
- [<Collections/Map>](./Map.md)

Extended `Array` and `Map` methods including mostly functional operations,
such as filtering, mapping, and transformations.

```ahk
Even(x) => !(x & 1)
Times(x) => (y) => (x * y)

Array(1, 2, 3, 4).RetainIf(Even).Map(Times(2)) ; [2, 4]
```

## Other Collections

- [<Collections/LinkedList>](./LinkedList.md)
- [<Collections/Set>](./Set.md)

**LinkedList**:

Doubly-linked list implementation for efficient insertion/deletion at
arbitrary positions. Supports generic typing via `LinkedList.OfType()`.

```ahk
L := LinkedList(1, 2, 3, 4) ; 1 <> 2 <> 3 <> 4

L.Push(5) ; insert as last element
L.Shove(0) ; insert as first element

MsgBox(L.Pop()) ; remove last element
MsgBox(L.Poll()) ; remove first element

L.Join(", ").MsgBox() ; "1, 2, 3, 4"

; cool stuff with `<Stream/Stream>`
; 
L.Drain().RetainIf(Even).Join(", ") ; "4, 2"
MsgBox(L.Length) ; 0 (we "drained" the list from the back)
```

**Set**:

Basic [ISet](../Interfaces/ISet.md) view of an [IMap](../Interfaces/IMap.md)
for storing unique values and performing set operations.

```ahk
M := HashMap(1, 2, 3, 4)
S := M.AsSet() ; view of keys

MsgBox(S.Contains(1)) ; true
MsgBox(S.Contains(2)) ; false
```
