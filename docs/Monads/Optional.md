# <[Monads](./overview.md)/[Optional](../../src/Monads/Optional.ahk)>

- [\<Monads/Optional\>](#monadsoptional)
  - [Overview](#overview)
  - [Create](#create)
  - [Value Presence](#value-presence)
  - [Side Effects](#side-effects)
  - [Filtering](#filtering)
  - [Transformation](#transformation)
  - [Retrieving Values](#retrieving-values)
  - [`.Optional()` Method](#optional-method)

## Overview

`Optional` represents a value that might or might not exist. It helps you avoid
messy null checks and in certain contexts - for example `.Find()` in
[`Enumerable1`](../Interfaces/Enumerable1.md) - forces you to deal with absence
in a clean, declarative way.

## Create

Use `Optional(Value?)` or `Optional.Of(Value)` to create a new optional.
`Optional.Empty()` produces an empty optional.

```ahk
O := Optional()       ; Optional<unset>
O := Optional.Empty() ; Optional<unset>

O := Optional(42)    ; Optional<42>
O := Optional.Of(42) ; Optional<42>
```

## Value Presence

Properties `.IsPresent` and `.IsAbsent` determine whether the value is
present or absent, respectively.

```ahk
Optional("foo").IsPresent ; true
Optional().IsAbsent       ; true
```

## Side Effects

Use `.IfPresent()` and `.IfAbsent()` to perform side-effects based on whether
the optional contains a value. These methods are chainable.

```ahk
O := Optional().IfPresent((Value) => MsgBox("value present"))
               .IfAbsent(() => MsgBox("value absent"))
```

## Filtering

Use `.RetainIf()` and `.RemoveIf()` to return new optionals filtered by
predicates.

```ahk
O := Optional(42)
O.RetainIf(IsNumber) ; Optional<42>
O.RemoveIf(IsNumber) ; Optional<unset>
```

## Transformation

Use `.Map()` to transform the inner value of the optional, if present.

```ahk
TimesTwo(x) => (x * 2)

Optional(4).Map(TimesTwo) ; Optional<8>
Optional().Map(TimesTwo)  ; Optional<unset>
```

Use `.FlatMap()` for mappers that themselves return optional values.

```ahk
DivideBy(n) {
    if (n == 0) {
        return (x) => Optional.Empty()
    }
    return (x) => Optional.Of(x / n)
}

O := Optional(4)
O.FlatMap(DivideBy(2)) ; Optional<2>
O.FlatMap(DivideBy(0)) ; Optional<unset>
```

## Retrieving Values

Use one of the following methods to retrieve a value from an optional.

```ahk
O.Get()                 ; inner value, or else throw error
O.OrElse(Default)       ; inner value, or `Default`
O.OrElseGet(GetDefault) ; inner value, or `GetDefault()`
O.OrElseThrow()         ; inner value, or else throw detailed error
```

## `.Optional()` Method

To convert any value into an optional, use the `.Optional()` method.

```ahk
42.Optional() ; Optional<42>
```
