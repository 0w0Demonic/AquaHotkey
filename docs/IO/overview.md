# Module `<IO>`

- [All Modules](../api-overview.md)

---

- [Module `<IO>`](#module-io)
  - [Overview](#overview)
  - [List of Features](#list-of-features)
  - [FileUtils](#fileutils)
  - [Path](#path)
  - [Serial](#serial)
  - [Serializer](#serializer)

## Overview

Features related to files and directories.

## List of Features

- [FileUtils](./FileUtils.md)
- [Path](./Path.md)
- [Serial](./IO/Serial.md)
- [Serializer](./IO/Serializer.md)

## FileUtils

- [`<IO/FileUtils>`](./FileUtils.md)

Simple file utilities including extensions for `File` and `FileOpen`, and
file streams.

## Path

- [`<IO/Path>`](./Path.md)

Class that represents file paths or URLs.

## Serial

- [`<IO/Serial>`](./Serial.md)

Extensible serialization logic for the [AquaHotkey serializer](#serializer).
This describes the different types of `.Serialize()` and `.Deserialize()`
methods that are used for converting objects from and into their binary
representation.

## Serializer

- [`<IO/Serializer>`](./Serializer.md)

Implements binary serialization for many built-in AHK types and AquaHotkey
collections. Values can be written into buffers or permanently stored in files,
and then completely reconstructed, while keeping identity and object structure.

```ahk
FileOpen("result.txt", "w").WriteObject({ foo: "bar" })
```
