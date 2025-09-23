# Advanced - Class Prototyping

This file covers some slightly more advanced, but still common use cases.

## Extending Nested Classes

Extending with nested classes works as you'd expect, just nest one layer deeper,
and the rest remains exactly the same.

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

## Extending Functions

Yep, you guessed right. This also works for global functions just like before.

```ahk
class MsgBoxUtil extends AquaHotkey
{
    class MsgBox {
        static Info(Text?, Title?) => this(Text?, Title?, 0x40)
    }
}

MsgBox.Info("(insert very informative text here)", "Absolute Cinema")
```

Note that you should prefer `static` properties when extending functions,
because conceptually speaking, they're not classes and you don't create any
instances of them.

## Field Declarations

You can control how objects are initialized by specifying field declarations.

It's really useful if you want to set default values for `Map#CaseSense`
or `Array#Default`, like this:

```ahk
class DefaultEmptyString extends AquaHotkey {
    class Map {
        Default := ""
    }
    class Array {
        Default := ""
    }
}
```

These field declarations are accumulated, i.e. each of them is executed one
after another without removing anything.

```ahk
class ArrayDefaultEmptyString extends AquaHotkey {
    class Array {
        Default := ""
    }
}

class ArrayCaseSenseOff extends AquaHotkey {
    class Array {
        CaseSense := "Off"
    }
}

Arr := Array()
MsgBox(Arr.Default)   ; ""
MsgBox(Arr.CaseSense) ; "Off"
```

Don't overuse this, though. I recommend making only very simple changes
(like e.g. `Array.Default`). You should prefer making changes to `.__New()`
instead. (see `AquaHotkey_Backup` below.)

> [!CAUTION]
>For `Object` and `Any`, you have to use `.__Init()` as a *function* -
>otherwise, your script will crash from infinite recursion.
>
>```ahk
>class ObjectExt extends AquaHotkey {
>    class Object {
>        ; Foo := "bar" ; <-- fails from infinite recursion!
>
>        __Init() {
>            this.Foo := "bar" ; <-- do this instead.
>        }
>    }
>}
>```

Also, for obvious reasons this doesn't apply to primitive classes such as
`Number`, since they're not objects you can assign properties to.

## Backup Classes

Backup classes can save a "snapshot" of a class, with all of its properties
and methods saved. It allows you to safely override things while still retaining
access to the old properties.

### How to Override Existing Properties

In this example, we'll overwrite the constructor of `Gui` with additional
behavior.

1. Create a new class that derives from `AquaHotkey_Backup`.
2. Define `static __New()`, and call `super.__New()`, specifying each class
   that you want to save.

```ahk
class Gui_Backup extends AquaHoteky_Backup {
    static __New() => super.__New(Gui)
}
```

The `Gui_Backup` class becomes almost an identical copy of `Gui`.

3. Now that we've saved the old state of `Gui`, we can safely override it.

```ahk
class GuiExtensions extends AquaHotkey {
    class Gui {
        __New(Args*) {
            (Gui_Backup.Prototype.__New)(this, Args*)

            MsgBox("Overridden safely!")
        }
    }
}
```

## Order of Execution

When working with `AquaHotkey_Backup`, the *order of execution* in which
AquaHotkey classes load becomes an issue. Conceptually speaking, you want to
create a backup *before* new extensions are being applied.

This is how we do it:

You can force classes to initialize by referencing them (i.e.,
`(MyClass1 [  , MyClass2, ...  ])`) and then finally calling `super.__New()`.

```ahk
class GuiExtensions extends AquaHotkey {
    static __New() {
        (Gui_Backup)  ; force the class to load
        super.__New() ; create a backup
    }

    class Gui { ... } ; same as before
}
```

## Shared Extensions with `AquaHotkey_MultiApply`

You can extend multiple unrelated classes to share behavior without writing
things twice, simple use `AquaHotkey_MultiApply`.

This is useful for creating [mixins](https://en.wikipedia.org/wiki/Mixin),
or applying properties to GUI controls which are related in Win32, but not
in AHK.

1. Create a class that derives from `AquaHotkey_MultiApply`.
2. Define `static __New()`, and call `super.__New()`, specifying each class
   that you want to apply the properties to.

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
