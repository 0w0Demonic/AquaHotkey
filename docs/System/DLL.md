# DLL

## Overview

The `DLL` class provides an object-oriented interface for dynamically
loading and interacting with DLL files in a clean and structured way.
It automatically loads and frees the library, resolves function addresses
and binds method signatures for type safety.

## Usage

To create a DLL wrapper, define a subclass and specify the target DLL using
the `static FilePath` property:

```ahk
class User32 extends DLL {
    static FilePath => "user32.dll"
}
```

This automatically resolves all named exports of `user32.dll` by memory
address when the class is initialized.

## Defining Function Signatures

Function parameters can be defined explicitly via:

1. Assigning signatures dynamically:

```ahk
User32.CharUpper := ["Str", "Str"]
```

2. Defining them inside the subclass:

```ahk
class User32 extends DLL {
    static FilePath => "user32.dll"

    static TypeSignatures => {
        MessageBox: ["Ptr", "Str", "Str", "UInt", "Int"],
        CharUpper: "Str, Str"
        ; ...
    }
}
```

### Supported Data Types

- AHK number types (`"UInt"`, etc.)
- Structures (v2.1-alpha.3+)
- Buffer-like objects (really anything with `Ptr` and `Size`)

## Function Resolution Behavior

- If a method is **directly defined**, it is used immediately.
- If a method is **not available**, the class automatically 
  tries **appending "W" (Wide)**.
- Once resolved, the function address is retroactively added as property,
  improving performance for repeated calls.

## Using Hidden Ordinal Functions

The `DLL` class supports calling undocumented functions that are **only
accessible via ordinal numbers** rather than exported names. The functions
are automatically loaded whenever an entry in the `TypeSignatures` property
starts with a **numeric value** (indicating an ordinal).

```ahk
class UXTheme extends DLL {
    static FilePath => "uxtheme.dll"

    static TypeSignatures => {
        SetPreferredAppMode: [135, "Int"],
        FlushMenuThemes:     [136]
    }
}
```

Note that **hidden functions are undocumented** and may very between Windows
versions.

## Limitations

Each subclass can only reference a single DLL.

Further subclasses cannot override properties:

- `static FilePath`
- `static TypeSignatures`
- `static Ptr`

**Example Usage**:

```ahk
class Kernel32 extends DLL {
    static FilePath => "kernel32"

    static TypeSignatures {
        GetTickCount: ["UInt"]
    }
}

TickCount := Kernel32.GetTickCount()

; defining a function signature
Kernel32.Sleep := ["UInt"]

; sleep for one second
Kernel32.Sleep(1000)
```
