# <[Collections](./overview.md)/[HashMap](../../src/Collections/HashMap.ahk)>

- [Overview](#overview)
- [Equality Checks and Hash Codes](#equality-checks-and-hash-codes)
- [Duck Types](#duck-types)

## Overview

A hash-based [IMap](../Interfaces/IMap.md) implementation.

```ahk
M := HashMap([1, 2], "str", { value: 42 }, 9)

MsgBox(M.Has([1, 2])) ; true
```

## Equality Checks and Hash Codes

To determine whether a key is present, a HashMap uses the key's
[hash code](../Base/Hash.md) to find the correct bucket, then compares the
key to the entries in that bucket via [`.Eq()`](../Base/Eq.md).

Therefore, the keys used in a HashMap must implement both `.Eq()` and
`.HashCode()`, and the two methods must be consistent with each other.
If two keys are considered equal by `.Eq()`, they must also have the same hash
code.

**Also See**:

- [<Base/Eq>](../Base/Eq.md)
- [<Base/Hash>](../Base/Hash.md)

## Duck Types

At the moment, HashMap cannot properly hold [duck types](../Base/DuckTypes.md)
because their instances don't necessarily inherit the proper `.HashCode()` or
`.Eq()` methods. This might change in later updates.
