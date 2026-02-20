# <[Func](./overview.md)/[Predicate](../../src/Func/Predicate.ahk)>

- [Overview](#overview)
- [Construction](#construction)
- [Composition](#composition)
- [Negation](#negation)
- [Built-In Functions](#built-in-functions)
- [Type Info](#type-info)
- [Ordering](#ordering)
- [Equality](#equality)

## Overview

A predicate is a function that takes in one input and returns a boolean value
(either `true` or `false`) based on a condition. They are useful for
filtering elements in [collections](../Collections/overview.md) or
[streams](../Stream/Stream.md), and for making concise
[assertions](../Base/Assertions.md) as validation or for testing.

```ahk
class Predicate extends Func {}
```

## Construction

Use `Predicate(Obj)` to create a predicate from any callable object.

```ahk
P := Predicate((Str) => InStr(Str, A_Space))
```

For more info, see [function casting](./Cast.md).

## Composition

Predicate functions can be composed together to form complex boolean
expressions:

```ahk
P := IsNumber.Or(IsSpace).Or(IsTime)

; alternatively:
P := Predicate.Any(IsNumber, IsSpace, IsTime)
```

## Negation

You can negate a predicate by calling either `Predicate.Not(Fn)` or
by calling the `.Negate()` method on an existing predicate.

```ahk
Predicate.Not(Fn)
Predicate(Fn).Negate()
```

## Built-In Functions

All compatible built-in functions are now defined as predicates, which means
you can call predicate methods on them.

This includes...

- all `Is...()` functions except `IsSet()`;
- `DirExist`, `FileExist`, and `ProcessExist()`.

```ahk
IsNotNumber := IsNumber.Negate()

Contains(Str) => Predicate.Cast((Input) => InStr(Input, Str))
FileContainsStr := FileExist.And( FileRead.AndThen(Contains("foo")) )
```

## Type Info

Use `InstanceOf(T)` to create a predicate that determines whether the input
is instance of the given type (based on [duck types](../Base/DuckTypes.md)).

```ahk
Array("foo", "bar", 0, 12).RetainIf(InstanceOf(String)) ; --> ["foo", "bar"]
```

To determine whether the input explicitly `is T`, use `DerivesFrom(Cls)`
instead.

```ahk
; --> (Val?) => IsSet(Val) && String.IsInstance(Val?)
I := InstanceOf(String)

; --> (Val?) => IsSet(Val) && (Val is String)
D := DerivesFrom(String)
```

## Ordering

You can use the same methods for total ordering defined in
[<Base/Comparable>](../Base/Comparable.md) to form predicates:

```ahk
; --> [2, 3, 4]
Array(1, 2, 3, 4, 5).RetainIf( InRange(2, 4) )

; (assuming `Version` is comparable and implements `.Compare(Other)`)
; 
; --> Optional<Version(2,1,1)>
Array(Version(2,0,5), Version(2,1,1), ...).Find(Gt(Version(2,0,10)))
```

## Equality

Use `Eq()` and `Ne()` to create equality predicates (based on AquaHotkey's
[equality methods](../Base/Eq.md)).

```ahk
0.Assert(Eq(0))
```

Functions `RefEq()` and `RefNe()` use regular `=` and `!=`.

```ahk
; --> (Val?) => 0.Eq(Val?)
Eq(0)

; --> (Val?) => (Obj = Val)
RefEq(Obj)
```
