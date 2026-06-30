# <[Collections](./overview.md)/[OrderedMap](../../src/Collections/OrderedMap.ahk)>

- [\<Collections/OrderedMap\>](#collectionsorderedmap)
  - [Overview](#overview)

## Overview

An [IMap](../Interfaces/IMap.md) backed with a doubly-linked list to preserve insertion order. Use `.Push(Values*)` to add elements in the back of the list.  Use `.Shove(Values*)` to add elements in the front of the list.

Use `IMap#Ordered()` to turn any regular map into its ordered version.

```ahk
M := OrderedMap(1, 2, 3, 4)

; same as:
M := Map(1, 2, 3, 4).Ordered()

M.Shove(-1, 0)
M.Push(5, 6)

for Key, Value in M {
    MsgBox(Key . ": " . Value)
}

; --> -1: 0
; -->  1: 2
; -->  3: 4
; -->  5: 6
```
