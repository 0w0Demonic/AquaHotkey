# <[Collections](./overview)/[SkipListMap](../../src/Collections/SkipListMap.ahk)>

- [Overview](#overview)
- [Some Short Technical Insight](#some-short-technical-insight)
- [Methods `.TryGet()` and `.TryDelete()`](#methods-tryget-and-trydelete)

## Overview

An ordered map implementation based on a
[skip list data structure](https://en.wikipedia.org/wiki/Skip_list).

Key-value pairs are stored in sorted order based on the natural ordering of
keys, or alternatively, a custom [Comparator](../Func/Comparator.md).

In order to support natural ordering

```ahk
; natural ordering
; 
; --> ["bar", "foo"] (sorted by `String#Compare()`) 
SkipListMap("foo", 42, "bar", 12).Keys

; custom comparator
; 
MapCls := SkipListMap.WithComparator( Comparator.Num(StrLen).ThenAlpha() )
MapCls("aa", 1, "b", 2, "a", 3).Keys ; --> ["a", "b", "aa"] (sorted by `Comp`)
```

## Some Short Technical Insight

A skip list is a probabilistic data structure that consists of multiple layers
of linked lists. The bottom layer contains all the elements in sorted order,
while each higher layer contains a subset of the elements, providing "express
lanes" for faster traversal.

```ahk
SL := SkipListMap(1, "a", 2, "b", 3, "c", ..., 9, "i")

L |                                                 |
e |                                                 |
v | ----------------> o --------------------------> |
e | -> o -----------> o --------------------------> |
l | -> o ------> o -> o ----------------> o ------> |
s | -> o ------> o -> o -> o -----------> o -> o -> |
  | -> o -> o -> o -> o -> o -> o -> o -> o -> o -> |
Head   1    2    3    4    5    6    7    8    9   Null
      "a"  "b"  "c"  "d"  "e"  "f"  "g"  "h"  "i"
```

When searching for a key, the algorithm starts at the top layer and moves
downwards, skipping over large sections of the list at each step, resulting
in an average time complexity of `O(log n)` for search, insertion, and
deletion operations.

```ahk
Sl.Get(9) ; --> "i"

L |                                                 |
e |                                                 |
v | ----------------> o                             |
e |                   o                             |
l |                   o ----------------> o         |
s |                                       o -> o    |
  |                                            o    |
Head   1    2    3    4    5    6    7    8    9   Null
      "a"  "b"  "c"  "d"  "e"  "f"  "g"  "h"  "i"
```

## Methods `.TryGet()` and `.TryDelete()`

For the sake of performance, you should use `.TryGet()` instead of manually
checking `.Has()` and then calling `.Get()`. The same applies to `.TryDelete()`
vs. `.Has()` + `.Delete()`.

```ahk
M := SkipListMap("a", 1, "b", 2)
if (M.TryGet("a", &Value)) {
    MsgBox(Value) ; 1
}
if (M.TryDelete("b", &Value)) {
    MsgBox(Value) ; 2
}
```
