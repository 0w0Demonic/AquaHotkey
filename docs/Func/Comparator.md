# Comparator

## Overview

Comparators are functions that take two inputs and return an integer:

- `< 0`: `a  < b`
- `= 0`: `a == b`
- `> 0`: `a  > b`

They're used across the library to define custom orderings for sorting and
max/min operations.

## Building Comparators

- `Comparator.Numeric()`: sort numerically
- `Comparator.Alphabetic()`: sort alphabetically
  
Use `.AndThen()` to fall back to a second comparator when values are equal.

```ahk
Comp := Comparator.Numeric().AndThen(Comparator.Alphabetic)
```

Or shorthand it:

- `.AndThenNumeric(Args*)`
- `.AndThenAlphabetic(Args*)`

You can reverse the result:

```ahk
Comp.Reversed()
```

You can also make it handle `unset` gracefully:

```ahk
Comp.NullsFirst() ; or .NullsLast()
```

Add null handling with `.NullsFirst()` and `.NullsLast()` as *last* operation.

## Function Composition

`.Compose(Mapper)` applies a mapper before comparing - you should usually avoid
this method. Prefer `Comparator.Numeric(StrLen)` instead of
`Comparator.Numeric().Compose(StrLen)`.

## Example

```ahk
ByStrLen := Comparator.Numeric(StrLen).AndThenAlphabetic().NullsFirst()
```

Yes, the method names are long. But they're also dead simple and surprisingly
expressive.

## Performance Tip

Comparators are lightweight and relatively easy to create, but consider storing
them (e.g. in a static variable) to avoid making unnecessary copies. They're
immutable and can therefore be shared across your entire script.
