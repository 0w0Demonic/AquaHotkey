# <[Interfaces](./overview.md)/[IBuffer](../../src/Interfaces/IBuffer.ahk)>

- [\<Interfaces/IBuffer\>](#interfacesibuffer)
  - [Overview](#overview)
  - [Duck Type](#duck-type)
  - [Read/Write Methods](#readwrite-methods)
  - [Filling the IBuffer](#filling-the-ibuffer)
  - [Hex Dump](#hex-dump)
  - [Defining Properties](#defining-properties)
  - [Slicing](#slicing)

## Overview

IBuffer is the base class for any buffer-like object with `Ptr` and `Size`
property. It introduces a variety of methods related to buffers, most
noteably read/write methods, and defining parts of the buffer as properties.

```ahk
Any
`- Object
   `- IBuffer
      `- Buffer
```

## Duck Type

Any object with `Ptr` and `Size` matches the [duck type](../Base/DuckTypes.md)
imposed by the `IBuffer` class. It makes more sense, though, to make objects
inherit from `IBuffer` to gain access to its methods.

```ahk
({ Ptr: 0, Size: 0 }).Is(IBuffer) ; true
```

## Read/Write Methods

IBuffer introduces `.Get<NumType>()` and `.Put<NumType>()` for every AHK
number type.

**Read**:

```ahk
Buf.Get("UChar", 16)
Buf.GetUChar(16)
```

**Write**:

```ahk
Buf.Put("Int", 2343651, 16)
Buf.PutInt(2343651, 16)
```

Also supports strings.

```ahk
Buf.GetString(Offset := 0, Encoding := "UTF-16")
Buf.PutString(Str, Offset := 0, Encoding := "UTF-16")
```

## Filling the IBuffer

To fill the buffer with the specified byte value, use `.Fill(Byte)`.
Use `.Zero()` to fill the buffer with zeros.

```ahk
Buf.Fill(0xFF)
Buf.Zero()
```

## Hex Dump

`.HexDump()` lets you return a hexadecimal representation of the buffer.

; "66 6F 6F 00"
Buffer.OfString("foo", "UTF-8").HexDump()

## Defining Properties

Use `.Define()` to define positions in the buffer as properties. This can
be very useful for creating structs.

```ahk
Buf := Buffer(8).Define("x", "Int", 0).Define("y", "Int", 4)
```

This method is chainable. Generally, you should prefer `static Define()` to
define the property for the prototype of the class instead of for the
object instance.

```ahk
class RECT extends Buffer {
    static __New() => this
        .Define("Left",  "Int",  0)
        .Define("Top",   "Int",  4)
        .Define("Right", "Int",  8)
        .Define("Bottom" "Int", 12)

    __New(Left := 0, Top := 0, Right := 0, Bottom := 0) {
        ...
    }
}
```

## Slicing

Lastly, `.Slice()` lets you return a buffer view of a portion of the buffer.
While resizing the buffer is okay, you should avoid it when possible.

```ahk
Buf := Buffer(4, 0)           ; [ 0   0   0   0 ]
FirstHalf := Buf.Slice(0, 2)  ; [ 0   0 ]
SecondHalf := Buf.Slice(2, 2) ;         [ 0   0 ]
```
