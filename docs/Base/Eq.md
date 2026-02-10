# <[Base](./overview.md)/[Eq](../../src/Base/Eq.ahk)>

## Summary

A universal way to test two values for equivalence.

```ahk
; --> true (structural equality)
([1, 2, 3]).Eq([1, 2, 3])


; --> true (properties are case-sensitive)
({ foo: "bar" }).Eq({ FOO: "bar" })
```

The `.Eq()` method takes an optional input value - `Other?` - to be tested
for equality. Collection classes, as well as many other features in AquaHotkeyX
rely on this equality check.

## How to Implement

In order to property implement this method, it must be easy to reason about.

For a more detailed guide, you can check out the JSDoc comments in
[Eq.ahk](../../src/Base/Eq.ahk), or check out the following Wikipedia article:
[Equality (mathematics)](https://en.wikipedia.org/wiki/Equality_(mathematics)#Basic_properties)

To keep it short, you should follow this checklist when writing an `.Eq()`
method:

### Checklist

- `unset` is *not* a value. `A.Eq(unset)` should *always* return `false`.
- If `A == B`, then `A.Eq(B)` should always return `true`. You *should*
  usually perform as fast path.
- Ensure that both `A` and `B` are the same type. In this case, "type" only
  means that the input value is something you'd expect to compare for. I
  strongly recommend using the `is` keyword for this.
- Start comparing the same set of fields in the same order, and use `.Eq()`
  recursively for each field. You should generally bail out as soon as a field
  differs, this keeps checks fast and predictable.
- `.Eq()` should produce the same result while the compared values remain
  unchanged.
- Whatever you use to decide equality must also be used to compute
  [`.HashCode()`](./Hash.md). Otherwise, [maps and sets](../Collections/overview.md)
  will behave incorrectly.
- Keep it simple. Prefer clear, explicit comparisons. It always makes sense to
  document what fields define equality.

### Example

Also see: [`.HashCode()`](./Hash.md)

```ahk
class Version {
    __New(Major, Minor, Patch) {
        this.Major := Major
        this.Minor := Minor
        this.Patch := Patch
    }

    Eq(Other?) {
        ; `unset` is never equal
        if (!IsSet(Other)) {
            return false
        }
        ; identical reference => equal
        if (this == Other) {
            return true
        }
        return (this.Major).Eq(Other.Major)
            && (this.Minor).Eq(Other.Minor)
            && (this.Patch).Eq(Other.Patch)
    }

    ; the same fields are used to produce a hash code
    HashCode() => Integer.Hash(this.Major, this.Minor, this.Patch)
}
```

## Static `.Equals()` Method

Use `T.Equals(A, B)` when you want a type-checked, two-argument equality
function that also supports `unset`.

```ahk
Number.Equals(23, 23)         ; true
Number.Equals(unset, unset)   ; true
Number.Equals([1, 2], [1, 2]) ; TypeError!
```

Duck types usually don't inherit instance equality, so provide a
`static Equals(A, B)` on duck types when needed.

```ahk
Numeric.Equals("-23.2", -23.2) ; true
```

Generally, it should be implemented as follows:

```ahk
static Equals(A?, B?) {
    if (!IsSet(A)) {
        return !IsSet(B)
    }
    if (!IsSet(B)) {
        return false
    }
    if (!A.Is(this) || !B.Is(this)) {
        throw TypeError("...")
    }

    ... ; perform an equality check as you'd do in `.Eq()`
}
```

Note that support for `unset` might be removed in the future, in favor of
[Nullable](./DuckTypes/Nullable.md).
