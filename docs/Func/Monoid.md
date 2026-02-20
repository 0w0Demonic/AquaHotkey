# <[Func](./overview.md)/[Monoid](../../src/Func/Monoid.ahk)>

## Overview

Monoids are binary operations with an identity (for example, addition).
They are useful for [`.Reduce()`](../Interfaces/Enumerable1.md#reduction)
to provide a default starting value.

```ahk
class Monoid extends Func {}
```

Basic monoids like addition and multiplication are provided in this feature
as `Sum` and `Product` respectively.

```ahk
Product(A, B) => (A + B)
Product.Identity := 0

Array(1, 2, 3, 4).Reduce(Product) ; 24
Array().Reduce(Product)           ; 1 (fallback to default value)
```

`Monoid` is implemented as [duck type](../Base/DuckTypes.md). It can be any
callable object with `Identity` property.

```ahk
class Sum extends Any {
    static Call(A, B) => (A + B)
    static Identity => 0
}

class Concat extends Any {
    static Call(A, B) => (A . B)
    static Identity => ""
}

Array(1, 2, 3, 4).Reduce(Sum) ; 10
Array().Reduce(Sum) ; 0

Array("f, "o", "o").Reduce(Concat) ; "foo"
Array().Reduce(Concat) ; ""
```
