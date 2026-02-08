# Advanced - Class Prototyping

This file covers some slightly more advanced, but still common use cases.

- [Extending Nested Classes](#extending-nested-classes)
- [Extending Functions](#extending-functions)
- [Field Declarations](#field-declarations)
- [Some More Technical Insight](#some-more-technical-insight)
- [Backup Classes](#backup-classes)
- [Overriding Existing Properties](#how-to-override-existing-properties)
- [Shared Extensions](#shared-extensions-with-aquahotkey_multiapply)

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

Note that you should prefer `static` when extending functions, because
conceptually speaking, they're not classes and you don't create any instances
of them.

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

## Some More Technical Insight

In AquaHotkey, classes are used as "property containers" whose contents can be
moved around freely. Understanding this concept is very helpful for the later
sections, because there's a lot of "pushing and pulling" going on between
classes and their properties.

Let's say we have two classes, the built-in `Array` class and a custom
`ArrayUtils` class which we use to define custom properties for `Array`:

```ahk
class ArrayUtils (custom)
|- ...
`- Prototype
   |- ForEach(Action)
   `- Contains(Value)

    |
    | paste into...
    V

class Array (built-in)
|- ...
`- Prototype
   |- Get(Index, Default?)
   |- Has(Index)
   |- __Item[Key]
   `- etc.
```

Here, `ArrayUtils` takes the role of an *extension class*. In order to use
its properties, they need to be "pasted" into the built-in `Array` class.

```ahk
class Array (built-in)
|- ...
`- Prototype
   |- ForEach(Action)
   |- Contains(Value)
   |
   |- Get()
   |- Has()
   |- __Item[]
   `- etc.
```

## Backup Classes

Changing an existing property of an object is *destructive*. To retain access
to the original property, it must be saved first. This is where *backup
classes* are used.

Because classes are treated as container objects, you can "fill" them with
the contents of another class in order to make a "snapshot" of that class.

```ahk
class Gui_Backup {
    static __New() => this.Backup(Gui)
}
```

In this example, calling `.Backup(Gui)` will save all properties contained
in `Gui`, also including the current state of `Gui.Control` and all of the
other nested classes.

### Overriding Existing Properties

Let's say we want to extend the constructor of `Gui`. It should be able to
create GUIs like usual, but also perform additional actions.

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

We've now successfully extended `Gui.Prototype.__New`. First, our new
constructor calls the previous contructor which we've previously
saved (`Gui_Backup.Prototype.__New`), then continues with our own code.

When working with backup classes, the *order of execution* in which classes
load becomes an issue.

Conceptually speaking, you want to create a backup *before* new extensions are
being applied. This is how we do it:

```ahk
class GuiExtensions extends AquaHotkey {
    static __New() {
        (Gui_Backup)  ; force the class to load
        super.__New() ; create a backup
    }

    class Gui { ... } ; same as before
}
```

You can force classes to initialize by referencing them (i.e.,
`(MyClass1 [  , MyClass2, ...  ])`) and then finally calling `super.__New()`.

## Shared Extensions with `AquaHotkey_MultiApply`

There might be occasions where you want to extend multiple unrelated classes
to share behavior without writing things twice.

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

The class represents any type that supports for-loops with 1 argument.
Using `.ApplyOnto()`, we specify each of the built-in classes that fulfill
this condition.

```ahk
Even(x) => !(x & 1)

; [2, 4]
Array(1, 2, 3, 4).ForEach(MsgBox)
MatchObj.ForEach(MsgBox)
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
