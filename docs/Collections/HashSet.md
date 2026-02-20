# <[Collections](./overview.md)/[HashMap](../../src/Collections/HashSet.ahk)>

- [Overview](#overview)

## Overview

A hash-based [ISet](../Interfaces/ISet.md) implementation. It uses a
[HashMap](./HashMap.md) as backing map to store elements.

```ahk
S := HashSet([1, 2], 42, [1, 2], "str")

MsgBox(S.Count) ; 3
```
