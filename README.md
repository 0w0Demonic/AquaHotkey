# AquaHotkey

```
    o         /|    .   *
.      0  (  / |  ,.       ,-.         .
 .  *      `/._|,(_.\ \  \  ,-\    .     *
        (_.'   l_    \ `-´\ `-´\     o
```

## What is AquaHotkey?

AquaHotkey is a *class prototyping library* for AutoHotkey v2 that lets you
easily rewrite built-in types like `Array`, `String` and `Map` to match your
own style and preferences.

```ahk
"Hello, World!".SubStr(1, 7).Append("AquaHotkey!").MsgBox()
```

- Declaratively add and rewrite properties of built-in types
- Make AutoHotkey match your style and needs. Clean, elegant, awesome.

### How it Works

The overall concept behind class prototyping is simple: It involves adding
or modifying properties of existing classes at runtime.

```ahk
; add a `.Length` property for strings
({}.DefineProp)(String.Prototype, "Length", { Get: StrLen })
```

The hard part is making this *easy*. AquaHotkey's goal is to make class
prototyping as straightforward and fun as possible.

Write a new class, make a few changes, done. AquaHotkey will do the rest of
the job, ensuring your changes land where they need to be.

```ahk
class StringLength extends AquaHotkey {
    class String {
        Length => StrLen(this)

        Contains(Pattern)   => InStr(this, Pattern)
        Sub(Start, Length?) => SubStr(this, Start, Length?)
    }
}

"foo".Length        ; 3
"foo".Contains("o") ; true
"foo".Sub(2, 2)     ; "oo"
```

For more insight on how this library evolved over time, check out
[About AquaHotkey](./rambling/00_about.md).

### Massively Reusable

Once you're done making changes, you can move your AquaHotkey class into a
separate file and `#Include` them across scripts whenever you need them.

Write once, use everywhere.

**StringUtils.ahk**:

```ahk
class StringUtils extends AquaHotkey {
    class String {
        Rep(Pat, Rep) => StrReplace(this, Pat, Rep)
    }
}
```

**MyScript.ahk**:

```ahk
#Include <StringUtils>

Str := "Hello, world!".Rep("l,", "p").Rep("d", "m").Rep("!", "?")
```

---

## Installation

To get started, clone this repository and (preferably) put it in one of the
AutoHotkey [lib folders](https://www.autohotkey.com/docs/v2/Scripts.htm#lib).

```ahk
#Requires AutoHotkey v2
#Include <AquaHotkey>
; #Include path/to/AquaHotkey.ahk
```

### Advanced Setup

This is optional, but will probably save you lots of work in the long run.
With this setup, both AquaHotkey and anything else that depends on it can
be imported with `<library>` syntax.

```ahk
#Include <AquaHotkey>
#Include <StringUtils>
#Include <ArrayUtils>
```

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
    lib/
    |
    |- AquaHotkey/
    |  |- AquaHotkey.ahk  <-- the actual source (#Include these)
    |  `- AquaHotkeyX.ahk
    |
    |
    |- AquaHotkey.ahk     <-- stub files (see above)
    |- AquaHotkeyX.ahk
    |
    |
    |- StringUtils.ahk    <-- other libs
    `- ArrayUtils.ahk
    ```

## Documentation

- [Beginner's Guide](./docs/basics.md)
- [Advanced Concepts](./docs/advanced.md)
- [Expert Concepts](./docs/expert.md)
- [AquaHotkeyX](#aquahotkeyx)

## AquaHotkeyX

A unique and modern standard batteries-included library that builds on top
of AquaHotkey.

- Heavily chainable method calls
- Extensive use of functional programming patterns
- Designed for maximal elegance and conciseness

```ahk
#Requires AutoHotkey >=v2.0.5
#Include <AquaHotkeyX>

; Map { 4: ["kiwi", "lime"], 5: ["apple"], 6: ["banana"] }
Array("banana", "kiwi", "apple", "lime").Collect(Collector.Group(StrLen))

; <[1, 2, 3], [2, 3, 4], [3, 4, 5]>
Range(5).Stream().Gather(Gatherer.WindowSliding(3))
```

For a quick overview, see [API Overview](./docs/api-overview.md).

## Design Philosophy

My opinionated belief:
> *A perfect tool is one you don't even notice you're using.*

### Goals

1. **Simplicity**

   The framework should be intuitive and easy to grasp conceptually.

2. **Universal**

   Handles anything that you throw at it, without having to think too
   much about what's going on below the hood.

3. **Bulletproof Reliability**

   No wiggle room for unexpected behavior. Writing this at first was very
   painful, so you can trust I won't let any weird bugs slip through again.

4. **Elegance**

   Designed to be highly concise, composable and elegant.

---

Curious how AquaHotkey actually came to be? Check out
[About AquaHotkey](./rambling/00_about.md) for the background story, design
decisions, and the evolution of the library.

## About

Made with love and lots of caffeine.

- 0w0Demonic
