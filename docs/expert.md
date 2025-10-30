# Expert - Class Prototyping

## Mixins

Mixins are classes that contain methods for use by other classes without having
to be the parent class of those other classes.

There's multiple different ways to simulate this:

1. By using `AquaHotkey_MultiApply` to actively "push" stuff onto the classes
   you want to extend.

   ```ahk
   class Mixin extends AquaHotkey_MultiApply {
       static __New() => super.__New(Target)
   }

   class Target {
   }
   ```

2. By using `AquaHotkey_Backup` to actively "pull" extensions from other
   classes.

   ```ahk
   class Mixin {
   }
   
   class Target extends AquaHotkey_Backup {
       static __New() => super.__New(Mixin)
   }
   ```

3. Using `AquaHotkey.ApplyMixin(TargetClass, Mixin, Mixins*)`

   ```ahk
   class Mixin {
   }
   
   class Target {
       static __New() => AquaHotkey.ApplyMixin(Target, Mixin)
   }

   ; alternatively, put this somewhere outside the class.
   ; 
   ;     AquaHotkey.ApplyMixin(Target, Mixin)
   ```

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
Any
`- AquaHotkey_Ignore
   |- AquaHotkey
   |- AquaHotkey_Backup
   `- AquaHotkey_MultiApply
```

## Conditional Imports

Sometimes your script depends on other modules, but you don't want it to break
completely if those modules aren't available. Instead, you can check whether
dependancies are present in the script and decide how to proceed:

- Abort with a clear error message
- Gracefully fallback to a smaller feature set
- Extend conditionally, when modules should work standalone or with AquaHotkey

To achieve this, you can perform `IfSet()` checks inside `static __New()`
methods.

### 1. Abort if a Dependancy is Missing

If a script *must* have a dependancy, you can stop early and show a useful
error:

```ahk
class StreamExtensions extends AquaHotkey {
    static __New() {
        if (IsSet(AquaHotkey_Stream) && (AquaHotkey_Stream is Class)) {
            return super.__New() ; success
        }

        ; otherwise, show message box with clear instructions
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

This ensure the script won't run without its dependancies.

### 2. Fallback to Reduced Functionality

You can delete some features as a way to do graceful fallback, if dependancies
are missing.

For example: `Collector.ahk` removes things reliant on `Stream.ahk`, if it's not
present in the script.

```ahk
class AquaHotkey_Collector extends AquaHotkey {
    static __New() {
        if (IsSet(AquaHotkey_Stream) && (AquaHotkey_Stream is Class)) {
            return super.__New()
        }
        OutputDebug("[Aqua] Collector.ahk: support for stream disabled.")
        this.DeleteProp("Stream")
        Collector.DeleteProp("ToMap")
    }
}
```

### 3. Conditional Extensions

Modules like `Optional.ahk` and `Stream.ahk` can be used both as standalones
or together with their AquaHotkey extension classes.

To achieve this, check for `AquaHotkey` at load time, before applying
extensions.

```ahk
class Optional_Extension {
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

This way, the extension class is only applied when AquaHotkey is included in
the script.

## Quick Summary

- You can declare mixins in multiple ways, but essentially it's just moving
  properties around classes.
- There's a neat trick with `(Func.Prototype.Call)(fn)` and similar properties,
  where it becomes unnecessary to save stuff with `AquaHotkey_Backup`.
- `AquaHotkey_Ignore` marks classes to be ignored by the prototyping system.
- With the help of `static __New()` and `IsSet()`, you gain a lot more control
  over how things are imported.
