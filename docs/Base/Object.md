# <[Base](./overview.md)/[Object](../../src/Base/Object.ahk)>

## Overview

Object utilities, mostly for the creation of new properties.

```ahk
class Point {
    ; declare `X` and `Y` as immutable properties
    __New(X, Y) => this.DefineProps({ X: Constant(X), Y: Constant(Y) })
}
```

## Working With Property Descriptors

AutoHotkey's object protocol is based on property descriptors, which are plain
objects that define the behaviour of a property. This makes the language
incredibly flexible, but it can be a bit verbose at times.

To make it easier to work with, AquaHotkeyX provides some helper functions
for creating property descriptors. It features both very common patterns like
`Constant`, but also very hacky ones like `CheckedField`, which defines a
property that checks the type of the value being set.

```ahk
Obj := Object()
Obj.DefineProp("Value", CheckedField(Integer, 42))

MsgBox(Obj.Value) ; 42
Obj.Value := 23
MsgBox(Obj.Value) ; 23
Obj.Value := "not an integer" ; TypeError!
```

## Method `.TransformProp()`

You can also wrap existing functions with additional behaviour:

```ahk
WithLogging(PropDesc, Message) {
    return { Call: Method }

    Method(Args*) {
        MsgBox(Message)
        return (PropDesc.Call)(Args*)
    }
}

Target := (Array.Prototype)
PropName := "Push"
Old_PropDesc := Target.TransformPop(PropName, WithLogging, "pushing...")

Arr := Array()
Arr.Push(1, 2, 3)
```

`.DefineProps()` lets you define several properties at once. It accepts one
plain object that contains zero or more fields with their associated prop desc.

```ahk
class Point {
    ; declare `X` and `Y` as immutable properties
    __New(X, Y) => this.DefineProps({ X: Constant(X), Y: Constant(Y) })
}
```

Also, you can use `ObjFromDesc(Desc)` to create an object only based from
a set of property descriptors.

```ahk
; equivalent to:
; 
; Obj := {}.DefineProp("X", { Get: (_) => 24 })
;          .DefineProp("Y", { Get: (_) => 15 })
Obj := ObjFromDesc({ X: Constant(24), Y: Constant(15) })
```

## Method `.GetPropDesc()`

By using `.GetPropDesc()` instead of `.GetOwnPropDesc()`, you can retrieve a
property descriptor by name, regardless of *where* the property is defined.

```ahk
BaseObj := { Value: 42 }
Obj := { base: BaseObj }

Obj.GetPropDesc("Value") ; { Value: 42 }
```

## Some Other Things

Functions `ObjBindMethod()` and `ObjSetBase()`, but as methods.

```ahk
Arr := Array()
Push := Arr.BindMethod("Push")
Push(1, 2, 3)
MsgBox(Arr.Length) ; 3

class Point {
    __New(X, Y) => this.DefineProps({ X: Constant(X), Y: Constant(Y) })
}

Obj := Object()
Obj.SetBase(Point.Prototype)
Obj.__New(15, 23)
```
