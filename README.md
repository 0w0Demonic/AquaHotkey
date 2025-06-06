
# AquaHotkey

*Class Prototyping Library for AutoHotkey v2.*

```
    o         /|    .   *
.      0  (  / |  ,.       ,-.         .
 .  *      `/._|,(_o\ \  \  ,-\    .     *
        (_.'   l_    \ `-`\ `-´\     o
```

## Overview

```ahk
"Hello, World!".SubStr(1, 7).Append("AquaHotkey!").MsgBox()
```

AquaHotkey is a powerful and intuitive library for AutoHotkey v2 that lets you
extend built-in types like `String`, `Array`, and even functions, using a clean,
class-based interface. With just a few lines of code, you can make built-in
types behaves exactly how you want.

### Example: Define New Array Properties

```ahk
class ArrayExtensions extends AquaHotkey {
    class Array {
        IsEmpty => (!this.Length)
    }
}

Arr := []
MsgBox(Arr.IsEmpty) ; true
```

## Key Features

- **Extend Built-In Types Easily**:

  Add properties and methods to native types like `String` or `Array` as if
  they were your own classes.

- **Redefine the Rules**:

  AquaHotkey helps you write elegant, expressive and modern code, tailored to
  your own needs.

- **Modular Extension Packages**:

  Organize your extensions into module classes and `#Include` them when needed.

- **Polished Built-In Extensions**:

  Comes with its own expressive standard library built using class prototyping.
  See [features](#list-of-features)

## Getting Started

### Installation

1. Clone the repository:

   ```sh
   git clone https://www.github.com/0w0Demonic/AquaHotkey.git
   ```

2. Include `AquaHotkey.ahk` in your script:

   ```ahk
   #Requires AutoHotkey >=v2.0.5
   #Include  path/to/AquaHotkey.ahk
   ```

Consider placing the repository into your user library path
(`%A_Documents%/AutoHotkey/lib`) for much easier access from your scripts.

```ahk
#Include <AquaHotkey>
```

### Using AquaHotkeyX

Alongside the core `AquaHotkey`, the library also provides `AquaHotkeyX` - a
complete, modular extension library built on top of it.

`AquaHotkeyX` gives you batteries-included enhancements for most of the built-in
types, and much more. It explores some very interesting patterns made possible
by class prototyping, especially **long method chains** and **fluent APIs**
inspired by functional programming.

```ahk
#Include <AquaHotkeyX>
```

This gives you access to the full standard library in one line (recommended).

If you prefer a lighter setup, you can selectively include specific modules:

```ahk
#Include <AquaHotkey>

#Include path/to/AquaHotkey/src/
  #Include Builtins/Array.ahk
  #Include Builtins/Map.ahk
#Include %A_ScriptDir% ; change back the "working directory"
```

The modules inside the standard library have no mutual dependencies, that makes
it relatively easy to pick what features you want to have in your script.

### How to extend types

#### Step 1: Create a Subclass

```ahk
class MyExtensions extends AquaHotkey {
    class Integer {

    }
}
```

#### Step 2: Add Your Own Extensions

```ahk
class MyExtensions extends AquaHotkey {
    class Integer {
        TimesTwo() {
            return (this * 2)
        }
    }
}
```

#### Step 3: Done!

```ahk
Four := 2.TimesTwo()
MsgBox(Four)
```

For more detailed information, see [class prototyping](./docs/about-class-prototyping.md).

---

## Examples

### Extending `String`

```ahk
class StringExtensions extends AquaHotkey {
    class String {
        FirstCharacter() {
            return SubStr(this, 1, 1)
        }
    }
}

"foo".FirstCharacter() ; "f"

```

### Extending Functions

```ahk
class FunctionExtensions extends AquaHotkey {
    class MsgBox {
        static Info(Text?, Title?) {
            return this(Text?, Title?, 0x40)
        }
    }
}

MsgBox.Info("Hello, world!")
```

---

### Modular Packages

One of the most elegant ways to get the most out of this library is to split
your extensions into separate, reusable class files:

```ahk
#Include MyStringExtensions.ahk
#Include MyGuiExtensions.ahk
```

## List of Features

### Function Chaining

Inspired by Elixir's `|>`, AquaHotkey lets you chain function calls to improve
readability and structure.

**Implicit Function Chaining**:

```ahk
MyVariable.DoThis().DoThat("foo").MsgBox()
```

**Explicit Function Chaining**:

```ahk
MyVariable.o0(Foo.Bar)
          .o0(Baz)
          .o0(MsgBox)
```

### Lazy-Evaluated Streams

Write expressive, efficient data transformations with lazy evaluation:

```ahk
MyArray := [13, 12, 3, -4, 2]
Result := MyArray.Stream()
                 .RetainIf((Value) => (Value > 10))
                 .Map((Value) => (Value * Value))
                 .Sum()
```

**AutoHotkey Alpha**:

Streams look especially pretty after the introduction of function declarations
in v2.1-alpha.3:

```ahk
#Requires AutoHotkey >=v2.1-alpha.3
MyArray := [13, 12, 3, -4, 2]

Result := MyArray.Stream().RetainIf(
    IsGreaterThan10(Num) {
        return (Num > 10)
    }
).Map(
    Squared(Num) {
        return (Num * Num)
    }
).Sum()
```

### Optional Type

An expressive alternative to `if`-statements when dealing with maybe-values:

```ahk
Optional("Hello world!")
        .RetainIf(InStr, "H")
        .IfPresent(MsgBox)
        .OrElseThrow(ValueError, "no value present!")
```

**AutoHotkey Alpha**:

```ahk
#Requires AutoHotkey >=v2.1-alpha.3
Optional("Hello, world!").RetainIf(
    ContainsLetterH(Str) {
        return InStr(Str, "H")
    }
).IfPresent(
    Message(Str) {
        MsgBox(Str)
    }
).IfAbsent(
    ThrowError() {
        throw ValueError("no value present!")
    }
)
```

### DLL File Interface

Call native DLL functions easily and safely:

```ahk
class CStdLib extends DLL {
    static FilePath => "msvcrt.dll"
    
    static TypeSignatures => {
        sqrtf:  "Float, Float",
        malloc: ["UPtr", "Ptr"],
        foo:    [117, "Int", "UInt"] ; ordinal 117
    }
}
CStdLib.sqrtf(9.0) ; 3.0
```

### COM Object Interface

Interact with COM objects in a structured and modern way, wrapped nicely into
a class:

```ahk
class InternetExplorer extends COM {
    static CLSID => "InternetExplorer.Application"
    
    static MethodSignatures => {
        ExampleMethod: [9, "Double", "UInt"]
    }
    
    __New() {
        this.Visible := True
        this.Navigate("https://www.autohotkey.com")
    }

    class EventSink extends ComEventSink
    {
        DocumentComplete(ieEventParam, &URL)
        {
            MsgBox(this.Document.Title)
            this.Quit()
            return
        }
    }
}
```

## More Features

Check out the [API Overview](./docs/api-overview.md) for the full list of
features.

## About

Made with love and lots of caffeine.

- 0w0Demonic
