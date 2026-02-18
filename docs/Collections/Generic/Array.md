# <[Collections](../overview.md)/[Generic](./overview.md)/[Array](../../../src/Collections/Generic/Array.ahk)>

## Overview

A type-checked wrapper for [IArray](../../Interfaces/IArray.md) classes,
which enforces that all elements conform to the specified
[duck type](../../Base/DuckTypes.md).

For more information see [generic collections](./overview.md).

```ahk
Arr := String[]("foo", "bar", "baz")
```

Use `IArray.OfType(T)` to create a new generic array class. Alternatively, call
`.__Item[]` on a class to return its "array class". For example, `String[]`
is shorthand for `Array.OfType(String)`.

```ahk
StrArray := Array.OfType(String)

; shorthand:
StrArray := String[]

; - method can be called on any IArray type
; - any duck type can be used to enforce elements in the array
Cls := LinkedList.OfType({ name: String, age: Integer })
```

Elements can be further constrained by passing a *type wrapper* like
[Nullable](../../Base/DuckTypes/Nullable.md) between the square brackets.
`String[Nullable]` becomes shorthand for `Array.OfType(Nullable(String))`.

```ahk
String[Nullable]("foo", "bar", unset, "baz") ; array of `Nullable(String)`
```

## Use as Type Pattern

If the tested value is another generic array, its array and component type are
checked for compatibility using
[`.CanCastFrom()`](../../Base/DuckTypes.md#subclasses-and-cancastfromt).
Otherwise, the tested value must be instance of the class's array type, and
all of its elements must be instance of the class's component type.

```ahk
; --> true (because `Any.CanCastFrom(String)`)
String[]("foo", "bar").Is(Any[]) 

; --> true (`1.Is(Number) && 2.Is(Number) && ...`)
Array(1, 2, 3, 4).Is(Number[])

; --> false (`LinkedList.CanCastFrom(Array)` returns `false`)
LinkedList(1, 2, 3, 4).Is(Number[])

; --> true
LinkedList(1, 2, 3, 4).Is( LinkedList.OfType(Number) )
```
