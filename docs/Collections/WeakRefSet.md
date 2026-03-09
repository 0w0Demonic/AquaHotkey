# <[Collections](./overview.md)/[WeakRefSet](../../src/Collections/WeakRefSet.ahk)>

- [\<Collections/WeakRefSet\>](#collectionsweakrefset)
  - [Overview](#overview)

## Overview

An [ISet](../Interfaces/ISet.md) wrapper over [WeakRefMap](./WeakRefMap.md).

```ahk
O := Object()
S := WeakRefSet(O)

MsgBox(S.Size) ; 1

; frees the object from the set
O := unset

MsgBox(S.Size) ; 0
```
