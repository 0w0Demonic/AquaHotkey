# <[IO](./overview.md)/[Serializer](../../src/IO/Serializer.ahk)>

- [\<IO/Serializer\>](#ioserializer)
  - [Overview](#overview)
  - [Basic Usage](#basic-usage)
  - [Supported Object Types](#supported-object-types)
  - [Custom Serialization](#custom-serialization)
  - [Graph Serialization](#graph-serialization)
  - [Binary Format Specification](#binary-format-specification)

## Overview

Implements a graph- and binary stream-based serializer for runtime values in
AutoHotkey. It supports most of the built-in AHK types and
[AquaHotkey collection types](../Collections/overview.md).

## Basic Usage

Use a `File` object to write from or into a file, or a `BufferEditor` to write
an object into memory. To write a value in its binary representation, use
`.WriteObject()`. Use `.ReadObject()` to reconstruct the same data back into
the original object.

## Supported Object Types

The following native types are supported:

- `Object`
- `Array`
- `Map`
- `Buffer`

## Custom Serialization

You can customize the way in which objects are serialized or deserialized by
implementing your own `.Serialize()` and `.Deserialize()` methods for the
type. For more information, see [`<IO/Serial>`](./Serial.md).

```ahk
class Point {
    Serialize(Output, Refs) {
        Output.WriteInt64(this.X)
        Output.WriteInt64(this.Y)
    }

    Deserialize(Input, Refs) {
        this.X := Input.ReadInt64()
        this.Y := Input.ReadInt64()
    }
}
```

## Graph Serialization

This serializer is graph-based, which means it's able to reference
previously seen objects, which typically happens when multiple objects share
the same reference or if there's a cyclic dependancy.

```ahk
A := Object()
B := Object()
A.Value := B
B.Value := A
FileOpen("result.txt", "w").WriteObject(A)

Obj := FileOpen("result.txt", "r").ReadObject()
MsgBox(Obj.Value.Value == Obj) ; true
```

## Binary Format Specification

For more information about the binary format used by the serializer, see the
[source file](../../src/IO/Serializer.ahk).
