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
; "Hello, AquaHotkey!"
"Hello, World!".SubStr(1, 7).Append("AquaHotkey!").MsgBox()
```

Setting up this one-liner to work is really easy! Just do the following:

```ahk
#Requires AutoHotkey v2
#Include <AquaHotkey>

class StringUtil extends AquaHotkey {
  class String {
    SubStr(Idx, Len?) => SubStr(this, Idx, Len*)
    Append(Str)       => (this . Str)
    MsgBox()          => MsgBox(this)
  }
}
```

What you see is an *extension class* that contains custom methods `.SubStr()`,
`.Append()` and `.MsgBox()` for the type `String`. As soon as the script loads,
the extension class "pastes" its contents into the specified target, in this
case `String`.

## Quick Start

Download the repository, ideally inside one of the
[lib folders](https://www.autohotkey.com/docs/v2/Scripts.htm#lib):

```batch
git clone https://www.github.com/0w0Demonic/AquaHotkey "%USERPROFILE%\Documents\TestFolder\lib\AquaHotkey"
```

Now, you can import the library:

```ahk
  #Requires AutoHotkey v2
  #Include <AquaHotkey>
; #Include <AquaHotkeyX> (extra features --- see below)
```

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

## Core Idea

Coming from other programming languages, there might be a set of methods that
the equivalent class in AutoHotkey might not have. A good example might be
the wide set of methods like `.map()`, `.includes()` and `.forEach()` provided
to arrays in JavaScript.

Because AutoHotkey uses prototype-based objects just like JavaScript, you *can*
define these features yourself with the help of `.DefineProp(...)` and the use
of property descriptors.

```ahk
Array.Prototype.DefineProp("ForEach", { Call: Array_ForEach })

Array_ForEach(this, Action, Args*) {
    GetMethod(Action)
    for Value in this {
        Action(Value?, Args*)
    }
    return this
}
```

This works just fine, if you need only a few simple utility functions, but
doing this manually is tedious, and requires quite a bit of knowledge about
objects in AHK.

In AquaHotkey, all of this is done declaratively using "extension classes"
that each contain the properties and methods that should be added to the
built-in classes.

```ahk
class ArrayUtils extends AquaHotkey {
    class Array {
        ForEach(Action) { ... }
        Contains(Value) { ... }
    }
}
```

After you're done, you can use these new methods anywhere you want!

```ahk
Arr := Array(1, 2, 3)
Arr.ForEach(MsgBox)    ; 1, 2, 3
Arr.Contains(2)        ; true
```

## Why This Matters

### Customizability

One of the main things that AquaHotkey is concerned with is *making things
fun through customization*. It's something that I think is very opinionated,
but pays off very quickly. With this extra expressive layer of expressing
things in code, you can shape AutoHotkey into something that matches your
own mental model. Kind of like your favorite code editor.

It's also great for making interaction with other libraries a lot more
seamless:

```ahk
#Requires AutoHotkey v2
#Include <SomeJsonLibrary>

class JsonUtils extends AquaHotkey {
    class Object {
        ToJson() => Json.Stringify(this) ; object to JSON string
    }
    class String {
        ToJson() => Json.Dump(this) ; JSON string to object
    }
}
```

### Features That Feel "Fundamental" to the Language

With AquaHotkey, you can very easily add features that appear as if they're
fundamental to the language, something that'd otherwise be almost impossible.

As a test, let me show you how to add a universal `.ToString()` method.

```ahk
#Requires AutoHotkey v2

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
themselves "know" what to do. We've just successfully made `String(Value)`
a feature that works on (almost) all data types.

---

This type of meta-programming uncovers a beautiful, but yet still vastly
unexplored part of AutoHotkey, and it's my job to be your tour guide.
If you're interested, you can check out [AquaHotkeyX](#aquahotkeyx), where
these patterns are taken to their extreme.

### Easy to Use

If you know how classes work (you probably should), then learning how to use
this library takes almost no effort at all.

### Modular

Changes that belong to one feature can live together in a single extension
class. That means you can move them into their own file, `#Include` them
when needed, and slowly build up your own collection of reusable language
features.

**StringUtils.ahk**:

```ahk
class StringUtils extends AquaHotkey {
    class String {
        Rep(Pat, Rep) => StrReplace(this, Pat, Rep)

        Contains(Pat) => InStr(this, Pat)
    }
}
```

**MyScript.ahk**:

```ahk
#Include <StringUtils>

Str := "Hello, world!".Rep("l,", "p").Rep("d", "m").Rep("!", "?")
"foo".Contains("o") ; true
```

You can start very small, one quick fix after another. And sooner than you
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

More interestingly, you can modify these prototypes to change the behavior of
any deriving object.

The concept behind class prototyping revolves around making changes to the internal prototype
objects to add properties and methods:

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

Thanks to AquaHotkey, this is no longer tedious manual work.
Everything happens declaratively, and with simple "class syntax".

## AquaHotkeyX

A unique and modern standard batteries-included library that builds on top
of AquaHotkey.

- Heavily chainable method calls
- Extensive use of functional programming patterns
- Designed for maximal elegance and conciseness

```ahk
#Requires AutoHotkey v2
#Include <AquaHotkeyX>

; Map { 4: ["kiwi", "lime"], 5: ["apple"], 6: ["banana"] }
Array("banana", "kiwi", "apple", "lime").Group(StrLen)

; <[1, 2, 3], [2, 3, 4], [3, 4, 5]>
Range(5).Stream().Gather(WindowSliding(3))
```

For a quick overview, see [API Overview](/docs/api-overview.md).

## About

Made with love and lots of caffeine.

- 0w0Demonic
