# Array

## Stream-Like Methods

The stream-inspired methods like `.Map()`, `.RetainIf()`, `.RemoveIf()` and
`.ReplaceAll()` behave just like you'd expect - think Java Streams, Python
list comprehensions, or Clojure & Haskell `map`.

```ahk
ArrayObj.Map(TimesTwo).RetainIf(GreaterThan10).ForEach(MsgBox)
```

Use [Stream](../Extensions/stream.md) to support lazy evaluation and complicated
[collect](../Extensions/collector.md) and [gather operations](../Extensions/gatherer.md)
(side note: *definitely* check these out, they're absolutely bonkers).

```ahk
C := Collector
G := Gatherer

; Map {
;     true:  Map { true: [202, ...], false: [38, ...] },
;     false: Map { true: [873, ...], false: [13, ...] }
; }
ArrayObj.Collect(C.Partition(IsEven, C.Partition(GreaterThan100)))

; <[1, 2, 3, 4], [2, 3, 4, 5], [3, 4, 5, 6]>
Array(1, 2, 3, 4, 5, 6).Gather(G.WindowSliding(4))
```

---

### Quick Overview

- `.Map()` - transforms elements
- `.ReplaceAll()` - mutating version of `.Map()`
- `.RetainIf()` and `.RemoveIf()` - instead of `.Filter()`
- `.FlatMap()` - transforms, then flattens elements
- `.Reduce()` - combine each element into a single value
- `.ForEach()` - calls a function on each element

---

### Using `Args*`

AutoHotkey v2.0 has unpleasant limitations. Since lambdas can't use block
bodies, these methods accept additional `Args*` after the function:

```ahk
MyArray.Map(SubStr, 1, 1)             ; (s) => SubStr(s, 1, 1)
MyArray.Map(StrReplace, "foo", "bar") ; (s) => StrReplace(s, "foo", "bar")
```

This is great for quick hacks, but don't overuse it. If things get complicated,
extract the logic into a named function, or switch to AHK v2.1 alpha to write
(preferably small) blocks in lambdas. Like this:

```ahk
Convert(Str) {
    ...
}

ArrayObj.Map(Convert)
```

```ahk
; beloved AHK alpha <3
#Requires AutoHotkey >=v2.1-alpha.3

ArrayObj.Map(Convert(Str) {
    if (...) {
        ...
    }
    return (...) ? ...
                 : ...
})
```

---

### Composable Helpers

Use helper classes like `Mapper`, `Condition` and `Combiner` to build functions
on the fly:

```ahk
MyArray.RetainIf(  Condition.IsNotNull  )
       .RetainIf(StrLen.AndThen(  Condition.Greater(2)  ))

MyArray.Map(  Mapper.Split(",", A_Space)  )

MyArray.Reduce(  Combiner.Sum  )
```

For more fun, see: [Mapper](./Mapper.md), [Condition](./Condition.md),
[Combiner](./Combiner.md)

---

## Custom Sorting

The `.Sort()` method lets you sort elements in place using a custom comparator
function (or otherwise, the array is sorted by numbers).

```ahk
/** no comparator - sort numerically */
Array(3, 2, 4, 1).Sort() ; [1, 2, 3, 4]

/** sorts strings alphabetically */
Array("foo", "bar").SortAlphabetically() ; ["bar", "foo"]
```

---

### Comparators

By convention, a comparator is a function that accepts two inputs `a` and `b`,
returning...

- `0`, if `a = b`
- a positive integer, if `a > b`
- a negative integer, if `a < b`

---

Use the `Comparator` class to create custom comparators:

```ahk
ByStrLen := Comparator.Numeric(StrLen).AndThenAlphabetic().NullsFirst()
```

While the methods are arguably verbose, the resulting comparator function
is surprisingly sophisticated:

1. Accept strings `a` and `b`, checking whether any input argument is `unset`.
2. Otherwise, compare `StrLen(a)` and `StrLen(b)` numerically.
3. If both strings have the same length, compare `a` and `b` alphabetically.

```ahk
; [unset, unset, "a", "b", "bar", "foo", "Hello", "Banana"]
MyArray.Sort(ByStrLen)
```

**Note**: Even though comparators aren't very expensive to create, you should
generally store them (e.g., in a static variable) for later reuse.

```ahk
Foo() {
    static Comp := ...

    ...
    MyArray.Sort(Comp)
}
```

- see [Comparator](./Comparator.md)

## Grouped Values and `ZipArray`

The newly added `ZipArray` lets you handle data very elegantly by using arrays
of grouped values - so-called *tuples* - which are immutable arrays.
Conceptually, `ZipArray` works very similar to two-dimensional arrays.

- see [ZipArray](./ZipArray.md)

When used with stream methods (such as `.ForEach()`), tuples are *spread* into
the given function, i.e., each value in the tuple is passed as separate
argument.

```ahk
... .ForEach((t1, t2, t3, t4) => ...)
```

This lets you elegantly work with grouped data by:

- intersecting multiple arrays

  ```ahk
  ; [(1, 3, 5), (2, 4, 6)]
  ZipArray.Of([1, 2], [3, 4], [5, 6])
  ```

- dissecting array elements into multiple related values

  ```ahk
  ; [("Hello", 5, "H", "o"), ("world!", 6, "w", "!")]
  Array("Hello", "world!").Spread(
          Func.Self,             ; the string itself
          StrLen,                ; string length
          s => SubStr(s, 1, 1),  ; first letter
          s => SubStr(s, -1, 1)) ; last letter
  ```

- performing stream operations on multiple values at once

  ```ahk
  ; [(1, 3, 5), (2, 4, 6)]
  Zipped := ZipArray.Of([1, 2], [3, 4], [5, 6])
  
  Zipped.ForEach((Left, Middle, Right) => MsgBox(Left + Middle + Right))
  ```
