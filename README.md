# AquaHotkey

```
    o         /|    .   *
.      0  (  / |  ,.       ,-.         .
 .  *      `/._|,(_.\ \  \  ,-\    .     *
        (_.'   l_    \ `-´\ `-´\     o
```

## What is AquaHotkey?

AquaHotkey is a *class-prototyping* library that lets you easily rewrite
built-in types like `Array`, `String` or `Map` to match your own style
and preferences.

```ahk
"Hello, World!".SubStr(1, 7).Append("AquaHotkey!").MsgBox()
```

Setting up this one-liner to work is really easy! Just do the following:

```ahk
#Include <AquaHotkey>

class StringUtil extends AquaHotkey {
    class String {
        SubStr(Start, Length?) {
            ; `this` - a string instance
            return SubStr(this, Start, Length*)
        }
        
        Append(Str) {
            return (this . Str)
        }
        
        MsgBox() {
            MsgBox(this)
        }
    }
}
```

What you see is an *extension class* that contains custom methods `.SubStr()`,
`.Append()` and `.MsgBox()` for the type `String`. As soon as the script loads,
the extension class "pastes" its contents into the specified target, in this
case `String`.

## Documentation

Getting started:

- [Installing](/docs/installation.md)
- [Beginner's Guide](/docs/basics.md)
- [Advanced Concepts](/docs/advanced.md)

Optional stuff:

- [Expert Concepts](/docs/expert.md)
- [Advanced Installation](/docs/installation.md)

Also see:

- [How does this work?](#a-short-insight-into-class-prototyping)
- [AquaHotkeyX](#aquahotkeyx)

## Why this Matters

With regular AutoHotkey libraries, you usually end up with piles of utility
functions. you must remember which function works on which type, invent naming
rules, or write big checks like "if this is a string, else if this is an
array ...". Works, but it becomes clunky very quickly.

AquaHotkey is a framework for "class prototyping" in AutoHotkey v2 - the ability
to add properties and methods to built-in types like `String` and `Array`.

Let's say we want to add some simple array methods to reuse across your
script. Normally, you'd start by calling `Array.Prototype.DefineProp(...)`, and
defining everything as bunch of global functions. Like this:

```ahk
Array.Prototype.DefineProp("ForEach", { Call: Array_ForEach })
Array.Prototype.DefineProp("Contains", { Call: Array_Contains })

Array_ForEach(this, Action, Args*) {
    GetMethod(Action)
    for Value in this {
        Action(Value?, Args*)
    }
    return this
}

Array_Contains(this, ExpectedValue) {
    for Value in this {
        if (Value == ExpectedValue) {
            return true
        }
    }
    return false
}
```

This works, but doing it manually is difficult, tedious, and very error-prone.

In AquaHotkey, all of this is done declaratively using "extension classes"
that specify which properties should added to which targets.

```ahk
class ArrayUtils extends AquaHotkey {
    class Array {
        ForEach(Action) { ... }
        Contains(Value) { ... }
    }
}
```

The greatest advantage of this is being exposed to regular class-based
syntax. Instead of implementing everything as global functions, you can write
them as methods of the target class, which is much more intuitive and feels a
lot more natural.

Instead of huge "do-everything" functions, you can write break up things into
smaller parts. Write a new class, make a few changes, done. AquaHotkey will do
the heavy lifting of ensuring your changes land where they need to be:

```ahk
class ToString extends AquaHotkey {
    class Number {
        ToString() => String(this)
    }
    class String {
        ToString() => this
    }
    class Array {
        ToString() {
            Result := "["
            for Value in this {
                ; ...
            }
            Result .= "]"
            return Result
        }
    }
    class Object {
        ToString() { ... }
    }
}
```

Strings get string methods, arrays get array methods, and so on. The objects
themselves "know" what to do.

We've just successfully made `String(Value)` a feature that works on (almost)
all data types.

This type of meta-programming uncovers a beautiful, but yet still vastly
unexplored part of AutoHotkey, and it's my job to be your tour guide.
If you're interested, you can check out [AquaHotkeyX](#aquahotkeyx), where
these patterns are taken to their extreme.

### Massively Reusable

When you're done writing a class, you can put it into a separate file, and
`#Include` it across multiple scripts.

**StringUtils.ahk**:

```ahk
class StringUtils extends AquaHotkey {
    class String {
        Rep(Pat, Rep) => StrReplace(this, Pat, Rep)

        Contains(Pat) => InStr(tihs, Pat)
    }
}
```

**MyScript.ahk**:

```ahk
#Include <StringUtils>

Str := "Hello, world!".Rep("l,", "p").Rep("d", "m").Rep("!", "?")
"foo".Contains("o") ; true
```

You can start very small, one quick fix other another. And sooner than you
think, it'll grow into your own language on top of AutoHotkey.

### A Short Insight Into Class Prototyping

AutoHotkey v2 is a prototype-based language, exactly like JavaScript. Everything
has an internal link to another object called its prototype, and so on,
forming a "prototype chain".

Example - the number 42:

```ahk
42
`- Integer.Prototype
   `- Number.Prototype
      `- Primitive.Prototype
         `- Any.Prototype
```

More interestingly, you can modify these prototypes to change the behaviour of
any deriving object.

The concept behind class prototyping is modifying the internal prototype
objects to add or change existing properties and methods:

```ahk
; add a `.Length` property for strings
({}.DefineProp)(String.Prototype, "Length", { Get: StrLen })
```

We've just successfully added a `Length` property to `String.Prototype`, which
is the prototype object of all strings.

You can now use the `Length` property on strings:

```ahk
MsgBox("foo".Length) ; 3
```

Thanks to AquaHotkey, this is no longer tedious manual work. You can entirely
avoid dealing with property descriptors, because everything happens
declaratively, and with simple "class syntax".

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

For a quick overview, see [API Overview](/docs/api-overview.md).

## About

Made with love and lots of caffeine.

- 0w0Demonic
