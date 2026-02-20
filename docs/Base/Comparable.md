# <[Base](./overview.md)/[Compare](../../src/Base/Compare.ahk)>

- [Overview](#overview)
- [Implementing `.Compare()`](#implementing-compare)
- [Static `.Compare()` Method](#static-compare-method)
- [Comparator Functions](#comparator-functions)

## Overview

An interface for imposing natural order between values of the same type.
This is useful for sorting arrays and other collections.

```ahk
Arr := ["pear", "banana", "apple", "dragonfruit"]
Arr.Sort() ; --> ["apple", "banana", "dragonfruit", "pear"]
```

To determine the order between two values, the `.Compare()` method is
used.

Any type that defines `.Compare()` is considered *comparable*, which grants the
following advantages:

- arrays are sortable without a custom [comparator](../Func/Comparator.md);
- instances of that type can be used as key inside an ordered
  collection such as [SkipListMap](../Collections/SkipListMap.md) or
  [SkipListSet](../Collections/SkipListSet.md);
- access to ordering functions such as `.Gt()` and `.Lt()`.

## Implementing `.Compare()`

The `.Compare()` method takes one parameter `Other`, which is *strictly* the
same type as `this`. It is a mandatory parameter, and not allowed to be
`unset`. However, you can handle `unset` with a little help of
[comparators](../Func/Comparator.md).

When comparing two values `A` and `B`, `A.Compare(B)` should return one of
the following:

- A negative integer, if `A < B`
- `0`, if `A == B`
- A positive integer, if `A > B`

It is **strongly recommended** that the `.Compare()` method is consistent with
the `.Eq()` method defined by the [Eq](./Eq.md) interface. This means that if
two values are considered equal by `.Eq()`, then `.Compare()` should
return `0` when comparing those two values.

Here's an example of how to implement the `.Compare()` method for a simple
`Version` class:

```ahk
class Version {
    __New(Major, Minor, Patch) {
        this.Major := Major
        this.Minor := Minor
        this.Patch := Patch
    }

    Compare(Other) {
        if (!(Other is Version)) {
            throw TypeError("Expected a Version",, Type(Other))
        }
        return (this.Major).Compare(Other.Major)
            || (this.Minor).Compare(Other.Minor)
            || (this.Patch).Compare(Other.Patch)
    }
}
```

Note that I'm using `||` to chain the comparisons together. This works, because
if the first comparison is non-zero, it will be returned immediately,
otherwise it'll continue with the next comparison and so on.

## Static `.Compare()` Method

You can use `T.Compare(A, B)` to compare two instances of type `T` with each
other. For example, `String.Compare()` will assert that both of its inputs
are strings, and then compare the two.

We can rewrite our `.Compare()` method to assert that all three fields are
`Integer`s, like this:

```ahk
...
return Integer.Compare(this.Major, Other.Major)
    || Integer.Compare(this.Minor, Other.Minor)
    || Integer.Compare(this.Patch, Other.Patch)
```

Although [duck types](./DuckTypes.md) might not inherit any `.Compare()`
methods, you can still provide a static `.Compare(A, B)` method for the class
that defines the duck type.

## Comparator Functions

`T.Compare` returns a [comparator function](../Func/Comparator.md) which can
be used as configuration inside ordered collections, or as parameter for
`.Sort()` methods.

```ahk
Arr := ["24.2", 45, 0, "0", 22.0, "-3"]

; e.g.: ("0", 0) => (true).Compare(false) => 1.Compare(0) => 1
NumbersFirst(A, B) => (A is String).Compare(B is String)

Arr.Sort( (Numeric.Compare).Then(NumbersFirst) )
; -> ["-3", 0, "0", 22.0, "24.2", 45]
;           ^ (number zero comes before string zero)
```
