# <[Base](./overview.md)/[Error](../../src/Base/Error.ahk)>

## Summary

Utilites related to errors, like throwing and error causes.

```ahk
IndexError.Throw("invalid index")

try {
    ...
} catch as Err {
    throw TypeError(...).CausedBy(Err)
}
```

## Throwing Errors

A static `Throw()` method which is particularly useful inside the middle of
statements, or for making one-liners in class properties.

```ahk
class Thing {
    DoSomething => PropertyError.Throw("not implemented")
}

; same as `throw IndexError()`
IndexError().Throw()
```

## Error Causes

This feature lets you attach another error as cause. Error objects now own
a property `Cause`, which contains either `false`, or another error object
deemed as the error reason.

By using the `.CausedBy()` method, you attach another error object as `Cause`,
and fill up the `Stack` with more detailed information.

The error cause should remain unchanged, once assigned.

```ahk
try {
    ...
} catch as InnerErr {
    throw TypeError(...).CausedBy(InnerErr) ; attach `Err` as cause
}

...
if (Err.Cause) { ; determine if there exists an error cause
    Inner := Err.Cause
    MsgBox(Inner.Message) ; display inner error message
}
```

In addition, the same works the other way around with `.Causing()`:

```ahk
try {
    ...
} catch as InnerErr {
    Middle := OSError(...)
    Outer := MethodError(...)
    throw InnerErr.Causing( Middle ).Causing( Outer )
}
```
