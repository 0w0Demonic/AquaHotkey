
# AquaHotkey

*Class Prototyping Library for AutoHotkey v2.*

```
    o         /|    .   *
.      0  (  / |  ,.       ,-.         .
 .  *      `/._|,(_o\ \  \  ,-\    .     *
        (_.'   l_    \ `-`\ `-´\     o
```

```ahk
"Hello, World!".SubStr(1, 7).Append("AquaHotkey!").MsgBox()
```

## Introduction

### Rewrite Built-In Classes the Way You Like

> *Make AutoHotkey match your own style and needs. Clean, elegant, awesome.*

AquaHotkey is a *language hack kit* designed to:

- Rewrite built-in types like `String` and `Array` exactly how you want
  them to be.
- Inject methods, properties - anything - directly into native classes.

---

**Example - Array Utility Functions**:

```ahk
class ArrayUtils extends AquaHotkey
{
    class Array {
        ; Calls a function `Action` for each element in the array.
        ForEach(Action) {
            for Value in this {
                Action(Value)
            }
        }

        ; Returns the sum of numbers in the array.
        Sum() {
            Total := 0
            for Value in this {
                Total += Value
            }
            return Total
        }

        ; makes the array use "false" as its default value
        Default := false
    }
}

; Displays 1 through 5 as message box
Array(1, 2, 3, 4, 5).ForEach(MsgBox)

Array(5, 23, 1).Sum() ; 29

Arr := [12, unset, "foo"]
Arr[2] ; false (`.Default` value)
```

---

### Design Philosophy: Make AHK Your Own Thing

AquaHotkey builds on a single but powerful idea:

> How can I make my own experience with AutoHotkey more convenient?

Think of AquaHotkey as your own personal meta-programming toolkit. Something
that lets you customize the language in a way that hasn't been possible before.

You don't need to start from scratch, though. The repo contains my own
implementation `AquaHotkeyX`, which takes lots of inspiration from functional
programming constructs, exploring some fancy - sometimes questionable - new
behavior made possible by this library. See [features](#using-aquahotkeyx)

## Workflow

Imagine that across your script, you have to repeatedly use lots of
`StrReplace()`. One really convenient solution would be to make `StrReplace()`
its own method to cut down on boilerplate code, like this:

```ahk
class StringUtils extends AquaHotkey {
    class String {
        Rep(Pattern, Replacement) {
            return StrReplace(this, Pattern, Replacement)
        }
    }
}

Str := "Hello, world!".Rep("l,", "p").Rep("d", "m").Rep("!", "?")
```

Feels much better, right?

---

The most elegant thing about this library is its modularity. Take your
new `StringUtils` class - which was originally designed as a quick fix - and
move it into a separate file. This way, you can *reuse it anywhere you like*.

```ahk
#Include <StringUtils> ; awesome.
#Include <ArrayUtils>  ; here some more utility...
```

---

Another situation where this is useful is when writing generic functions that
have to handle many different types. In the case of `ToString()`, this gets
messy really fast:

```ahk
ToString(thing) {
    if (thing is Number) {
        return Format("{:0.2f}", this)
    } else if (thing is String) {
        return '"' . thing . '"'
    } else if (thing is Array) {
        ...
    } else if (thing is Map) {
        ...
    }
}
```

This scales horribly when you want to support more types.
With AquaHotkey's prototyping, we just move the responsibility to the classes
themselves:

```ahk
class String {
    ToString() => '"' . this . '"'
}

class Number {
    ToString() => Format("{:0.2f}", this)
}

class Array {
    ToString() {
        Result := "["
        for Value in this {
            if (A_Index - 1) {
                Result .= ", "
            }
            Result .= Value.ToString() ; use `.ToString()` recursively
        }
        Result .= "]"
        return Result
    }
}

class Map {
    ToString() {
        ...
    }
}
```

This makes it extremely easy to reason about the data type of the variable,
and to separate logic between the different data types.

## Create Anything You Want

With special classes such as `AquaHotkey_Backup` and `AquaHotkey_MultiApply`,
you can make pretty much anything you'd ever want. AquaHotkey goes to great
lengths to be fail-fast, reliable, consistent, and to support even the most
ridiculous things that you throw at it.

- **Make Array/Map Use `false` as Default Return Value**

    ```ahk
    class DefaultValueFalse extends AquaHotkey {
        class Array {
            Default := false
        }

        class Map {
            Default := false
        }
    }
    ```

- **Make Changes to Multiple Unrelated Classes**

    ```ahk
    class Buttons extends AquaHotkey_MultiApply {
        static __New() => super.__New(Gui.Button, Gui.Radio, Gui.CheckBox)

        Click() {
            static BM_CLICK := 0x00F5
            SendMessage(BM_CLICK, 0, 0, this)
        }
    }
    ```

- **Preserve and Extend on Original Behavior**

    ```ahk
    class GuiBackup extends AquaHotkey_Backup {
        static __New() => super.__New(Gui)
    }

    class GuiUtils extends AquaHotkey {
        class Gui {
            __New(Args*) {
                MsgBox("A GUI was created!")
                ; call the previous implementation of `__New()`
                return (GuiBackup.Prototype.__New)(this, Args*)
            }
        }
    }
    ```

## Installation

1. Clone the repository:

   ```sh
   git clone https://www.github.com/0w0Demonic/AquaHotkey.git
   ```

2. Include `AquaHotkey.ahk` in your script:

   ```ahk
   #Requires AutoHotkey >=v2.0.5 <v2.2
   #Include  path/to/AquaHotkey.ahk

   ; more ideally, put the repo into one of the standard lib paths:
   #Include <AquaHotkey>
   ```

---

### Advanced Installation

If you're frequently using the library to define property extensions which are
packed into their own on-demand packages, consider using the following setup:

1. Create stub files `AquaHotkey.ahk` and `AquaHotkeyX.ahk` that each contain a
   single `#Include` pointing to the real source inside the repository folder:

    ```ahk
    ; AquaHotkey.ahk (stub)
    #Include "%A_LineFile%/../AquaHotkey/AquaHotkey.ahk"
  
    ; AquaHotkeyX.ahk (stub)
    #Include "%A_LineFile%/../AquaHotkey/AquaHotkeyX.ahk"
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

With this layout, both AquaHotkey and any dependant packages can be referenced
using the standard angle brackets syntax:

```ahk
#Include <AquaHotkey> ; much better.
#Include <StringUtils>
#Include <ArrayUtils>
```

## AquaHotkeyX - Batteries-Included

Enjoy a standard library using fluent, expressive extensions inspired
by functional programming languages and syntax sugar.

```ahk
#Include <AquaHotkeyX>
```

If you prefer a lighter setup, you can selectively include specific modules:

```ahk
#Include <AquaHotkey>

#Include path/to/AquaHotkey/src/
  #Include Builtins/Array.ahk
  #Include Builtins/Map.ahk
#Include %A_ScriptDir% ; change back the "working directory"
```

---

### List of Features

- **Function Chaining**

    ```ahk
    DoThis(Something) {
        ...
    }

    DoThat(Something, Str) {
        ...
    }
    
    ; MsgBox(DoThat(DoThis(Foo), "bar"))
    Foo.DoThis().DoThat("bar").MsgBox()
    ```

- **Rudimentary `Range()` Function**

    For all the Python lovers out there.

    ```ahk
    MsgBox("Let's count!")
    for Val in Range(10) {
        MsgBox(Val)
    }
    ```

- **Exciting New Array Methods**
  
    ```ahk
    ; Map {
    ;     "A" -> ["Apple"],
    ;     "B" -> ["Banana"],
    ;     "K" -> ["Kiwi"]
    ; }
    Array("Apple", "Banana", "Kiwi").GroupBy((Str) => SubStr(Str, 1, 1))

    ; ["A", "p", "p", "l", "e", "B", "a", ...]
    Array("Apple", "Banana", "Kiwi").FlatMap(StrSplit)
    ```

- **Lazy-Evaluated Streams**

    The thing I'm most proud of - enjoy lazy data transformation
    inspired by Java Streams and .NET LINQ:

    ```ahk
    ; <4, 6, 234, 56>
    Array(4, 6, 234, 56).Stream()

    ; <(1, 72), (2, "foo"), (3, 9), (4, "bar")>
    Array(72, "foo", 9, "bar").Stream(2)
    ```

    AutoHotkey v2.1-alpha.3 makes this much more elegant and easier to use:

    ```ahk
    Array(34, 7, "foo", 9, "bar")
        .Stream(2) ; <(1, 34), (2, 7), (3, "foo"), (4, 9), (5, "bar")>
        .Map((Index, Value) {
            return Format("Array[{}]: {}", Index, Value)
        })
        .Join(", ")
        .MsgBox()
    ```

    Works with *anything* that is enumerable - even strings, if you really want.

    ```ahk
    Range(1000).Stream().RetainIf(IsEven).Sum().MsgBox()

    ; "72 101 108 108 111 44 32 119 111 114 108 100 33"
    "Hello, world!".Stream().Map(Ord).Join(" ")
    ```

    ...or files.

    ```ahk
    for Index, Line in FileOpen("message.txt") {
        MsgBox(Line)
    }

    FileOpen("litany.txt").Stream()
            .RetainIf(ContainsSomething)
            .ForEach(DoSomething)
    ```

- **Optional Type**

    A data type seen in functional programming that contains an optional value.

    ```ahk
    Optional("Hello, world!")
            .RetainIf(InStr, "H")
            .IfPresent(MsgBox)
    
    #Requires AutoHotkey >=2.1-alpha.3

    Optional("Hello, world!")
        .RetainIf(ContainsLetterH(Str) {
            return InStr(Str, "H")
        })
        .IfPresent(Output(Str) {
            MsgBox(Str)
        })
    ```

- **Custom Sorting with Comparators**

    Build complex sorting mechanisms through function composition.

    ```ahk
    ; ["banana", "quux", "bar", "foo", "b"]
    Array("apple", "banana", "foo", "b", "bar", "quux").Sort(
            Comparator.Numerical(StrLen).Reversed())
    ```

- **DLL File Interface**

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

- **COM Object Interface**

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

## About

Made with love and lots of caffeine.

- 0w0Demonic
