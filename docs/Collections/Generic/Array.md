# <[Collections](../overview.md)/[Generic](./overview.md)/[Array](../../../src/Collections/Generic/Array.ahk)>

## Summary

A type-checked wrapper for [IArray](../../Interfaces/IArray.md) classes.
Generic arrays wrap around any array class that implements `IArray`, and
enforce that all of their elements conform to a specified type.

```ahk
Arr := String[]("foo", "bar", "baz")

MsgBox(Type(Arr)) ; "String[]"
```

Use `IArray.OfType(T)` to create a new generic array class.

Alternatively, you can call `.__Item[]` on a class `T` to return its
"array class".

```ahk
StrArray := Array.OfType(String)

; shorthand:
StrArray := String[]
```

## Array Type and Component Type

The way how generic array classes work is simpler than you might think.
Essentially, they're just wrappers around existing array classes with
type-checking.

Every generic array class holds an *array type* and a *component type*.

The array type describes the array that should be used to store elements.
It can be any class that inherits from `IArray`:

```ahk
Cls := Array.OfType(String)
Cls := LinkedList.OfType(Integer) ; (because LinkedList inherits from IArray)
```

The component type describes the type of elements that the array holds.
It uses [duck types](../../Base/DuckTypes.md), which means you can use any
arbitrary type definition as the element type.

```ahk
ArrClass := Array.OfType({ name: String, age: Integer })
```

... even predicates, [if you're brave enough](../../Base/DuckTypes.md#using-functions-as-type-patterns).

```ahk
ArrClass := Array.OfType( InstanceOf(Integer).And(Gt(0)) )
```

**Also See**:

- [predicate functions](../../Func/Predicate.md)

## Constraints

Elements can be further constrained by passing a *type wrapper* class like
[Nullable](../../Base/DuckTypes/Nullable.md) between the square brackets.

```ahk
String[Nullable]("foo", "bar", unset, "baz") ; array of `Nullable(String)`
```

The concept behind type wrappers isn't fully established yet. For now, just
remember you can pass `Nullable` between the brackets if you want to, and
the array will be able to hold `unset` as an element.

## Use as Type Pattern

Generic array classes can be used as [type patterns](../../Base/DuckTypes.md).

If the tested value is another generic array, its array and component type are
checked for compatibility using
[`.CanCastFrom()`](../../Base/DuckTypes.md#subclasses-and-cancastfromt).

```ahk
Generic := String[]("foo", "bar")

MsgBox(Generic.Is(String[])) ; true
MsgBox(Generic.Is(Any[]))    ; true (because `Any.CanCastFrom(String)`)
```

Otherwise, the tested value must be instance of the class's array type, and
all of its elements must be instance of the class's component type.

```ahk
; --> true (`1.Is(Number) && 2.Is(Number) && ...`)
Array(1, 2, 3, 4).Is(Number[])

; --> false (`LinkedList.CanCastFrom(Array)` returns `false`)
LinkedList(1, 2, 3, 4).Is(Number[])

; --> true
LinkedList(1, 2, 3, 4).Is( LinkedList.OfType(Number) )
```

The fact that generic array classes can match regular arrays is a design choice
in favor of duck types. It allows matching an array by its elements without
necessarily having to use a generic array class.

This allows a lot more flexible code, but also means that you need to be
careful with nested generic arrays:

```ahk
; OK.
Grid := Number[][](
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
)

; TypeError! (as intended)
Grid[1] := "not a Number[]"

; doesn't throw...
Grid[1][1] := "not a number"
```

In this example, changing the value of `Grid[1][1]` doesn't throw a `TypeError`,
because `Grid[1]` is only a plain array. To avoid this, you should generally
prefer generic arrays over regular ones.

```ahk
; bulletproof version
Grid := Number[][](
    Number[](1, 2, 3),
    Number[](4, 5, 6),
    Number[](7, 8, 9)
)
```

## Performance

If performance matters, you should try to reuse existing classes as best as
you can. In that case, the overhead of generic array classes stays relatively
reasonable, depending on what you're doing.

```ahk
ArrCls := String[Nullable]

; reuse `ArrCls` instead of creating a new class
Array("foo", "bar", unset, "baz").Is(ArrCls)
```

Arguably, you can also use generic array classes as a development tool to
catch type errors early on. You can start with generic arrays, and then switch
to regular ones once your code is stable and you know that it works. This way,
you get the best of both worlds. Kind of like how TypeScript does it.

```ahk
Numbers := Numeric[](1, 2, "3.4")

; at some point, replace with `Array(1, 2, "3.4")` as soon as everything works
```
