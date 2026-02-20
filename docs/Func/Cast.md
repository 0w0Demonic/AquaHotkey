# <[Func](./overview.md)/[Cast](../../src/Func/Cast.ahk)>

- [Overview](#overview)
- [Static `.Call()`](#static-call)
- [Static Method `.Cast()`](#static-method-cast)
- [Instance Method `.Cast()`](#instance-method-cast)

## Overview

This feature allows easy type-casting between different `Func` types.
Because AquaHotkeyX introduces many subclasses of `Func`, it can be useful to
be able to "elevate" a `Func` to a more specific type.

You generally only need this feature if you want to implement a custom `Func`
subclass that has additional methods beyond the base `Func` class.

```ahk
; changes the base of `IsNumber` to `Predicate.Prototype`, which allows it to
; access methods like `.And()`, `.Or()`, etc.
Predicate.Cast(IsNumber)
```

## Static `.Call()`

Calling `Func(Obj)` creates a `BoundFunc` of the given callable object,
and then casts it into an instance of the calling class.

The resulting function is considered a copy of the original, but with a
different type.

```ahk
Pred := Predicate(IsNumber)
; equivalent to...
;   ObjSetBase(Pred := ObjBindMethod(IsNumber), Predicate.Prototype)

MsgBox(Pred is Predicate)     ; true
MsgBox(IsNumber is Predicate) ; false
MsgBox(Pred == IsNumber)      ; false
```

## Static Method `.Cast()`

Calling `Func.Cast(Fn)` changes the base object of `Fn` into the prototype
of the calling class. `Fn` must be an instance of `Func`.

```ahk
Pred := Predicate.Cast(IsNumber)
; equivalent to:
;   ObjSetBase(Pred := IsNumber, Predicate.Prototype)

MsgBox(Pred is Predicate)     ; true
MsgBox(IsNumber is Predicate) ; true
MsgBox(Pred == IsNumber)      ; true
```

## Instance Method `.Cast()`

Lastly, calling `.Cast(Fn)` as method will cast `Fn` into the same type of
the calling function.

Just like in `Func.Cast(Fn)`, `Fn` must also be an instance of `Func`.

```ahk
class Predicate extends Func {
    And(Other) {
        GetMethod(Other)
        return this.Cast((Val?) => this(Val?) && Other(Val?))
    }

    ; ...
}
```
