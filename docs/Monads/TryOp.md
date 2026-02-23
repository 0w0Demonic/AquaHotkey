# <[Monads](./overview.md)/[TryOp](../../src/Monads/TryOp.ahk)>

- [\<Monads/TryOp\>](#monadstryop)
  - [Overview](#overview)
  - [Construction](#construction)
  - [Success](#success)
  - [Side Effects](#side-effects)
  - [Filtering](#filtering)
  - [Transformation](#transformation)
  - [Returning Values](#returning-values)
  - [Error Recovery](#error-recovery)
  - [Calling a Function](#calling-a-function)

## Overview

Abstracts the use of try-catch blocks into a container object that is
either a `TryOp.Success` containing a value, or a `TryOp.Failure`, containing
an error object.

## Construction

Use `TryOp()` to wrap a [supplier function](../Func/Supplier.md) with
try-catch logic.

```ahk
T := TryOp(() => FileRead("myFile.txt"))
```

Use `TryOp.Value()` to create a successful TryOp containing the given value.

```ahk
T := TryOp.Value(42) ; same as `TryOp(() => 42)`
```

You can also use methods `TryOp.Success(Value)` and `TryOp.Failure(Err)`,
but you should generally avoid using them directly.

```ahk
Success := TryOp.Success(42)
Failure := TryOp.Failure(IndexError("out of bounds"))
```

## Success

Use `.Succeeded` and `.Failed` to determine whether the TryOp is successful
or not.

```ahk
TryOp(() => "str").Succeeded ; true
TryOp(Divide, 0, 0).Failed ; true
```

## Side Effects

Use `.Then()` or `.OnSuccess()` to perform a side effect if the TryOp is
successful, `.OnFailure()` or `.OrElseRun()` if the TryOp has failed,
and `.Finally()` regardless of the state.

```ahk
Success.Then(...)         ; [x]
       .OnSuccess(...)    ; [x]
       .OnFailure(...)    ; [ ]
       .OrElseRun(...)    ; [ ]
       .Finally(...)      ; [x]

Failure.Then(...)         ; [ ]
       .OnSuccess(...)    ; [ ]
       .OnFailure(...)    ; [x]
       .OrElseRun(...)    ; [x]
       .Finally(...)      ; [x]
```

## Filtering

Use predicate function to test the inner value for conditions, if a value is
present.

```ahk
FileContents := TryOp(FileRead, "myFile.txt")
        .RemoveIf(Eq(""))
        .OnSuccess(Str => MsgBox("success!"))
        .OrElseThrow()
```

## Transformation

`.Map()` lets you transform the inner value of a successful TryOp by applying
a mapper function.

```ahk
Times2(x) => (x * 2)

TryOp.Value(2).Map(Times2) ; TryOp.Success(4)
```

Use `.FlatMap()` for mappers that themselves return TryOp values.

```ahk
Divide(A, B) => TryOp(() => (A / B))

TryOp.Value(3).FlatMap(Divide, 0) ; TryOp.Failure<ZeroDivisionError>
```

`.Transform()` will pass the entire `TryOp` into the mapper function,
regardless whether it is successful or not.

```ahk
TryOp.Value(2).Transform((T) {
    if (T.Succeeded) {
        return ...
    } else {
        return ...
    }
})
```

## Returning Values

You can retrieve values from a TryOp in a manner similar to
[Optional](./Optional.md):

```ahk
T.Get()                 ; inner value, else throw
T.OrElse(Default)       ; inner value, or `Default`
T.OrElseGet(GetDefault) ; inner value, or `GetDefault()`
T.OrElseThrow()         ; inner value, else throw detailed error
```

## Error Recovery

To recover from a failed TryOp, use `.Recover()` or `.RecoverAny()`:

```ahk
TryOp(DoSomething)
        .Recover(UnsetError, Err => "unset")
        .RecoverAny(Err => "something went wrong: " . Err.Message)
        .Get()
```

## Calling a Function

Use `.TryCall()` on any callable object to wrap it into a TryOp.

```ahk
; equivalent to:
;   TryOp(  () => FileRead("myFile.txt")  ).OrElse("")

FileContents := FileRead.TryCall("myFile.txt").OrElse("")
```
