# <[IO](./overview.md)/[Serial](../../src/IO/Serial.ahk)>

- [\<IO/Serial\>](#ioserial)
  - [Overview](#overview)
  - [Supported Types](#supported-types)
  - [Custom Serialization](#custom-serialization)

## Overview

Implements serialization and deserialization for the "basic set" of object
types supported by [`<IO/Serializer>`](./Serializer.md).

Whereas values such as `unset`, classes, primitive types, and references are
hardcoded into the serializer itself, objects are serialized based on their
*native type* as well as their `.Serialize()`/`.Deserialize()` methods.

## Supported Types

The following native types are supported:

- `Object`
- `Array`
- `Map`
- `Buffer`

## Custom Serialization

Because objects are converted based on `.Serialize()`, `.Deserialize()`, you
can provide your own implementation by overriding these two methods.

In this case, the binary format used is *implementation-defined* - in other
words, you decide how things are done.

Refer to [the source file](../../src/IO/Serial.ahk) for guidance on how to
implement them. I highly recommend reading the class-level JSDoc before
implementing your own methods. Because objects are essentially reconstructed
"from scratch", you're also expected to have a good understanding of how
the `.__Init()` and `.__New()` methods work.

```ahk
class Point {
    __New(X, Y) {
        this.X := X
        this.Y := Y
    }

    Serialize(Output, Refs) {
        (Object.Prototype.Serialize)(this, Output, Refs)

        Output.WriteFloat(this.X)
        Output.WriteFloat(this.Y)
    }

    Deserialize(Input, Refs) {
        this.X := Input.ReadFloat()
        this.Y := Input.ReadFloat()
    }
}
```
