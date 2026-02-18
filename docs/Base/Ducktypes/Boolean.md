# <[Base](../../Base/overview.md)/[DuckTypes](../DuckTypes.md)/[Boolean](../../../src/Base/DuckTypes/Boolean.ahk)>

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
