# Advanced Concepts - Class Prototyping

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

This is really useful if you want to set default values for `Map.CaseSense`
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
our own method, without breaking any existing properties.

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
            MsgBox("Overridden safely!")
        }
    }
}
```

We've now safely overridden the old `Gui` constructor. Let's test it out:

```ahk
; creates a valid Gui and then displays "Overridden safely!"
g := Gui()
```

One last thing we need to take into consideration is the *order of execution*
of different AquaHotkey classes.

Especially when working with `AquaHotkey_Backup`, this can produce obscure bugs
if you're not careful. We want to make sure that a backup is made *before*
`GuiExtensions` is loaded. This is how we do it:

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

## Overriding Functions

You don’t need to mess with `AquaHotkey_Backup` to tweak the behavior of
global functions like `FileOpen()`. There's a nice trick for that:

```ahk
class FileOpen_DefaultRead extends AquaHotkey {
    class FileOpen {
        static Call(FileName, Flags := "r", Encoding?) {
            return (Func.Prototype.Call)(this, FileName, Flags, Encoding?)
        }
    }
}
```

Why does this work? Essentially: a call like `MsgBox("Hello, world!")` is just
syntactic sugar for `(Func.Prototype.Call)(MsgBox, "Hello, world!")`. Even if
you override `FileOpen.Call`, the actual function was never lost. You can
always call the previous implementation using `Func.Prototype.Call` directly.
We've merely intercepted the call on the way there.

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

Since extensions are just classes (also the `AquaHotkey` class responsible for
them), you can check if a class has been included in your script simply by using
`IsSet()`.

In general, defining your own `static __New()` helps you gain much more
control of how properties are being extended. It lets you check if other
extensions are present, and to make extensions only be applied if `AquaHotkey`
is present in the script.

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

---

Modules such as `Optional.ahk` and `Stream.ahk` introduce their own extension
properties (e.g. `Any#Optional()`), which are only applied if `AquaHotkey` is
present in the script.

That way, they can be used as standalone scripts that fall back to a smaller
subset of features if `AquaHotkey` isn't present in the script.

1. Create a class as you normally would, but *without* extending `AquaHotkey`.
2. Inside `static __New()`, use `IsSet(AquaHotkey)` to check if it's
   present in the script.
3. Use `(AquaHotkey.__New)(this)` to add your extension properties.

```ahk
class Optional_Extension {
    static __New() {
        if (ObjGetBase(this) != Object) {
            return
        }
        if (!IsSet(AquaHotkey) || !(AquaHotkey is Class)) {
            ; do not apply extension properties 
            return
        }
        (AquaHotkey.__New)(this)
    }

    ...
}
```

## Quick Summary

- Overriding nested classes works exactly the same, just nest deeper.
- You can add field declarations to built-in types.
  - Prefer making changes to `__New()`, instead.
  - Doesn't work on primitive types.
  - Watch out when dealing with `Object` and `Any`!
- `AquaHotkey_Backup` creates a snapshot of one or multiple classes.
  - Often times, the order of execution between classes is important.
  - Force classes to load by referencing them: `(MyClass, ...)`
- `AquaHotkey_MultiApply` overrides the same properties into multiple classes.
- `AquaHotkey_Ignore` marks classes to be ignored by the prototyping system.
- You can check whether `AquaHotkey` or extension classes are present by
  defining your own `static __New()`, and using `IsSet(<Class>)`
