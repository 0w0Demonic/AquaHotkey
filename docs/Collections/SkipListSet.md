# <[Collections](./overview.md)/[SkipListSet](../../src/Collections/SkipListSet.ahk)>

## Overview

An ordered implementation of [ISet](../Interfaces/ISet.md) that uses the keys
of a [SkipListMap](./SkipListMap.md) as its elements.

To support natural ordering between keys, they must implement
[`.Compare()`](../Base/Comparable.md). Otherwise, you can specify a custom
[comparator function](../Func/Comparator.md) by creating a subclass, or using
`SkipListSet.WithComparator()`.

```ahk
; option 1: subclass
class CustomSet extends SkipListSet {
    static Call(Values*) {
        static Cls := SkipListMap.WithComparator(...)
        return this.FromMap(Cls(Values*))
    }
}

; option 2: `SkipListSet.WithComparator()`
CustomSet := SkipListSet.WithComparator(...)
S := CustomSet(...)
```
