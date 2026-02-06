# Module `<Base>`

- [All Modules](../api-overview.md)

## List of Features

- [Assertions](./Assertions.md)
- [Buffer](./Buffer.md)
- [ComValue](./ComValue.md)
- [DuckTypes](./DuckTypes.md)
- [Eq](./Eq.md)
- [Error](./Error.md)
- [Hash](./Hash.md)
- [Object](./Object.md)
- [Ord](./Ord.md)
- [ToString](./ToString.md)
- [TypeInfo](./TypeInfo.md)
- [VarRef](./VarRef.md)

## Assertions

- [<Base/Assertions>](./Assertions.md)

Simple assertion utilities for validating values during development. Integrates
with predicates for fluent, composable validation chains.

```ahk
Assert(2 == 2)

Num := 23
Num.AssertType(Number).Assert(Gt(2))
```

**See Also**:

- [Predicates](../Func/Predicate.md)
- [Duck Types](./DuckTypes.md)

## Duck Types

- [<Base/DuckTypes>](./DuckTypes.md)

A runtime type system enabling duck typing and structural pattern matching.
Extends the `is` operator to support custom type checks, object/array patterns,
and generic type validation.

```ahk
User := { age: Integer, name: String }
Pattern := Array.Of(User)

Obj := [{ age: 21, name: "Sasha" }
        { age: 37, name: "Sofia" }]

Obj.Is(Pattern) ; true
```

**See Also**:

- [Generic Collections](../Collections/overview.md)

## Buffer

- [<Base/Buffer>](./Buffer.md)

Provides utility for working with buffers, especially for creating new buffers
through methods like `Buffer.FromFile()` or `Buffer.FromString()`.

Operations that apply to *any* buffer-like object are implemented in
[IBuffer](../Interfaces/IBuffer.md).

This module also includes information about the size of AHK number types.

```ahk
Buf := Buffer.OfString("Hello, world!")

Slice := Buf.Slice(0, 8) ; copy the first 8 bytes into a new buffer

Size := Buffer.SizeOf("Int64") ; 8
```

**See Also**:

- [IBuffer](../Interfaces/IBuffer.md)

## ComValue

- [<Base/ComValue>](./ComValue.md)

A variety of shorthand methods and properties for the `ComValue` types.
This includes the `VT_` constants, as well as their constructors.

**VARIANT Types as Constants**:

```ahk
MsgBox(ComValue.BSTR)    ; 0x0008 (VT_BSTR)
MsgBox(ComObjArray.BSTR) ; 0x2008 (VT_BSTR | VT_ARRAY)
MsgBox(ComValueRef.BSTR) ; 0x4008 (VT_BSTR | VT_BYREF)
```

**VARIANT Type Constructors**:

```ahk
Str := ComValue.BSTR("foo")
Ref := ComValueRef.BSTR(Buffer.OfString("foo"))
Arr := ComObjArray.BSTR(16, 2) ; ComObjArray(0x08, 16, 2)
```

**`.Get()` and `.Set()` for `ComValueRef`**:

```ahk
Ref := ComValueRef.VARIANT(Buffer(24, 0)).Set("value")
MsgBox(Ref.Get())
```

## Equality Checks

- [<Base/Eq>](./Eq.md)

Universal equality protocol via the `.Eq()` method. Defines how values should
compare for semantic equality, distinct from identity checks. It's the backbone
of many different collections like `HashSet` and `HashMap` to reliably check
for value presence.

```ahk
([1, 2, 3]).Eq([1, 2, 3]) ; true

({ foo: "bar" }).Eq({ FOO: "bar" }) ; true (properties are case-insensitive)

Any.Equals(unset, unset) ; true

Integer.Equals(34, []) ; Error! Expected an Integer, but got an Array.
```

**See Also**:

- [Hash Codes](./Hash.md)
- [Collection Classes](../Collections/overview.md)
- [HashSet](../Collections/HashSet.md)
- [Find-Value Methods](../Interfaces/Enumerable1.md)

## Error Handling

- [<Base/Error>](./Error.md)

Utilities related to errors, such as throwing or error causes.

```ahk
try {
    ...
} catch as Err {
    throw ValueError(...).CausedBy(Err)
}

class Something {
    Value => UnsetError.Throw("Not implemented")
}
```

## Hash Codes

- [<Base/Hash>](./Hash.md)

Consistent hash code generation for all value types. Enables values to be used
reliably in hash-based collections like `HashMap` and `HashSet`

```ahk
"foo".HashCode()
Array(1, 2, 3).HashCode()

Integer.Hash(23, 41, 9734, 12)
```

**See Also**:

- [HashMap](../Collections/HashMap.md)
- [HashSet](../Collections/HashSet.md)

## Object Manipulation

- [<Base/Object>](./Object.md)

Core object utilities for introspection and manipulation properties.

```ahk
Obj.DefineProp({
    Capacity: { Get: (_) => 16 },
    SayHello: { Call: (_) => MsgBox("Hello, world!") },
    ...
})

Obj.DefineProp("Value", CheckedField(Integer, 42))

MsgBox(Obj.Value)           ; 42
Obj.Value := "not a number" ; Error!
```

## Comparing by Natural Order

- [<Base/Ord>](./Ord.md)

Natural ordering via the `.Compare()` method. Enables sorting and ordering
operations on custom types.

```ahk
Arr := [23, 5623, 123, 56]

Arr.Sort() ; --> [23, 56, 123, 5623]
Arr.Stream().RetainIf(Gt(100)) ; <123, 5623>

; note: for `.AssertType()`, see <Base/Assertions> and <Base/DuckTypes>.
class Version {
    __New(Major, Minor, Patch) {
        this.Major := Major.AssertType(Integer)
        this.Minor := Minor.AssertType(Integer)
        this.Patch := Patch.AssertType(Integer)
    }

    Compare(Other) {
        Other.AssertType(Version)
        return (this.Major).Compare(Other.Major)
            || (this.Minor).Compare(Other.Minor)
            || (this.Patch).Compare(Other.Patch)
    }
}
```

**See Also**:

- [Predicates](../Func/Predicate.md)
- [Sorting Arrays](../Interfaces/IArray.md)
- [IArray](../Interfaces/IArray.md)

## String Representations

- [<Base/ToString>](./ToString.md)

Custom string conversion via the `.ToString()` method for all types.
Provides human-readable representations for debugging and logging.

```ahk
String(Array(1, 2, 3)) ; "[1, 2, 3]"

; (<Collections/Generic/Array>)
Integer[](1, 2, 3).ToString() ; "Array<Integer>[1, 2, 3]"

String(MsgBox) ; "Func MsgBox"
String(Buffer) ; "Class Buffer"
```

## Type Information

- [<Base/TypeInfo>](./TypeInfo.md)

Detailed information about types, including inheritance chains, properties,
and implementing class of an object.

```ahk
42.Class ; Integer (class)
42.Type ; "Integer" (string)

"foo".Hierarchy ; ["foo", String.Prototype, Primitive.Prototype, Any.Prototype]
"foo".Bases ; [String.Protoype, Primitive.Prototype, Any.Prototype]
```

## VarRef

- [<Base/VarRef>](./VarRef.md)

Allows the `Ptr` property of an object to be used, even if it's wrapped by
a `VarRef`.

```ahk
Str := "Hello, world!"
DllCall("...", "Ptr", &Str)
```
