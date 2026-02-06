# Func

## Common Mapping Functions

- `Func.Self`: a function that always returns its input value (also known as *identity function*)
- `Func.Constantly(x)`: function that always returns `x`
- `Func.Replicate(x)`: function that always returns `x`, or `x.Clone()` if it's
  an object.

## Function Composition

Use `.AndThen()` and `.Compose()` to chain functions together:

```ahk
Plus5TimesTwo := Plus5.AndThen(TimesTwo)

Plus5TimesTwo(2) ; 14
```

**Side Note**: you should generally prefer `.AndThen()`, it's arguably more
straightforward.

You can also compose predicates using `.And()`, `.Or()`, `.Negate()` etc.,
which is great for building small condition checks.

## Memoization

`.Memoized()` returns a memoized version of a function that caches previous
results in a `Map`.

If the function calls itself (a.k.a. *recursion*), it must use its memoized
version for caching.

```ahk
Fibonacci(x) {
    if (x > 1) {
        return FibonacciMemo(x - 2) + FibonacciMemo(x - 1)
    }
    return 1
}
FibonacciMemo := Fibonacci.Memoized()
FibonacciMemo(80) ; 23416728348467685
```

You can also pass a custom hasher and map (or map supplier, or case-sense
option) to control how results are stored and looked up.
