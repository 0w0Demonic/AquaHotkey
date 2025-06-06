# Class Prototyping

**TL;DR.**:

- AquaHotkey lets you extend native AutoHotkey classes like `Array`, `Gui` and
  `String` with your own methods and properties.
- It makes most general wrapper functions *obsolete*.
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

One reason that it is clunky is because wrapper functions can accept
any type of object, and there's no safeguard if you accidentally pass something
unexpected (e.g., a `Map` instead of an `Array`) - the function might fail
silently or misbehave badly. With AquaHotkey, there's *no type checking needed*,
because methods are directly owned by the variables themselves (and because
polymorphism is awesome).

AquaHotkey lets you *inject methods directly into native classes*, so you can
call them like any normal method. And it **works for all possible types** and
even global functions like `MsgBox()`!

**How it works**:
>AquaHotkey scans your nested class definitions at runtime, injecting them into
>the correct class or class prototype (e.g. `Array`, `Gui.Control.Prototype`,
>etc.). You write methods exactly like you're subclassing, and AquaHotkey
>performs a bunch of hidden class-prototyping wizardry to make everything work
>smoothly.

## Getting Started

Setting up new methods and properties is pretty straightforward - you won't
even truly notice that the library is even *there* at all.

### Step 1 - Extend `AquaHotkey`

```ahk
class ArrayExtensions extends AquaHotkey {
}
```

### Step 2 - Create a nested class matching your target

The naming is important here: To extend `Array`, define a class called `Array`
inside your outer class.

```ahk
class ArrayExtensions extends AquaHotkey {
    class Array {
    }
}
```

### Step 3 - Add properties and methods

Also very straightforward - define things like you normally would in a class:

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

### Step 4 - Use like native methods!

```ahk
Arr := Array.OfCapacity(20, 1, 2, 3, 4)

MsgBox( Arr.IsEmpty  ) ; false
MsgBox( Arr.Sum()    ) ; 10
MsgBox( Arr.Capacity ) ; 20
```

### Notes and Warnings

>Overriding methods is destructive, because AquaHotkey *replaces* existing
>methods without asking. If you override a built-in method (like
>`Gui.Prototype.__New`), the original is gone - unless you back it up manually
>or use [`AquaHotkey_Backup`](#Preserving-Original-Behaviour).

## Real-World Example - Extending `Gui.Control`

You can modify nested classes like `Gui.Control`, too:

**Example - Define a `Hidden` property for `Gui.Control`**:

```ahk
class GuiControlExtensions extends AquaHotkey
{
    class Gui
    {
        class Control {
            Hidden {
                get => (!this.Visible)
                set => (this.Visible := !value)
            }
        }
    }
}

Btn := MyGui.Add("Button", "vMyButton", "Click me")

Btn.Hidden := true ; this hides the button
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

Note: These are ignored for primitive classes, namely `Number`, `Integer`,
`Float` and `String` because they cannot possible own any instance variables.
Static variable declarations, however, work perfectly as you would expect.

> [!CAUTION]
>For `Object` and `Any`, you must use an `__Init()` method with a function body.
>Otherwise, AutoHotkey will crash from infinite recursion.

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
