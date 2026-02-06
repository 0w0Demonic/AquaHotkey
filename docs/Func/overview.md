# Module `<Func>`

## List of Features

- [Cast](./Cast.md)
- [Comparator](./Comparator.md)
- [Continuation](./Continuation.md)
- [Func](./Func.md)
- [Kwargs](./Kwargs.md)
- [Lazy](./Lazy.md)
- [Monoid](./Monoid.md)
- [Pipes](./Pipes.md)
- [Predicate](./Predicate.md)
- [Supplier](./Supplier.md)
- [Transducer](./Transducer.md)

## Class Diagram

```ahk
Func
|- Comparator
|- Continuation
|- Lazy
|- Monoid
|- Predicate
|- Supplier
`- Transducer
```

## Type Casting

- [<Func/Cast>](./Cast.md)

Utility for type casting between different `Func` classes. This module is
meant mostly for internal use.

```ahk
class Comparator extends Func {
    (...)
}

Comp(A, B) => ...

Comparator.Cast(Comp) ; change base object of `Comp` to `Comparator.Prototype`
```

## Comparator Functions

- [<Func/Comparator>](./Func/Comparator.md)

Composable comparator functions for custom sorting logic. Enables building
complex comparisons through method chaining.

```ahk
Comp := Comparator.By(StrLen).ThenAlpha().NullsFirst()

; --> [unset, "a", "b", "example"]
Array("example", "b", "a", unset).Sort(Comp)
```

## Continuation

- [<Func/Continuation>](./Func/Continuation.md)

Continuation-passing style support for advanced control flow and asynchronous
patterns.

```ahk
LoopFiles(A_Desktop . "\*").Map((*) => A_LoopFileName).JoinLine().MsgBox()
```

## Function Composition

- [<Func/Func>](./Func/Func.md)

General function utilities including composition, memoization and
error handling.

```ahk
Plus(A) => (B) => (A + B)
Times(A) => (B) => (A * B)

Times2_Plus4 := Times(2).AndThen(Plus(4))
Times2_Plus4(2) ; 8
```

## Keyword Arguments

- [<Func/Kwargs>](./Func/Kwargs.md)

Named argument support for functions via the `.With()` method. Improves
readability by allowing calls with self-documenting parameter names.

```ahk
ControlSend.With({
    Keys: "hello",
    Ctrl: "Edit1",
    Title: "ahk_exe notepad.exe"
})
```

## Lazy Evaluation

- [<Func/Lazy>](./Func/Lazy.md)

Lazy evaluation wrapper deferring computation until the value is accessed.
Useful for expensive operations, or ones that can be cached easily.

```ahk
L := Lazy(() => SomethingExpensive())

Value := L() ; evaluated for the first time
Value := L() ; result is cached now
```

## Predicate

- [<Func/Predicate>](./Func/Predicate.md)

Composable boolean predicates for filtering and conditional logic. Supports
combining predicates with logical operators.

```ahk
; --> [1, "-12.23"]
Array(1, 23, "-12.23", "example").RetainIf( InstanceOf(Numeric).And(Lt(20)) )
```

**See Also**:

- [Assertions](../Base/Assertions.md)
- [Stream](../Stream/Stream.md)

## Pipes

- [<Func/Pipes>](./Func/Pipes.md)

Function piping for readable left-to-right data transformation chains.
Simplifies nested function calls.

```ahk
MyVar.o0(DoThis).o0(DoThat, "foo").o0(MsgBox)

; equivalent to:
MsgBox(DoThat(DoThat(MyVar), "foo"))
```

**Supplier**:

- [<Func/Supplier>](./Func/Supplier.md)

Supplier functions for value generation.

```ahk
Times(A) => (B) => (A * B)

S := Supplier(Random, 1, 6).Map(Times(2))
```
