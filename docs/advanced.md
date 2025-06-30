# Advanced Concepts - Class Prototyping

Now that you've ..., I'd like to demonstrate the more advanced concepts for
getting the most out of this library and to show you how to make much more
fundamental changes to AHK's built-ins.

## Extending Nested Classes

Works exactly in the same way. Just nest one layer deeper:

```ahk
class GuiButton extends AquaHotkey
{
  class Gui {
    class Button {
      ...
    }
  }
}
```

## Field Declarations

By specifying field declarations (like e.g. `Foo := "bar"`) or an `__Init()`
method, you can control how objects are initialized.

This is really useful if you want to set default values such as `Map.CaseSense`
or `Array.Default`:

```ahk
class MyDefaultSettings extends AquaHotkey {
    class Map {
        CaseSense := false
    }

    class Array {
        Default := ""
    }
}

M := Map("foo", "bar", "FOO", "bar")
MsgBox(M.Size) ; 1

A := [unset, 2, 3]
MsgBox(A[1]) ; ""
```

Don't overuse this, though. I recommend making only very simple changes and to
prefer overriding `__New()` instead. (see `AquaHotkey_Backup` below.)

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
properties and methods.

It allows you to safely override while retaining access to the original
properties.

**How to use**:

In this following example, we'll overwrite the `Gui.__New()` constructor with
our own method, without breaking any existing things.

First, we define a new class that derives from `AquaHotkey_Backup`. To create
a snapshot, call `super.__New()` and specify each class which you want to save.

```ahk
class OldGui extends AquaHotkey_Backup {
    static __New() => super.__New(Gui) ; create a snapshot of `Gui`
}
```

Now that we've saved the current state of the `Gui` class, we can proceed by
defining an extension:

```ahk
class GuiExtensions extends AquaHotkey {
    class Gui {
        __New(Args*) {
            (OldGui.Prototype.__New)(this, Args*)


        }
    }
}
```

We've now safely overridden the old `Gui` constructor. Let's test it out:

```ahk
; creates a valid Gui and then displays "Overridden safely" as message box
g := Gui()
g.AddEdit(...)
...
g.Show()
```

One last thing we need to take into consideration is the *order of execution*.
Especially when working with `AquaHotkey_Backup`, this can produce obscure bugs
if you're not careful.

We want to make sure that a backup is made *before* `GuiExtensions` is loaded.
This is how we do it:

```ahk
class GuiExtensions extends AquaHotkey {
    static __New() {
        (OldGui)      ; force the class to load
        super.__New() ; create a backup
    }
    class Gui { ... } ; same as before
}
```

You can force classes to initialize by referencing them (i.e.,
`(MyClass1 [  , MyClass2, ...  ])`) and then finally calling `super.__New()`.

This is a very common pattern you'll encounter whenever you're making deeper
changes to AHK's types.

## Sharing Behavior Across Multiple Classes with `AquaHotkey_MultiApply`

If you want to extend multiple unrelated classes to share behavior without
repeating code, use `AquaHotkey_MultiApply`.

This is mostly useful for GUI controls which are related (e.g., a
`Gui.Button` and `Gui.Radio` are the same Win32 class) but don't share a common
type in AHK.

Same as `AquaHotkey_Backup` - you specify which classes to override by
calling `super.__New()` and passing each class as argument.

```ahk
class ButtonUtils extends AquaHotkey_MultiApply {
    static __New() => super.__New(
        Gui.Button,
        Gui.CheckBox)

    Foo() {
        MsgBox("I'm a Button or CheckBox!")
    }
}
```

## Ignoring Nested Classes with `AquaHotkey_Ignore`

Use the special `AquaHotkey_Ignore` marker class to exclude helper or
internal-use classes from AquaHotkey's class prototyping system.

```ahk
class LargeProject extends AquaHotkey {
    class Utils extends AquaHotkey_Ignore {
        ; ignored during property injection
    }

    ...
}
```

This is also the base class of all core library classes, i.e. `AquaHotkey`,
`AquaHotkey_Backup` and `AquaHotkey_MultiApply`.

## Class Hierarchy

```txt
Object
`- AquaHotkey_Ignore
   |- AquaHotkey
   |- AquaHotkey_Backup
   `- AquaHotkey_MultiApply
```

## Conditional Imports

Here's where things get clever.

Since extensions are just classes, you can check if a class has been included
in your script using `IsSet()`.

That means you can make your own extensions depend on other ones conditionally.

```ahk
class StreamExtensions extends AquaHotkey {
    static __New() {
        if (IsSet(AquaHotkey_Stream)) {
            return super.__New() ; success
        }

        ; otherwise, abort
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

This is exactly what `Collector.ahk` and `Gatherer.ahk` do: if Streams aren't
included, gatherers won't load at all, and collectors fall back to a smaller
subset of features.
