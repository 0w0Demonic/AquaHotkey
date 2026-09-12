# <[Base](./overview.md)/[Assertions](../../src/Base/Assertions.ahk)>

- [\<Base/Assertions\>](#baseassertions)
  - [Overview](#overview)
  - [Conventions](#conventions)
    - [Removed Methods in v2](#removed-methods-in-v2)
  - [Function `Assert()`](#function-assert)
  - [Method `.Assert(Condition, Args*)`](#method-assertcondition-args)
  - [Method `.AssertType(T)`](#method-asserttypet)
  - [Disabling Assertions](#disabling-assertions)
  - [Examples](#examples)

## Overview

This module introduces assertion methods, which make assumptions about the program during runtime. They are especially useful for unit tests.

## Conventions

An assertion method SHOULD return the calling object (i.e., `return this`).

Method should return the original object, This lets you write multiple assertions in a sequence.

```ahk
PositiveNum := Value.Assert(IsNumber).Assert(Gt(0))
```

## Writing Own Assertion Methods



```ahk
class MyAssertions extends AquaHotkey {
    class Any {
    }
}
```

### Removed Methods in v2

Currently, AquaHotkey defines only two assertion methods, `.Assert()` and `.AssertType()`.

Other assertion methods such as `.AssertHasOwnProp()` have been cut in favor of [predicates](../Func/Predicate.md).

Always feel free to add more assertion methods with some help of [extension classes](../core.md#), if it makes writing your program easier. After all, it's what this library is for!

## Function `Assert()`

Use `Assert()` for simple assertions, like this:

```ahk
Assert(4 == 4)
```

In this example `4 == 4` is an expression that should return either `true` or `false`. Whenever an expression evaluates to `false`, `Assert()` will throw an error.

## Method `.Assert(Condition, Args*)`

You can also use it as a method, generically with the help of [predicate](../Func/Predicate.md) functions.

```ahk
; 1. assert that value is a non-empty string
; 
IsStringNonEmpty := InstanceOf(String).AndNot(IsSpace)
"example".Assert(IsStringNonEmpty)

; 2. assert that an object owns a given property
; 
Obj := { Value: 42 }
; 
; equivalent to: Assert(ObjHasOwnProp(Obj, "Value"))
Obj.Assert(ObjHasOwnProp, "Value")
```

## Method `.AssertType(T)`

To assert that a value is member of a given type `T`, you can use `.AssertType(T)`:

```ahk
Val.AssertType(String)
```

The example above asserts that `Val` is an instance of `String`. This is equivalent to `Val.Assert(InstanceOf(String))`.

Because `.AssertType()` uses [duck types](./DuckTypes.md), you can use complex pattern matching in your assertion.

```ahk
Arr := Array({ Value: 42 }, { Value: 43 })
Arr.AssertType(  Array.OfType({ Value: Integer })  )
```

If you want to match using inheritance instead of duck types:

```ahk
"foo".Assert(s => s is String)
"foo".Assert(DerivedFrom(String))
```

**See Also**:

- [<Func/Predicate>](../Func/Predicate.md)
- [<Base/DuckTypes>](./DuckTypes.md)

## Disabling Assertions

To disable `.Assert()` assertions, include `<cfg/DisableAssertions>` in your script.

To disable `.AssertType()` assertions, include `<cfg/DisableTypeAssertions>` in your script.

This lets you write code with guardrails to catch errors more easily. After you gain enough confidence that everything works, you can remove assertions to speed up your script and remove most of the performance overhead.

```ahk
#Include <AquaHotkey/cfg/DisableAssertions>     ; disable `.Assert()`
#Include <AquaHotkey/cfg/DisableTypeAssertions> ; disable `.AssertType()`

; (no assertions are made, almost no overhead)
Value.AssertType(SomethingComplicated).Assert(SomethingExpensive)
; ==> Value
```

## Examples

Here's some more examples of how to use this in practice.

Generally, I'm using `.Assert()` together with predicate functions, because that's arguably the most flexible way to do assertions.

```ahk
Divide(A, B) {
    A.AssertType(Numeric)
    B.AssertType(Numeric).Assert(Ne(0)) ; also assert that `B` is not zero
    return (A / B)
}

CreateUser(Name, Age) {
    Name.Assert( InstanceOf(String).AndNot(IsSpace) )
    Age.Assert( InstanceOf(Integer).And(Gt(0)) )
    ...
}

GetUserInput() => InputBox(...)
    .AssertType({ Result: "OK", Value: IsSpace.Negate() })
    .Value
```

