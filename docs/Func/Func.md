# <[Func](./overview.md)/[Func](../../src/Func/Func.ahk)>

- [Overview](#overview)
- [Memoization](#memoization)
- [Try-Catch-Finally](#try-catch-finally)
- [Wrap in Loop Behavior](#wrap-in-loop-behavior)
- [`Self()` Function](#self-function)

## Overview

Basic utilities for function composition.

Use `.AndThen()` and `.Compose()` to chain functions together:

```ahk
Plus5TimesTwo := Plus5.AndThen(TimesTwo)
TimesTwoPlus5 := Plus5.Compose(TimesTwo)
```

## Memoization

Calling `.Memoized()` returns a memoized version of a function that
caches previous results in an [IMap](../Interfaces/IMap.md).

```ahk
Fibonacci(x) {
    static Memo := Fibonacci.Memoized()
    if (x > 1) {
        return Memo(x - 2) + Memo(x - 1)
    }
    return 1
}
Fibonacci(80) ; 23416728348467685
```

Note: if the function calls itself recursively, it must use its
memoized version for caching.

## Try-Catch-Finally

You can wrap a function with try-catch-finally logic by calling `.WithCatch`:

```ahk
Divide(A, B) => (A / B)
SafeDivide := Divide.WithCatch(
    (Err) => MsgBox(Err.Message),
    () => MsgBox("finished")
)
```

## Wrap in Loop Behavior

You can wrap a function to be called multiple times in a loop by calling
`.Loop()`. The resulting function is able to access the `A_Index` variable.

```ahk
Print := () => MsgBox(A_Index)
L := Print.Loop(100)
L() ; 1, 2, 3, ..., 100
```

## `Self()` Function

The `Self()` function is a fundamental concept in functional programming that
represents the *identity function* which always returns its input value.

```ahk
MsgBox(Self(42)) ; 42
```
