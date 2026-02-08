# Module `<Monads>`

- [All Modules](../api-overview.md)

## Summary

At its simplest form, a monad is something that wraps a value and provides a
way to apply functions to it. Take `Optional` for example: it wraps a value
that may or may not be present, where operations like `.Map()` transform
the into a new `Optional` with the function applied to the inner value, if it exists.

## List of Features

- [Optional](./Optional.md)
- [TryOp](./TryOp.md)

## Optional

- [Optional](./Optional.md)

Represents a value that may or may not be present. This is different than
AutoHotkey's `unset`, because you can still access properties from an empty
`Optional`.

```ahk
; Displays the first matching element, if present. Otherwise, an error
; is thrown.
Range(20).Find( Ge(10) ).IfPresent(MsgBox).ElseThrow()
```

While `Optional` revolves around the presence or absence of a value, `Nullable`
is used to wrap a duck type that can be `unset`.

**See Also**:

- [Nullable](../Base/Ducktypes/Nullable.md)
- [Stream](../Stream/overview.md)
- [Enumerable1's `.Find()` method](../Interfaces/Enumerable1.md)

## TryOp

- [TryOp](./TryOp.md)

An operation that may succeed or fail. It wraps the result of a function that
may return a value or throw an error.

```ahk
Divide(A) => (B) => (A / B)

TryOp.Value(42)
    .Map(Divide(0)) ; this will fail
    .Recover(ZeroDivisionError, Err => "Zero division error") ; error recovery
    .OnSuccess(MsgBox)
```
