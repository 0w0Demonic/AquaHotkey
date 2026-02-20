# <[Collections](./overview.md)/[ImmutableSet](../../src/Collections/ImmutableSet.ahk)>

- [Overview](#overview)

## Overview

An immutable [ISet](../Interfaces/ISet.md) implementation.

```ahk
S := ImmutableSet(1, 2, 3, 4)
```

Use `ImmutableSet.FromSet()` or `ISet#Freeze()` to create a read-only view
of an existing set. To return a set view of an [IMap](../Interfaces/IMap.md),
you can use `IMap#AsSet()` or `IMap#ToSet()`.

```ahk
S := Set(1, 2, 3, 4)
Frozen := ImmutableSet.FromSet(S) ; same as: `Frozen := S.Freeze()`

; use `.ToSet()` instead of `.AsSet()` to create an immutable snapshot view
S := Map(1, true, 2, true).AsSet(ImmutableSet)
```
