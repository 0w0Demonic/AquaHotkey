# <[Base](../../Base/overview.md)/[DuckTypes](../DuckTypes.md)/[Boolean](../../../src/Base/DuckTypes/Boolean.ahk)>

- [\<Base/DuckTypes/Boolean\>](#baseducktypesboolean)
  - [Overview](#overview)
  - [Convert to Boolean](#convert-to-boolean)
  - [Natural Ordering](#natural-ordering)
  - [JSON Serialization](#json-serialization)

## Overview

A Boolean is a [duck type](../DuckTypes.md) that represents the values `true` and `false` (`1` and `0`). The class `Boolean` is a subtype of `Integer`.

<!-- TODO link "subtype" to some file that explains definitions -->

```ahk
(true).Is(Boolean) ; ==> true
(false).Is(Boolean) ; ==> true

(0).Is(Boolean) ; ==> true
(1).Is(Boolean) ; ==> true

Integer[].CanCastFrom(Boolean[]) ; ==> true (`Integer.CanCastFrom(Boolean)`)
```

## Convert to Boolean

Call `Boolean(Value)` to convert any value into a boolean. This is equivalent to `!!Value`. `unset` is converted to `false`.

```ah
Boolean(false)     ; !!(false) --> false
Boolean("example") ; !!("example") --> true

Boolean(unset) ; --> false
```

## Natural Ordering

(see [natural ordering](../Comparable.md))

You can perform natural ordering on booleans by using `Boolean.Compare(A, B)`. `true` is considered greater than `false`, similar to `1 > 0`.

```ahk
([true, false, true, false]).Sort(Boolean.Compare)
; ==> [false, false, true, true]

([42, true]).Sort(Boolean.Compare)
; ==> TypeError! Expected a Boolean, but got an Integer.
```

## JSON Serialization

<!-- (see [JSON Serialization](...)) -->

Use `Boolean` as an argument in `.ParseJson(T)` to convert an instance of `Json.Boolean` into an AHK boolean.

```ahk
"true".ParseJson() ; ==> Json.True
"true".ParseJson(Boolean) => true (1)
```
