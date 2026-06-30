# <[Collections](./overview.md)/[OrderedMap](../../src/Collections/OrderedSet.ahk)>

- [\<Collections/OrderedMap\>](#collectionsorderedmap)
  - [Overview](#overview)

## Overview

An [ISet](../Interfaces/ISet.md) that maintains insertion order.

On top of the regular ISet interface, you can add elements in the back of the set by using `.Push()`, and in the front of the set by using `.Shove()`.

Use `ISet#Ordered()` to turn any regular set into its ordered version.

```ahk
OS := Set(1, 2, 3, 4).Ordered()

OS.Push(5)
OS.Shove(0)

; "0, 1, 2, 3, 4, 5"
OS.Stream().Join(", ").MsgBox()
```
