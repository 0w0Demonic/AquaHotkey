# AquaHotkey

```
    o         /|    .   *
.      0  (  / |  ,.       ,-.         .
 .  *      `/._|,(_.\ \  \  ,-\    .     *
        (_.'   l_    \ `-´\ `-´\     o
```

```ahk
"Hello, World!".SubStr(1, 7).Append("AquaHotkey!").MsgBox()
```

## What is AquaHotkey?

AquaHotkey is a *class prototyping library* for AutoHotkey v2 that lets you
rewrite built-in types like `Array`, `String` and `Map` to match your own
style and preferences. Think of it as a meta-programming toolkit to improve
your overall AHK experience and make it more elegant and personalized.

- Add methods directly into native types
- Use clean and modular `#Include` files to organize your code
- Make AutoHotkey match your style and needs. Clean, elegant, awesome.

---

### How it Works - Very Quick Overview

```ahk
class StringLength extends AquaHotkey {
    class String {
        Length => StrLen(this)
    }
}

"foo".Length ; 3
```

As soon as the `StringLength` class is loaded, `String` is injected with a new
`.Length` property. More on that in the [beginner's guide.](./docs/basics.md)

## Documentation

- [Beginner's Guide](./docs/basics.md)
- [Advanced Concepts](./docs/advanced.md)
- [AquaHotkeyX - Batteries Included](#aquahotkeyx---batteries-included)

## Installation

```ahk
#Requires AutoHotkey >=v2.0.5 <v2.2
#Include <AquaHotkey>
```

### Advanced Installation

With this special setup, both AquaHotkey and any dependant packages can be
referenced using the very convenient angle brackets syntax. Like this:

```ahk
#Include <AquaHotkey>
#Include <StringUtils>
#Include <ArrayUtils>
```

If you use this library a lot, this setup will save lots of work in the long
run. Here's how to do it:

1. Create stub files `AquaHotkey.ahk` and `AquaHotkeyX.ahk` that each contain a
   single `#Include` pointing to the real source inside the repository folder:

    ```ahk
    ; ------------- AquaHotkey.ahk (stub)
    #Include "%A_LineFile%/../AquaHotkey/AquaHotkey.ahk"
    ; -------------
  
    ; ------------- AquaHotkeyX.ahk (stub)
    #Include "%A_LineFile%/../AquaHotkey/AquaHotkeyX.ahk"
    ; -------------
    ```

2. Structure your files like this:

    ```txt
    %A_Documents%/AutoHotkey/lib
    |- AquaHotkey/
    |  |- AquaHotkey.ahk  // the actual source (#Include these)
    |  `- AquaHotkeyX.ahk
    |
    |- AquaHotkey.ahk     // your stub files (step 1)
    |- AquaHotkeyX.ahk
    |
    |- StringUtils.ahk    // your custom packages
    `- ArrayUtils.ahk
    ```

## Why This Matters

AutoHotkey's built-in classes are powerful, but you can't easily modify them.

Want to add `.Sum()` to every array? You'll be stuck writing wrapper functions
like this:

```ahk
Array_Sum(Arr) {
    if (!(Arr is Array)) {
        throw TypeError()
    }
    Result := 0
    for Value in Arr {
        Result += (Value ?? 0)
    }
    return Result
}

Array_Sum([1, 2, 3, 4]) ; 10
```

It works, but it's clunky.

Wouldn't it be better to just write:

```ahk
Array(1, 2, 3, 4).Sum() ; 10
```

Feels much better, right?

### Reuse Your Extensions

Move your classes into separate files and include them in your standard
library path.

**StringUtils.ahk**:

```ahk
class StringUtils extends AquaHotkey {
    class String {
        Rep(Pattern, Replacement) {
            return StrReplace(this, Pattern, Replacement)
        }
    }
}

```

**MyScript.ahk**:

```ahk
#Include <StringUtils>
Str := "Hello, world!".Rep("l,", "p").Rep("d", "m").Rep("!", "?")
```

## AquaHotkeyX - Batteries-Included

AquaHotkeyX is a wide collection of extensions built on top of AquaHotkey.

It consists of many extensions for built-in types, as well as many other
features designed for clarity, conciseness and elegance. Stream ops,
array utilities, comparators, optionals, and much more.

```ahk
#Include <AquaHotkeyX>

; Map { 4: ["kiwi", "lime"], 5: ["apple"], 6: ["banana"] }
Array("banana", "kiwi", "apple", "lime").Collect(Collector.Group(StrLen))

; <[1, 2, 3], [2, 3, 4], [3, 4, 5]>
Range(5).Stream().Gather(Gatherer.WindowSliding(3))
```

For a quick overview, see [API Overview](./docs/api-overview.md).

## About

Made with love and lots of caffeine.

- 0w0Demonic
