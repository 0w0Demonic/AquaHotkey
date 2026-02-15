# Module `<Collections/Generic>`

- [All Modules](../../api-overview.md)
- [Module `<Collections>`](../overview.md)

## List of All Features

- [GenericArray](./Array.md)
- [GenericMap](./Map.md)

## What Are Generic Collections?

Generic collection classes are *type-safe versions* of existing collection
classes. When you create a generic array or map, you're wrapping an existing
collection (like `Array` or `Map`) with an extra layer that enforces type
constraints on all elements.

```ahk
; generic array: only strings are allowed
; 
StrArr := String[]("foo", "bar")
StrArr.Push(42)  ; TypeError! Expected a String.
```

## How They Work

Each generic collection class:

- *wraps* an existing collection type that implements an interface (`IArray`,
  `IMap`, etc.)
- *enforces* that all elements conform to the specified
  [duck types](../../Base/DuckTypes.md)
- *delegates* actual storage to the underlying wrapped collection

For example, `String[]` is a generic array class that wraps a regular `Array`,
and enforces that all elements are an instance of `String`.

### Backing Collections

The underlying collection can be *any class* that implements the corresponding
interface. For example:

```ahk
StrArray := String[] ; shorthand for: Array.OfType(String)
StrLinkedList := LinkedList.OfType(String)

; assuming `Version` is a comparable type
SortedMap := SkipListMap.OfType(Version, String)
```

### Element Types

Elements can be anything that can be described by a duck type:

```ahk
; array of integers
Arr := Integer[]()

; object patterns
UserArray := Array.OfType({ name: String, age: Integer })

; union types
Result := Array.OfType(
    Type.Union(
        { status: 200, data: Any },
        { status: 400, error: String }
    )
)

; predicates
PositiveIntegers := Array.OfType(  InstanceOf(Integer).And(Gt(0))  )
```

## Using Generics as Type Pattern

Generic collection classes can be used as type patterns for validation:

```ahk
Array().Is(String[])         ; true (edge case: empty array matches everything)
Array("a", "b").Is(String[]) ; true
Array(1, 2).Is(String[])     ; false
```

When checking a generic collection against a generic pattern, the type of
backing collection and element types are tested for compatibility via
[`.CanCastFrom()`](../../Base/DuckTypes.md#subclasses-and-cancastfromt).

```ahk
Integer[](1, 2, 3).Is(Any[]) ; true (because `Any.CanCastFrom(Integer)`)

Cls1 := HashMap.OfType({ name: String, age: Integer }, Array)
Cls2 := IMap.OfType(Object, Any)

Cls1.CanCastFrom(Cls2)
; 1. `IMap.CanCastFrom(HashMap)` --> true
; 2. `Object.CanCastFrom({ ... })` --> true
; 3. `Any.CanCastFrom(Array)` --> true
; --> true
```

## Some Caveats

### Matching Non-Generic Collections

A generic collection, when used as type pattern, **will match its non-generic
counterpart**. This design choice reduces verbosity, but requires some care
with nested patterns.

```ahk
; generic array class matches a plain array
Array(1, 2, 3).Is(Number[])
```

However, this can be surprising with nested structures. The following example
shows a regular array can fulfill the constraints imposed by `Number[]`.

```ahk
Grid := Number[][](
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
)
```

Creating an instance of `Number[][]` doesn't throw, because each of the plain
arrays can be matched by `Number[]`. However, it means that the arrays
themselves are *not* type-safe.

```ahk
Grid[1][1] := "not a number" ; doesn't throw
```

Whenever nesting, you should always take the extra step and be explicit about
the integrity of your elements.

```ahk
Grid := Number[][](
    Number[][1, 2, 3],
    Number[][4, 5, 6],
    Number[][7, 8, 9]
)

Grid[1][1] := "not a number" ; TypeError! Expected a(n) Number.
```

### Mutability of Objects

Although an element can be validated against a duck type during insertion
or modification, this doesn't make the element itself immutable. If the element
is an object, its properties can still be changed.

This is why you should generally try to work with immutable objects, or avoid
making any changes to them.

```ahk
UserArr := Array.OfType({ name: String, age: Integer })
Arr := UserArr({ name: "John Doe", age: 24 })

Arr[1].name := unset ; doesn't throw
```

## Performance Considerations

The overhead of generic collections is reasonable, but not free. Some
optimization tips include reusing generic classes, or
disabling them completely.

```ahk
IntArray := Integer[]

loop 1000 {
    ; reuse `IntArray` instead of creating a new class through `Integer[]`
    Cls := IntArray(1, 2, 3)
}
```

Generics can be used as guard rails for catching errors very early on. As soon
as everything works correctly, you can choose to switch off type-checks to
gain performance.

By including the "disable generics" configuration, you can switch off
type-checking completely.

```ahk
#Include <AquaHotkey/cfg/DisableGenerics>

; `String[]` returns the normal `Array` class.
; 
; Usually, this statement should throw an error, but the program would normally
; be in a state where you've already tested everything.
StrArray := String[]("foo", 42)
```
