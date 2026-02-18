# <[Collections](./overview.md)/[Set](../../src/Collections/Set.ahk)>

## Overview

An implementation of [ISet](../Interfaces/ISet.md) that uses the keys of
an [IMap](../Interfaces/IMap.md) as its elements.

## Create

Use `Set(Values*)` to create a new set. This will create a set which uses a
regular Map as its backing map.

```ahk
; backing map: Map { 1: true, 2: true, 3: true }
S := Set(1, 2, 3)
```

To specify a different map implementation, use `Set.FromMap(Map)`. This is
also the way how [HashSet](./HashSet.md) is implemented.

```ahk
; backing map: HashMap { 1: true, 2: true, [1, 2]: true }
S := HashSet(1, 2, [1, 2])
```

## Map to Set

To create a set view of an existing map, use `IMap#AsSet()` or `IMap#ToSet()`.
The former creates a live view of the map, while the latter creates a snapshot
of the map's keys at the time of the call. `.ToSet()` assumes that the map
can be cloned by calling `.Clone()`

```ahk
M := Map(1, true, 2, true)

S1 := M.AsSet() ; mutable view
S2 := M.ToSet() ; snapshot

M[3] := true
S1.Has(3) ; true
S2.Has(3) ; false
```

## Set to Map

The same logic applies when converting sets into maps. Use `ISet.AsMap()` or
`ISet#ToMap()` to create either a live view of the set, or a snapshot of the
current elements. To support `.ToMap()`, the backing map must be cloneable.

```ahk
S := Set(1, 2)

M1 := S.AsMap() ; mutable view
M2 := S.ToMap() ; snapshot

S.Add(3)
M1.Has(3) ; true
M2.Has(3) ; false
```
