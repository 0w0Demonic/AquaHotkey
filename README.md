# AquaHotkey

```
    o         /|    .   *
.      0  (  / |  ,.       ,-.         .
 .  *      `/._|,(_.\ \  \  ,-\    .     *
        (_.'   l_    \ `-´\ `-´\     o
```

## What is AquaHotkey?

AquaHotkey is a *class-prototyping* library for AutoHotkey v2.

It extends built-in types such as `Array`, `String`, and `Map` with custom methods and properties. You define these extensions in classes declaratively, instead of calling `.DefineProp()` manually.

Create an extension class:

```ahk
#Requires AutoHotkey v2
#Include <AquaHotkey\AquaHotkey>

class StringUtil extends AquaHotkey {
    class String {
        SubStr(Idx, Len?) => SubStr(this, Idx, Len*)
        Append(Str)       => (this . Str)
        MsgBox()          => MsgBox(this)
    }
}
```

The nested `StringUtil.String` class targets the built-in `String` type.

When the script loads, AquaHotkey copies the methods and properties from the extension class into the target prototype. After that, every string can use these methods.

```ahk
; "Hello, AquaHotkey!"
"Hello, World!".SubStr(1, 7).Append("AquaHotkey!").MsgBox()
```

## Quick Start

Clone this repository into one of the [lib folders](https://www.autohotkey.com/docs/v2/Scripts.htm#lib):

```batch
git clone https://www.github.com/0w0Demonic/AquaHotkey "%USERPROFILE%\Documents\AutoHotkey\lib\AquaHotkey"
```

Alternatively, use [Aris](https://github.com/Descolada/Aris):

```ahk
aris install AquaHotkey
```

---

Finally, include the library in your script:

```ahk
  #Requires AutoHotkey v2
  #Include <AquaHotkey>
; #Include <AquaHotkeyX> ; extra features (see below)
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

Many programming languages provide utility methods on their standard types. For example, JavaScript arrays include methods such as `.map()`, `.includes()` and `.forEach()`.

AutoHotkey allows similar extensions through `.DefineProp()`:

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

This approach works, but each methods requires lots of knowledge of AutoHotkey's prototype system, and boilerplate code for setup.

This is where AquaHotkey comes into play. It replaces this pattern with declarative extension classes.

```ahk
class ArrayUtils extends AquaHotkey {
    class Array {
        ForEach(Action) { ... }
        Contains(Value) { ... }
    }
}
```

These new methods are available everywhere after the extension class loads.

```ahk
Arr := Array(1, 2, 3)
Arr.ForEach(MsgBox)    ; 1, 2, 3
Arr.Contains(2)        ; true
```

## Why Use AquaHotkey?

### Extend Existing Types

Add your favorite features from other programming languages with minimal setup. Essentially, you always have one additional programming style up your sleeve.

For example, instead of:

```ahk
ToString(Val) {
    if (Val is Object) {
        ...
    } else if (Val is Array) {
        ...
    } ...
}
```

You can attach behavior directly to the types that use it.

```ahk
class ToString extends AquaHotkey {
    class Object { ToString() { ... } }
    class Array  { ToString() { ... } }
    ...
}

{ foo: "bar" }.ToString() ; e.g. "{ foo: bar }"
```

In addition, the version written with AquaHotkey stays extensible. You simply implement your own `.ToString()` when writing a new class, instead of handling it in one giant function.

### Reorganize Code

If you *want* to reorganize your code in a certain way, you probably *can*.

Instead of:

```ahk
MsgBox(StrReverse(FileRead(Filepath)))
```

You can write:

```ahk
Filepath.FileRead().Reverse().MsgBox()
```

### Compose Features

Each extension class provides one feature. Combine only the features that your script requires.

```ahk
#Include <Collections/ArrayContains>
#Include <Collections/ArraySort>
#Include <String/Trim>
```

### Extend Third-Party Libraries

Extension classes work with any class or function. This includes built-ins, but also things that you and other people wrote.

Add methods to third-party libraries without modifying their source code or creating derived classes.

```ahk
#Include <SomeJsonLib>
class JsonUtils extends AquaHotkey {
    class Any {
        DumpToJson() => ...
    }
    class String {
        ParseJson() => ...
    }
}
```

### Optional Features

Each feature is represented by a class.

You can test whether a feature is available with `IsSet()`.

```ahk
if (IsSet(ArrayContains)) {
    MsgBox( Arr.Contains(Value) )
}
```

It keeps features distributed as separate files that you can import whenever you need them.

### A Powerful Runtime

AquaHotkey consists of two parts:

- the extension framework
- a standard runtime built with that framework

A quick overview:

#### String Utils

```ahk
"The quick brown fox jumps over the lazy dog"
    .From("quick").Until("fox")
    .ToUpper() ; ==> "QUICK BROWN FOX"
```

#### Universal `.ToString()` Method

```ahk
John := { Age: 22, Friends: ["Bob", "Sophie"] }

; convert to string
John.ToString() ; ==> "{ Age: 22, Friends: [Bob, Sophie] }"
```

#### Assertions

```ahk
Str := "str"
Str.Assert(Eq("str"))
```

#### Pattern Matching

```ahk
; pattern matching
Person := { Age: Integer, Friends: String[] }
John.Is(Person) ; true

; as assertion
Str.AssertType(String)
```

#### Collections and Enumerable Processing

```ahk
; generic collections
Arr := Number[](1, 2, 3, 4, 5)
Arr.Push("not a number") ; TypeError!

; immutable collections
Arr := ImmutableArray(1, 2, 3)

; sequences, aggregation
"a b c a a b".CaptureAll("\w+").Stream().Frequency()
; ==> Map { a: 3, b: 2, c: 1 }

; natural ordering, sorting, comparator functions
[34, 1, -3, unset, 12].Sort( Comparator.By(Self).NullsFirst() )
```

#### Data Handling

```ahk
; URIs
Uri("https://www.example.com").Resolve("/path/to/file.html").Run()

; binary serialization
FileOpen("out.bin", "w").WriteObject({ FirstName: "John", LastName: "Doe" })
FileOpen("out.bin", "r").ReadObject() ; ==> { FirstName: "John", LastName: "Doe" }

; JSON parser + bindings
"[1, 2, 3, 4]".ParseJson(Integer[]) ; ==> Array<Integer>[1, 2, 3, 4]
{ Value: 42 }.ToJson() ; ==> '{"Value":42}'

; Optional/error handling
Result := Arr.Find(IsInteger).OrElse("(not found)")

Div(a, b) => (a / b)
Div.TryCall(0, 0).OnFailure((*) => MsgBox("failed."))
```

For a quick overview, see [API Overview](/docs/api-overview.md).

## About

Made with love and lots of caffeine.

- 0w0Demonic
