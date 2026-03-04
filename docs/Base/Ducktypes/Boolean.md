# <[Base](../../Base/overview.md)/[DuckTypes](../DuckTypes.md)/[Boolean](../../../src/Base/DuckTypes/Boolean.ahk)>

- [\<Base/DuckTypes/Boolean\>](#baseducktypesboolean)
  - [Overview](#overview)
  - [Value Conversion](#value-conversion)

## Overview

A [duck type](../DuckTypes.md) that represents the boolean values `true`/`1`
and `false`/`0`.

Only integer values `1` and `0` are treated as booleans, not floats or numeric
strings.

`Boolean` is considered a subtype of `Integer`.

```ahk
(true).Is(Boolean) ; true
(false).Is(Boolean) ; true

(0).Is(Boolean) ; true
(1).Is(Boolean) ; true

Integer[].CanCastFrom(Boolean[]) ; because `Integer.CanCastFrom(Boolean)`
```

## Value Conversion

Call `Boolean(Value)` to convert any value into a boolean. This is equivalent
to `!!Value`. `unset` is converted to `false`.

```ah
Boolean(false)     ; !!(false) --> false
Boolean("example") ; !!("example") --> true

Boolean(unset) ; --> false
```
