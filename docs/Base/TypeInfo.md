# <[Base](./overview.md)/[TypeInfo](../../src/Base/TypeInfo.ahk)>

- [Overview](#overview)
- [Properties `.Type` and `.Class`](#properties-type-and-class)
- [Properties `.Hierarchy` and `.Bases`](#properties-hierarchy-and-bases)
- [`Class.ForName()`](#classforname)
- [Class `.Name` Property](#class-name-property)

## Overview

Properties for retrieving type information, such as the type and class of a
value, or the name of a class.

```ahk
([1, 2]).Type ; "Array"

"example".Class ; String (class)

; --> [123, Integer.Prototype, Number.Prototype,
;      Primitive.Prototype, Any.Prototype]
(123).Hierarchy

; --> [Integer.Prototype, Number.Prototype, Primitive.Prototype, Any.Prototype]
(123).Bases

; --> Gui.ActiveX (class)
Class.ForName("Gui.ActiveX")
```

## Properties `.Type` and `.Class`

These properties return the type of the value, either as string (which is
equivalent to `Type(Value)`), or the implementing class object.

```ahk
; same as: Type([1, 2])
; 
([1, 2]).Type ; "Array"

([1, 2]).Class ; Array (class)
```

`.Class` relies on the `__Class` property of a value in order to find the
implementing class.

## Properties `.Hierarchy` and `.Bases`

Returns the chain of base objects of a value. While `.Hierarchy` includes the
value itself, `.Bases` doesn't.

```ahk
; --> [123, Integer.Prototype, Number.Prototype,
;      Primitive.Prototype, Any.Prototype]
(123).Hierarchy

; --> [Integer.Prototype, Number.Prototype, Primitive.Prototype, Any.Prototype]
(123).Bases
```

## `Class.ForName()`

Returns a class object by its string path.

```ahk
Class.ForName("Gui.ActiveX") ; class Gui.ActiveX
```

## Class `.Name` Property

Returns the name of the class.

```ahk
String.Name ; "String"
```
