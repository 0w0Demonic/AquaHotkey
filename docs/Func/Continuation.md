# <[Func](./overview.md)/[Continuation](../../src/Func/Continuation.ahk)>

- [Overview](#overview)
- [Parallels to Stream](#parallels-to-stream)
- [Technical Insight](#technical-insight)
  - [General](#general)
  - [Early Termination](#early-termination)
  - [Composition](#composition)

## Overview

Allows the creation of pipelines in continuation-passing style. This is a
powerful technique for structuring code in a functional and declarative
way, especially for things like `loop files` which cannot be lazy-evaluated.

If you're looking for a comprehensive guide for how to use them, you won't find
anything lol. Just look at [<Stream/Stream>](../Stream/Stream.md) and you'll
be fine. Nonetheless, I find them pretty interesting, and this documentation
covers some basic explanation as to how they actually work.

## Parallels to Stream

The overall API is almost identical to that of [streams](../Stream/Stream.md),
because both are very similar in nature. While streams are essentially layers
of Enumerators, continuations work the other way around by defining a pipeline
of functions to be called one after another. Both streams and continuations
are only evaluated when actual elements are required on terminal operations
such as `.ForEach()` or `.ToArray()`.

```ahk
LoopFiles(A_Desktop . "\*", "FR")
    .RetainIf((*) => (A_LoopFileExt = "ahk"))
    .Map(FileRead)
    .ForEach(MsgBox)

; equivalent to:
loop files A_Desktop . "\*", "FR" {
    Path := A_LoopFilePath
    if (A_LoopFileExt != "ahk") {
        continue
    }
    MsgBox(FileRead(Path))
}
```

## Technical Insight

### General

To understand how continuations work, let's have a look at `LoopFiles()`:

```ahk
LoopFiles(Pattern, Mode := "F") {
    return Continuation.Cast(LoopFiles)

    LoopFiles(Downstream) {
        loop files Pattern, Mode {
            if (!Downstream(A_LoopFilePath)) {
                return
            }
        }
    }
}
```

Calling `LoopFiles` returns a function that is considered the **source** of
elements in the pipeline. It retrieves the specified files or folders using
`loop files`, and pushes every file path (`A_LoopFilePath`) into the
specified `Downstream`, which is the next layer in the pipeline.

```ahk
LoopFiles(A_Desktop . "\*", "D")(MsgBox)

; equivalent to:
;   loop files A_Desktop . "\*", "D" {
;       if (!MsgBox(A_LoopFilePath)) {
;           return
;       }
;   }
```

### Early Termination

In order to support early termination, the return value of `Downstream` is a
boolean value that indicates whether the pipeline should continue or not.

```ahk
LoopFiles(A_Desktop . "\*", "F")((Path) {
    ; ...

    ; only continue for the first 10 elements in the continuation
    return (A_Index <= 10)
})
```

### Composition

Now let's see how we can compose together more complex continuations by using
composition:

```ahk
class Continuation extends Func {
    ...

    Map(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(Factory)

        Factory(Downstream) {
            return this((Value?) => Downstream(Value?, Args*))
        }
    }
}
```

This might seem like witchcraft at first, but allow me to explain.

Because continuations are an iterative function disguised as something
lazy-evaluated, there's many extra steps involved in the code.

The `.Map()` method returns a new continuation (`Factory`). It should first
accept the element, transform it using the `Mapper`, and then push the
transformed value into the next layer of the pipeline (`Downstream`).

Essentially what happens is, whenever the continuation is called (and actual
elements are being requested), we specify exactly whether or how `Downstream`
should be called. We do this on every layer, and end up with something that
works almost the same as a [stream](../Stream/Stream.md).

Based on the fact that you're still reading this, I assume you already know
what you're doing. Lol.

One last example that I want to show you is the implementation of `.RetainIf()`.

```ahk
...

RetainIf(Condition, Args*) {
    GetMethod(Condition)
    return this.Cast(Factory)

    Factory(Downstream) {
        return this(RetainIf)

        RetainIf(Value?) {
            if (Condition(Value?, Args*)) {
                Downstream(Value?)
            }
        }
    }
}
```
