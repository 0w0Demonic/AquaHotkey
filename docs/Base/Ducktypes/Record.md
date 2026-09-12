# <[Base](../../Base/overview.md)/[DuckTypes](../DuckTypes.md)/[Record](../../../src/Base/DuckTypes/Record.ahk)>

- [\<Base/DuckTypes/Record\>](#baseducktypesrecord)
  - [Overview](#overview)
  - [Compared to Regular Objects](#compared-to-regular-objects)
  - [Pattern Matching](#pattern-matching)
  - [Subtypes](#subtypes)
  - [Future Plans](#future-plans)

## Overview

A record represents a plain object with constraints to its properties.

For each property of the object, ...

1. the property name must be instance of the record's key type;
2. the property value must be instance of the record's value type.

Only plain objects can be instance of a record.

```ahk
Obj := {
    Admin: "do what you want lol",
    User: "okay, you're allowed in",
}

Rec := Record(Type.Enum("Admin", "User", "Guest"), String)
Obj.Is(Rec) ; true
```

## Compared to Regular Objects

A record does not check whether an object has a set of properties. Instead, all of the properties of an object must match the constraints specified by the record. This is comparable to a `Partial<Record<K, V>>` in JavaScript. To determine whether an object owns a set of properties, use plain objects as type patterns instead.

```autohotkey
{ A: "foo", B: "bar" }.Is({ A: String, B: String, C: String })
; ==> false (does not have property `C`)
```

## Pattern Matching

To match a record, the value must be a plain object (inherit directly from `Object.Prototype` and no other class), and each of its own fields must match by the key and value that was specified in the record.

```ahk
Arr := Array()
Arr.Value := 42

Rec := Record(Eq("Value"), Integer)
Arr.Is(Rec) ; false (because `Arr` is an array and not a plain object)
```

## Subtypes

Whether a record is considered a subclass of another record depends on its key and value type.

```ahk
( Record(String, Any) ).CanCastFrom( Record(String, Integer) )

; --> true (because `String.CanCastFrom(String) && Any.CanCastFrom(Integer)`)
```

## Future Plans

- There should be a way to create a record class by using a fixed set of keys rather than a type.
- Due to its behavior, `Record` should probably be renamed to `PartialRecord`.
- Implement `.CanCastFrom()` logic to determine the relation of two record types

