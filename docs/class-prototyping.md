# Class Prototyping

**TL;DR.**:

- AquaHotkey lets you *inject methods directly into native classes*, so you can
  call them like any normal method.

- It makes many general wrapper functions *obsolete*.
- You can write `Arr.Sum()` instead of `Array_Sum(Arr)`.
- Just create a nested classes inside one that extends `AquaHotkey`,
  and AquaHotkey handles the rest.

## Why This Matters

AutoHotkey’s built-in classes are powerful, but you can't easily modify them.

Want to add `Sum()` to every array? You'll be stuck writing wrapper functions
like this:

```ahk
Array_Sum(Arr) {
    Result := 0
    for Value in Arr {
        Result += Value
    }
    return Result
}
```

It works, but it's clunky.

Wouldn't it be better to just write:

```ahk
Array(1, 2, 3, 4).Sum() ; 10
```

The main idea behind AquaHotkey is to allow you to make these changes possible
without knowing about the rocket science that is AHK's object protocol.

## Getting Started

- **Extend `AquaHotkey`**

    ```ahk
    class ArrayExtensions extends AquaHotkey {
    }
    ```

- **Create a Nested Class Named After Your Target**

    To extend `Array`, define a new nested class `Array`

    ```ahk
    class ArrayExtensions extends AquaHotkey {
        class Array {
        }
    }
    ```

- **Add properties and methods**

    ```ahk
    class ArrayExtensions extends AquaHotkey {
        class Array {
            IsEmpty => (!this.Length)

            Sum() {
                Total := 0
                for Value in this { ; `this` - the array instance
                    Total += Value
                }
                return Total
            }

            static OfCapacity(Cap, Values*) {
                Arr := this(Values*) ; `this` - the `Array` class
                Arr.Capacity := Cap
                return Arr
            }
        }
    }
    ```

- **Done!**

    ```ahk
    Arr := Array.OfCapacity(20, 1, 2, 3, 4)

    MsgBox( Arr.IsEmpty  ) ; false
    MsgBox( Arr.Sum()    ) ; 10
    MsgBox( Arr.Capacity ) ; 20
    ```

## Instance Variable Declarations

You can even define custom fields on built-in types by using simple
declarations:

```ahk
class ArrayExtensions1 extends AquaHotkey {
    class Array {
        Foo := "bar"
    }
}

class ArrayExtensions2 extends AquaHotkey {
    class Array {
        Baz := "quux"
    }
}

Arr := Array()
MsgBox( Arr.Foo ) ; "bar"
MsgBox( Arr.Baz ) ; "quux"
```

- Note: Declaring non-static fields don't work on primitive classes such as
        `Integer`, because they can't own any fields.

> [!CAUTION]
>For `Object` and `Any`, you must declare nonstatic fields using `__Init()` -
>otherwise, your script will crash from infinite recursion.
>
>```ahk
>class ObjectExt extends AquaHotkey {
>    class Object {
>        ; Foo := "bar" <-- don't do this!!!
>
>        __Init() {
>            this.Foo := "bar" <-- do this instead.
>        }
>    }
>}
>```

## Preserving Original Behavior with `AquaHotkey_Backup`

Use the `AquaHotkey_Backup` class to create a snapshot of an existing class's
properties and methods. This lets you safely override functionality while
retaining access to the original implementation.

```ahk
class OriginalGui extends AquaHotkey_Backup {
    static __New() {
        ; Create a snapshot of the Gui class
        super.__New(Gui)
    }
}

class GuiExtensions extends AquaHotkey {
    static __New() {
        (OriginalGui) ; Force the backup class to load before applying changes
        super.__New()
    }
    
    class Gui {
        ; Extend the original Gui constructor
        __New() {
            ; Call the original constructor
            (OriginalGui.Prototype.__New)(this, Args*)

            ; add your code here
            MsgBox("Overridden safely!")
        }
    }
}
```

## Ignoring Specific Nested Classes with `AquaHotkey_Ignore`

Use the special `AquaHotkey_Ignore` marker class to exclude helper or
internal-use classes from AquaHotkey's class prototyping system.

```ahk
class MyProject extends AquaHotkey {
    class Gui {
        ; visible to the prototype system
    }

    class Utils extends AquaHotkey_Ignore {
        ; ignored during property injection
    }
}
```

## Sharing Behavior Access Multiple Classes with `AquaHotkey_MultiApply`

If you want multiple unrelated classes to share behavior without repeating
code, use `AquaHotkey_MultiApply`.

```ahk
class Tanuki extends AquaHotkey {
    class Gui {
        class CommonControls extends AquaHotkey_MultiApply {
            static __New() {
                super.__New(Tanuki.Gui.Button, Tanuki.Gui.CheckBox)
            }
            CommonProp() => MsgBox("Shared by Button and CheckBox!")
        }

        class Button {
            ButtonProp() => MsgBox("I'm a Button!")
        }

        class CheckBox {
            CheckBoxProp() => MsgBox("I'm a CheckBox!")
        }
    }
}
```

This lets you write shared behavior once, and inject it into multiple
components cleanly.

## Class Hierarchy

```txt
Object
`- AquaHotkey_Ignore
   |- AquaHotkey
   |- AquaHotkey_Backup
   `- AquaHotkey_MultiApply
```

## Quick Summary

- Add behaviour by defining nested classes such as `ArrayExtension.Array`.
- `AquaHotkey_Backup` snapshots a class for safe method overriding.
- `AquaHotkey_MultiApply` copies properties directly into multiple classes.
- `AquaHotkey_Ignore` marks classes to skip during property injection.

## Advanced Concepts

This section talks about the basic conventions and some more advanced concepts
to allow you to get the most out of this library.

**One extension, one file**:

You should generally offload each of your extension classes to separate files.
It lets you very easily `#Include` previously used code across many different
scripts.

**Always assign clear names**:

Extensions are global classes. Make sure to give clear and unambigious names
to them to make them easy to reuse across multiple scripts.

**Extending nested classes**:

Extending nested classes such as `Gui.Button` works the exact same way, just
keep nesting:

```ahk
class Extension_GuiButton extends AquaHotkey {
    class Gui {
        class Button {
            ...
        }
    }
}
```

**Conditional imports**:

You can check whether certain extensions are imported, simply by calling
`IsSet()` on the class that defines them. This allows you to very easily
ensure that the right files are `#Include`'d in your script, or customize
behavior based on what is present. Sort of like `#indef` in C/C++, if you
think about it.

```ahk
class StreamExtensions extends AquaHotkey {
    static __New() {
        if (IsSet(AquaHotkey_Stream)) {
            return super.__New() ; success - extend like usual
        }

        ; failure - return without calling `super.__New()`.
        ; realistically, you'd throw an error instead of a message box
        MsgBox("
        (
        StreamExtensions.Stream unavailable - Stream.ahk is missing.

        #Include .../Stream.ahk
        )", "StreamExtensions.ahk", 0x40)
    }

    class Stream {
        ...
    }
}
```

**Order of execution**:

In some cases, the order in which extension classes are loaded is crucial.
Most of the time, this happens when you work with `AquaHotkey_Backup` -
you want to take a snapshot of the class *before* any changes are applied.

To ensure everything works correctly, you force the classes to load inside
your `static __New()` method.

```ahk
class DarkModeGui extends AquaHotkey {
    static __New() {
        ; force this class to load (yes, this works, trust me bro.)
        (BackupGui)
    }

    class Gui {
        ...
    }
}

class BackupGui extends AquaHotkey_Backup {
    static __New() => super.__New(Gui)
}
```
