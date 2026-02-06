# Expert - Class Prototyping

Finally, a few quick tricks and hacks to keep in mind.

- [Overriding Functions](#overriding-functions)
- [Ignored Classes](#ignoring-nested-classes-with-aquahotkey_ignore)
- [Class Hierarchy](#class-hierarchy)
- [Conditional Imports](#conditional-imports)

## Overriding Functions

For functions, this is a lot easier than
[for regular properties](./advanced.md#overriding-existing-properties).

```ahk
class FileOpen_DefaultRead extends AquaHotkey {
    class FileOpen {
        static Call(FileName, Flags := "r", Encoding?) {
            return (Func.Prototype.Call)(this, FileName, Flags, Encoding?)
        }
    }
}
```

Why does this work?

Even if you override `FileOpen.Call`, the actual function was never lost. You
can always call the previous implementation using `Func.Prototype.Call`
directly. We've merely intercepted the call on the way there.

## Ignoring Nested Classes with `AquaHotkey_Ignore`

Extend your class with `AquaHotkey_Ignore` to mark helper or internal-use
classes that should be ignored by AquaHotkey.

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
Any
`- AquaHotkey_Ignore
   |- AquaHotkey
   |- AquaHotkey_Backup
   `- AquaHotkey_MultiApply
```

## Conditional Imports

Sometimes your script depends on other modules, but you don't want it to break
completely if those modules aren't available. Instead, you can check whether
dependancies are present in the script and decide how to proceed.

Because extension classes are just global classes, you can check whether they're
present in the script by using `IsSet()`.

### 1. Abort if a Dependancy is Missing

If a script *must* have a dependancy, you can stop early and show a useful
error:

```ahk
class StreamExtensions extends AquaHotkey {
    static __New() {
        if (!IsSet(AquaHotkey_Stream)) {
            throw UnsetError()
        }
    }

    (...)
}
```

### 2. Fallback to Reduced Functionality

You can delete some features as a way to do graceful fallback, if dependancies
are missing.

For example: `Collector.ahk` removes things reliant on `Stream.ahk`, if it's not
present in the script.

```ahk
class Utils extends AquaHotkey {
    static __New() {
        ; remove `Utils.Stream`, when unable to find `AquaHotkey_Stream`
        this.Requires(AquaHotkey_Stream?, "Stream")
        super.__New()
    }

    class Stream {
        (...)
    }

    (...) ; some other classes
}
```

The same works for AHK version requirements:

```ahk
this.RequiresVersion(">=2.1-alpha.3")
```

### 3. Conditional Extensions

For things that should be able to work as standalone, you can make extension
classes loosely coupled and only do something if `AquaHotkey` is actually
imported into the script.

```ahk
class Optional_Extensions {
    static __New() {
        if (ObjGetBase(this) != Object) {
            return
        }
        if (!IsSet(AquaHotkey) || !(AquaHotkey is Class)) {
            return
        }
        (AquaHotkey.__New)(this)
    }
}
```

Alternatively, just do this:

```ahk
class Optional_Extension {
    static __New() {
        try (AquaHotkey.__New)(this)
    }
}
```

## Quick Summary

- You can declare mixins in multiple ways, but essentially it's just moving
  properties around classes.
- There's a neat trick with `(Func.Prototype.Call)(fn)` and similar properties,
  where it becomes unnecessary to save stuff with `AquaHotkey_Backup`.
- `AquaHotkey_Ignore` marks classes to be ignored by the prototyping system.
- With the help of `static __New()` and `IsSet()`, you gain a lot more control
  over how things are imported.
