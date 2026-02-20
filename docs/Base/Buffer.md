# <[Base](./overview.md)/[Buffer](../../src/Base/Buffer.ahk)>

- [Overview](#overview)
- [Size of AHK Numbers](#size-of-ahk-numbers)
- [Creating Buffers](#creating-buffers)
- [Move a ClipboardAll Into Your Clipboard](#move-a-clipboardall-into-your-clipboard)

## Overview

A few methods for `Buffer` and its subclasses, especially for their creation.

This file also includes `Buffer.SizeOf()`, which determines the size of the
built-in AHK number types such as `Int` or `UChar`.

Many of the read/write operations common for buffers are implemented in
[<Interfaces/IBuffer>](../Interfaces/IBuffer.md).

## Size of AHK Numbers

A simple utility to determine the size of an AHK number type in bytes.

```ahk
Buffer.SizeOf("UInt")  ; 4
Buffer.SizeOf("Short") ; 2

; supports pointers with `*` and `p` suffix
Buffer.SizeOf("Char*") ; A_PtrSize
```

## Creating Buffers

These cover some very common ways of filling a buffer, such as from the
contents of a file, memory section, or from a string.

```ahk
; from memory address and size
Buf := Buffer.FromMemory(Ptr, Size)

; buffer filled with the given string
Buf := Buffer.OfString("Hello, world!", "UTF-16")

; an AHK number
Buf := Buffer.OfNumber("UInt", 42)

; contents of a file
Buf := Buffer.FromFile("myFile.txt")
```

## Move a ClipboardAll Into Your Clipboard

Use `.ToClipboard()` to move the contents of the ClipboardAll into your
system clipboard. This is generally equivalent to `A_Clipboard := CB`

```ahk
ClipboardAll(Ptr, Size).ToClipboard()
```
