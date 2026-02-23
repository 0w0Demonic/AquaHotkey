# <[Interfaces](./overview.md)/[ISet](../../src/Interfaces/ISet.ahk)>

- [\<Interfaces/ISet\>](#interfacesiset)
  - [Overview](#overview)
  - [Set Param](#set-param)
  - [Map to Set](#map-to-set)
  - [Properties and Methods](#properties-and-methods)
    - [`.Add(Values: Any*) => Integer`](#addvalues-any--integer)
    - [`.Clear() => void`](#clear--void)
    - [`Clone() => ISet`](#clone--iset)
    - [`Delete(Values: Any*) => Integer`](#deletevalues-any--integer)
    - [`Contains(Value: Any) => Boolean`](#containsvalue-any--boolean)
    - [`__Enum() => Enumerator`](#__enum--enumerator)
    - [`Size => Integer`](#size--integer)
  - [Default Methods](#default-methods)

## Overview

ISet represents the base class for sets, which are collections of unique
elements.

## Set Param

Methods such as `.Distinct()` defined in [`Enumerable1`](./Enumerable1.md)
accept an optional *set param* to specify the set that should be used
internally. This is done by calling `ISet.Create()`, which constructs
instances of `ISet` based on a parameter, which may be one of the following:

- an existing set returned as-is;
- a callable object that produces a set;
- the case-sensitivity of a newly created set.

```ahk
ISet.Create(S := Set()) ; S
ISet.Create(HashSet)    ; HashSet()
ISet.Create(false)      ; (S := Set(), S.CaseSense := false, S)
```

`ISet.Create()` guarantees that the return value is
[instance of](../Base/DuckTypes.md) the calling class.

```ahk
HashSet.Create(Set()) ; TypeError! Expected a(n) HashMap.
```

## Map to Set

To convert an [IMap](./IMap.md) into an ISet, use `.AsSet()` or `.ToSet()`.
`.AsSet()` returns a mutable view of the map, whereas `.ToSet()` creates a
set of the map's entries at the current moment.

```ahk
M := Map(1, true, 2, true)

S1 := M.AsSet()
S2 := M.ToSet()

M.Set(3, true)

MsgBox(S1.Contains(3)) ; true
MsgBox(S2.Contains(3)) ; false
```

## Properties and Methods

```ahk
ISet.Prototype
|- Add()
|- Clear()
|- Clone()
|- Delete()
|- Contains()
|- __Enum()
`- Size
```

### `.Add(Values: Any*) => Integer`

Adds one of more values to the set.

This method returns the amount of new elements that were added to the set.

```ahk
S := Set()
MsgBox("added " . S.Add(1, 2, 3) . " elements to the set")
```

### `.Clear() => void`

Clears the set.

```ahk
S := Set(1, 2, 3)
S.Clear()

MsgBox(S.Size) ; 0
```

### `Clone() => ISet`

Clones the set (shallow copy).

### `Delete(Values: Any*) => Integer`

Deletes values from the set. This method returns the amount of elements that
were removed from the set.

```ahk
S := Set(1, 2, 3)

; "removed 2 elements"
MsgBox("removed " . S.Delete(1, 2, 4) . " elements")
```

### `Contains(Value: Any) => Boolean`

Determines whether the given value is present in the set.

```ahk
S := Set(1, 2, 3)

S.Contains(1)  ; true
S.Contains(42) ; false
```

### `__Enum() => Enumerator`

Returns an enumerator for the set, allowing the use of for-loops. Only
1-parameter is supported.

```ahk
for Value in Set(1, 1, 1, 2, 2, 3) {
    MsgBox(Value) ; 1, 2, 3
}
```

### `Size => Integer`

Retrieves the size of the set.

```ahk
Set(1, 2, 3).Size ; 3
```

## Default Methods

Use `.ContainsAll()`, `.ContainsAny()` or `.ContainsNone()` to check whether
the set contains all, any, or none of the given values, respectively.

```ahk
S := Set(1, 2, 3)
S.ContainsAll(1, 2) ; true
S.ContainsAny(2, 42) ; true
S.ContainsNone(42, 43) ; true
```

You can use `.__Item[Value]` as shorthand for `.Contains(Value)`.

```ahk
S := Set(1, 2, 3)
S[2] ; true
S[42] ; false
```
