# <[Collections](./overview.md)/[ImmutableMap](../../src/Collections/ImmutableMap.ahk)>

- [Overview](#overview)

## Overview

An immutable [IMap](../Interfaces/IMap.md) implementation.

Use `ImmutableMap.FromMap()` or `IMap#Freeze()` to create a read-only view
of an existing map.

```ahk
IM := ImmutableMap(1, 2, 3, 4)
IM[5] := 6 ; Error!

; these two are the same:
IM := Map(1, 2, 3, 4).Freeze()
IM := ImmutableMap.FromMap(Map(1, 2, 3, 4))
```
