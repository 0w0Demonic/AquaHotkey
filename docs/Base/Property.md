# <[Base](./overview.md)/[Property](../../src/Base/Property.ahk)>

- [\<Base/Property\>](#baseproperty)
  - [Overview](#overview)
  - [Type-Checked Fields](#type-checked-fields)
  - [Reactive Properties](#reactive-properties)

## Overview

A class that help with the creation of new object properties.

```ahk
class Point {
    __New(X, Y) => this.DefineProps({
        X: Property.Constant(X),
        Y: Property.Constant(Y)
    })
}
```

AutoHotkey's object protocol is based on property descriptors, which are plain objects that define the behaviour of a property. This makes the language incredibly flexible, but it can be a bit verbose at times.

## Type-Checked Fields

This allows you to create fields whose values are type-checked.

```ahk
Obj := Object()
Obj.DefineProp("Value", Property.CheckedField(Integer, 42))

MsgBox(Obj.Value) ; 42
Obj.Value := 23
MsgBox(Obj.Value) ; 23
Obj.Value := "not an integer" ; TypeError!
```

For more information, see [<Base/DuckTypes>](./DuckTypes.md).

## Reactive Properties

An observable field which executes a callback function whenever its
value changes.

```ahk
Callback(NewValue) {
    MsgBox("changed! " . NewValue)
}

Obj := Object()
Obj.DefineProp("Age", Property.ReactiveProp(Callback))

Obj.Age := 42 ; --> MsgBox("changed! 42")
```
