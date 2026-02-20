# <[Base](./overview.md)/[Hash](../../src/Base/Hash.ahk)>

- [Overview](#overview)
- [How to Implement](#how-to-implement)
- [Static `.Hash()` Method](#static-hash-method)
- [Duck Types](#duck-types)

## Overview

Implements a universal `.HashCode()` method for generating stable,
well-distributed hash codes for use in hash-based collections like
[HashMap](../Collections/HashMap.md) and [HashSet](../Collections/HashSet.md).

```ahk
; -7236171085846062470
({ foo: "bar" }).HashCode()
```

## How to Implement

To determine whether a value is present, a HashMap uses the value's hash code
to find the correct bucket, then compares the value to the entries in that
bucket via [`.Eq()`](./Eq.md).

Therefore, `.HashCode()` must be consistent with its equality definition
`.Eq()`. If two values are considered equal by `.Eq()`, they must have the
same hash code.

In addition, the `.HashCode()` method must consistently return the same result,
as long as no information used in `.Eq()` is changed.

If any of the information is considered "absent", or has an `unset` value,
the hash code of that information must be equal to `0`.

Here's a simple example of how to implement `.HashCode()` for a simple `Point`
type:

```ahk
class Point {
    __New(X, Y) {
        this.X := X
        this.Y := Y
    }

    HashCode() => (this.x * 31) + this.y
}
```

## Static `.Hash()` Method

By using `T.Hash(Values*)`, you can create a hash code from zero or multiple
values of type `T`. You should generally use this method instead of creating
a hash code manually.

Now let's rewrite the `.HashCode()` method for our `Point` class:

```ahk
class Point {
    __New(X, Y) {
        this.X := X
        this.Y := Y
    }

    ; both `this.X` and `this.Y` are assured to be instance of `Integer`
    HashCode() => Integer.Hash(this.X, this.Y)
}
```

## Duck Types

Although [duck types](./DuckTypes.md) usually don't inherit any `.HashCode()`
methods, you can still specify a `static Hash()` method for the class.

Note: at the moment, `HashMap` and `HashSet` are incapable of holding duck
types properly, but this might change in the near future.
