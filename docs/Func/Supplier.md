# <[Func](./overview.md)/[Supplier](../../src/Func/Supplier.ahk)>

## Overview

A zero parameter function that represents a supplier of results.

## Constant Functions

Constant functions are functions that always return the same value.

Use `Constantly(x)` or `Supplier.Of(x)` to return a supplier function that
always returns `x`.

```ahk
Fn := Constantly(42) ; alternatively: `Supplier.Of(42)`

Fn() ; 42
Fn() ; 42
```

## Composition

Use `.Map()` to compose a supplier function with another function.

```ahk
Times(x) => (n) => (n * x)

Dice := Supplier(Random, 1, 6)
TimesTwo := Dice.Map(Times(2))

TimesTwo() ; 6 (random)
TimesTwo() ; 10 (random)
```
