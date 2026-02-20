# <[Func](./overview.md)/[Lazy](../../src/Func/Lazy.ahk)>

- [Overview](#overview)

## Overview

A zero-parameter function whose value is computed once by retrieving a value
from a [supplier function](./Supplier.md), and then internally caching its
result.

```ahk
class Lazy extends Func {}
```

They're useful especially for delaying the construction of objects until the
first time they're actually used, or saving the result of pure functions.

```ahk
Dice := Lazy(Random, 1, 6)
TimesTwo := Dice.Map(x => (x * 2))

Dice() ; 3 (randomly generated)
Dice() ; 3 (cached)
```
