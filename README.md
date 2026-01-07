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

### What is Class Prototyping?

AutoHotkey v2 is a prototype-based language, exactly like JavaScript. Everything
has an internal link to another object called its prototype, and so on,
forming a "prototype chain".

Example - the number `42`:

```ahk
42
`- Integer.Prototype
   `- Number.Protoype
      `- Primitive.Prototype
         `- Any.Prototype
```

More interestingly, you can modify these prototypes to change the behaviour of
any deriving object:

```ahk
Define := {}.DefineProp

; add a `.Length` property for strings
Define(String.Prototype, "Length", { Get: StrLen })

MsgBox("foo".Length) ; 3
```

Although this method of adding properties and methods has existing for pretty
long and can be found mostly in array/map utility libraries, it's tedious work
when done manually.

This is where AquaHotkey is the perfect tool for you:

### How it Works

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

Arguably the best thing about how everything happens declaratively, and that
it uses plain and simple "class syntax". In most cases, the use of
[descriptors](https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc)
can be fully avoided.

```ahk
...
Contains(Pattern) => InStr(this, Pattern)
```

As you'd expect, the `this` keyword is simply a string instance.

<TODO>
- if you know what you're doing, you can make groundbreaking changes with just
  a few classes and properties
- this library uncovers a huge, beautiful but still vastly unexplored part of
  AutoHotkey, and it's my job for you to explore
</TODO>

### Modular and Massively Reusable

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
