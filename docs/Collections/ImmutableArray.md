# <[Collections](./overview.md)/[ImmutableArray](../../src/Collections/ImmutableArray.ahk)>

- [Overview](#overview)

## Overview

An immutable implementation of [IArray](../Interfaces/IArray.md).

```ahk
IA := ImmutableArray(1, 2, 3, 4)
IA.Push(5) ; Error!
```

To create a new immutable array, use `ImmutableArray(Values*)` or
`Tuple(Values*)`. Use `ImmutableArray.FromArray(A)` or `IArray#Freeze()` to
create a read-only view of an existing array.

```ahk
; same as: `T := ImmutableArray(1, 2)`
T := Tuple(1, 2)

; same as: `Frozen := ImmutableArray.FromArray(Array(1, 2, 3, 4))`
Frozen := Array(1, 2, 3, 4).Freeze()
```
