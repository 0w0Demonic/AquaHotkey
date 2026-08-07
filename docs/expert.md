# AquaHotkey - Expert

Finally, a few quick tricks and hacks to keep in mind.

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [AquaHotkey - Expert](#aquahotkey---expert)
  - [Overriding Functions](#overriding-functions)
    - [Why This Works](#why-this-works)
  - [Conditional Imports](#conditional-imports)
    - [Abort if a Dependancy is Missing](#abort-if-a-dependancy-is-missing)
    - [Fallback to Reduced Functionality](#fallback-to-reduced-functionality)
    - [Conditional Extensions](#conditional-extensions)

<!-- /code_chunk_output -->



## Overriding Functions

(This is **not recommended**.)

```ahk
class FileOpen_DefaultRead extends AquaHotkey {
    class FileOpen {
        static Call(FileName, Flags := "r", Encoding?) {
            return (Func.Prototype.Call)(this, FileName, Flags, Encoding?)
        }
    }
}
```

### Why This Works

Even if you override `FileOpen.Call`, the actual function was never lost. You can always call the previous implementation using `Func.Prototype.Call` directly. We've merely intercepted the call on the way there.

## Conditional Imports

Sometimes your script depends on other modules, but you don't want it to break completely if those modules aren't available. Instead, you can check whether dependancies are present in the script and decide how to proceed.

Because extension classes are just global classes, you can check whether they're present in the script by using `IsSet()`.

### Abort if a Dependancy is Missing

If a script *must* have a dependancy, you can stop early and show a useful error:

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

### Fallback to Reduced Functionality

You can delete some features as a way to do graceful fallback, if dependancies are missing.

For example: `Collector.ahk` removes things reliant on `Stream.ahk`, if it's not present in the script.

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

### Conditional Extensions

For things that should be able to work as standalone, you can make extension classes loosely coupled and only do something if `AquaHotkey` is actually imported into the script.

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
