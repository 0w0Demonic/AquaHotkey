# <[Collections](./overview.md)/[WeakRefMap](../../src/Collections/WeakRefMap.ahk)>

- [\<Collections/WeakRefMap\>](#collectionsweakrefmap)
  - [Overview](#overview)

## Overview

An [IMap](../Interfaces/IMap.md) with *weak* keys. As opposed to other
collections, the presence of a key in this map won't prevent it from being
disposed if via `.__Delete()`, in which case the associated value is
automatically freed from the map.

```ahk
M := WeakRefMap()
O := Object()
M[O] := 42

; frees the object from the `Map`.
O := unset

MsgBox(M.Count) ; 0
```

Also see: [WeakRefSet](./WeakRefSet.md)
