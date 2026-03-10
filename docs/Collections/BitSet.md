# <[Collections](./overview.md)/[BitSet](../../src/Collections/BitSet.ahk)>

- [\<Collections/BitSet\>](#collectionsbitset)
  - [Overview](#overview)

## Overview

An implementation of [ISet](../Interfaces/ISet.md) which views a buffer or
buffer-like object as a set of 1-bits in a bit vector, where each component
of the bit set has a boolean value.

The bits of the bit set are indexed by nonnegative integers, starting with `0`.

```ahk
S := BitSet(0, 1, 2, 3, 4, 5) ; uses a `Buffer(1)` as backing storage
```
