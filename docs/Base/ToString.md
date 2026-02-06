# ToString

This package introduces a default string representation for most of the
built-in types. It adds `.ToString()` methods, which are invoked automatically
whenever an object is passed to `String(Value)`.

String representations here are mostly meant for debugging, and shouldn't be
relied on too much. They're also not necessarily final.

## Array

```ahk
String(Array(1, 2, 3, 4)) ; "[1, 2, 3, 4]"
```

## Buffer

```ahk
String(Buffer(128)) ; "Buffer { Ptr: 000000000024D080, Size: 128 }"
```

## Class

```ahk
String(Array) ; "Class Array"
```

## File

```ahk
String(FileOpen(...)) ; "File { Name: C:\...\foo.txt, Pos: 0, ... }"
```

## Func

```ahk
String(() => 1) ; "Func (unnamed)"

String(MsgBox) ; "Func MsgBox"
```

## Object

1. `for Key, Value in Obj`
2. `for Key in Obj`
3. `for PropName, Value in Obj.OwnProps()`
4. `Type(Obj)`

```ahk
; 1. 'Map { foo: "bar" }'
; 2. 'Foo { "val1", "val2", "val3" }'
; 3. 'Object{ foo: "bar" }'
; 4. 'MyClass'
```
