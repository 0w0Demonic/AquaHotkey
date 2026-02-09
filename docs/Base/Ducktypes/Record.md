# <[Base](../../Base/overview.md)/[DuckTypes](../DuckTypes.md)/[Record](../../../src/Base/DuckTypes/Record.ahk)>

## Summary

A [duck type](../DuckTypes.md) that represents objects with specified key and
value type.

Only plain objects are matched - ones that inherit directly from
`Object.Prototype` and no other class.

```ahk
Obj := {
    Admin: "do what you want lol",
    User: "okay, you're allowed in",
    Guest: "fine... but don't touch anything"
}

Rec := Record(Type.Enum("Admin", "User", "Guest"), String)
Obj.Is(Rec) ; true
```

## Pattern Matching

To match a record, the value must be a plain object (inherit directly from
`Object.Prototype` and no other class), and each of its own fields must
match by the key and value that was specified in the record.

```ahk
Arr := Array()
Arr.Value := 42

Rec := Record(Eq("Value"), Integer)
Arr.Is(Rec) ; false (because `Arr` is an array and not a plain object)
```

## Subtypes

Whether a record is considered a subclass of another record depends on its
key and value type.

```ahk
( Record(String, Any) ).CanCastFrom( Record(String, Integer) )

; --> true (because `String.CanCastFrom(String) && Any.CanCastFrom(Integer)`)
```
