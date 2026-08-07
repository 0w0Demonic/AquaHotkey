# AquaHotkey - Advanced

## Debug Messages

If anything decides to break badly, you can always look at the debugger messages. They contain information about all of the extension classes and their targets.

For very detailed information, you can activate verbose logging by adding `#Include <AquaHotkey\cfg\VerboseLogging>` to your script.

```ahk
; just an empty class. You can expect this to work just like #ifdef in C
class AquaHotkey_Verbose {
}
```

## Extending Nested Classes

Extending with nested classes works as you'd expect, just nest one layer deeper, and the rest remains exactly the same.

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

## Ignored Classes

Extend your class with `AquaHotkey_Ignore` to mark helper or internal-use classes that should be ignored by AquaHotkey.

```ahk
class LargeProject extends AquaHotkey {
    class Utils extends AquaHotkey_Ignore {
        ; ignored during property injection
    }

    ...
}
```

## Class Hierarchy

```txt
Any
`- AquaHotkey_Ignore
   |- AquaHotkey
   |- AquaHotkey_Backup
   `- AquaHotkey_MultiApply
```

This is also the base class of all core library classes, i.e. `AquaHotkey`, `AquaHotkey_Backup` and `AquaHotkey_MultiApply`.

## Extending Functions

Same for global functions, just like before.

```ahk
class MsgBoxUtil extends AquaHotkey
{
    class MsgBox {
        static Info(Text?, Title?) => this(Text?, Title?, 0x40)
    }
}

MsgBox.Info("(insert very informative text here)", "Absolute Cinema")
```

Note that you should prefer `static` when extending functions, because conceptually speaking, they're not classes and you don't create any instances of them.

## Field Declarations

You can control how objects are initialized by specifying field declarations.

Using this feature is **not recommended**, but can be useful for setting default values for `Map#CaseSense` and `Array#Default`. If possible, you should prefer overriding `.__New()`.

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

These field declarations are accumulated, i.e. each of them is executed one after another without removing anything.

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

Don't overuse this, though. I recommend making only very simple changes (like e.g. `Array.Default`). You should prefer making changes to `.__New()` instead. (see `AquaHotkey_Backup` below.)

> [!CAUTION]
>For `Object` and `Any`, you have to use `.__Init()` as a *function*. otherwise, your script will crash from infinite recursion.
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

This feature does not work on primitive classes such as `Number`, because primitive values cannot own any properties on their own.

## Backup Classes

Changing an existing property of an object is *destructive*. To retain access to the original property, it must be saved first. This is where *backup classes* are used.

Because classes are treated as container objects, you can "fill" them with the contents of another class in order to make a "snapshot" of that class.

For this purpose, AquaHotkey offers a `.Backup()` method for classes:

```ahk
class Gui_Backup {
    static __New() => this.Backup(Gui)
}
```

This saves the current state of `Gui` in `Gui_Backup`.

## Overriding Existing Properties

(Using this feature is **not recommended**.)

Let's say we want to extend the constructor of `Gui`. It should be able to create GUIs like usual, but also perform additional actions.

```ahk
class GuiExtensions extends AquaHotkey {
    class Gui {
        __New(Args*) {
            (Gui_Backup.Prototype.__New)(this, Args*)
            MsgBox("creating a GUI...")
        }
    }
}
```

We've now successfully extended `Gui.Prototype.__New`. First, our new constructor calls the previous contructor which we've previously saved (`Gui_Backup.Prototype.__New`), then continues with our own code.

When working with backup classes, the *order of execution* in which classes load becomes an issue.

Conceptually speaking, you want to create a backup *before* new extensions are being applied. This is how we do it:

```ahk
class GuiExtensions extends AquaHotkey {
    static __New() {
        (Gui_Backup)  ; force the class to load
        super.__New() ; create a backup
    }

    class Gui { ... } ; same as before
}
```

You can force classes to initialize by referencing them (i.e., `(MyClass1 [  , MyClass2, ...  ])`) and then finally calling `super.__New()`.

## Mixins

Extend multiple unrelated classes with the same extension by using `.ApplyOnto()`.

```ahk
class Enumerable1 {
    static __New() => this.ApplyOnto(Array, Map, RegExMatchInfo, ...)

    ForEach(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            Action(Value?, Args*)
        }
        return this
    }
}
```
