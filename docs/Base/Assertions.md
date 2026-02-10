# <[Base](./overview.md)/[Assertions](../../src/Base/Assertions.ahk)>

## Summary

Introduces a set of assertion methods, perfect for validating parameters and
making assumptions in your program at runtime. Because of their conciseness,
they're particularly useful inside unit tests.

Methods return the value itself (`return this`), meaning you can chain
multiple assertions together fluently.

### Removed Methods in v2

Most of the other assertion methods in v2 (such as `.AssertHasOwnProp()`) have
been cut in favor of [predicates](../Func/Predicate.md). At the moment,
only `.AssertType()` is left.

Note that some of these methods might return very soon, if they end up
being reasonable enough to keep as shorthand. Otherwise, feel free to put
them back with some help of [extension classes](../basics.md#getting-started).
In fact, I encourage you to do so, if you find yourself using some of the old methods a lot. It's what this library is for!

## Function `Assert()`

Use `Assert()` for simple assertions, like this:

```ahk
Assert(4 == 4)
```

In this example `4 == 4` is an expression that should return either `true` or
`false`. Whenever an expression evaluates to `false`, `Assert()` will throw
an error.

## Method `.Assert(Condition, Args*)`

You can also use it as a method, generically with the help of
[predicate](../Func/Predicate.md) functions.

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

To assert that a value is member of a given type `T`, you can use
`.AssertType(T)`:

```ahk
Val.AssertType(String)
```

This is equivalent to `.Assert(InstanceOf(String))`, and will assert that `Val`
is an instance of `String`.

Because `InstanceOf(T)` makes use of [duck types](./DuckTypes.md), you can
pass basically anything as a type pattern. Use `DerivedFrom(T)` to explitly
assert that something `is T`.

```ahk
Arr := Array()
Arr.Push({ Value: 42 })
...
Pattern := Array.OfType({ Value: Integer })
Arr.AssertType(Pattern) ; asserts that `Arr.Is(Pattern)`

"foo".Assert(DerivedFrom(String)) ; asserts that `"foo" is String`
```

**See Also**:

- [<Func/Predicate>](../Func/Predicate.md)
- [<Base/DuckTypes>](./DuckTypes.md)

## Some More Examples

Here's some more examples of how to use this in practice.

Generically, I'm using `.Assert()` together with predicate functions, because
that's arguably the most flexible way to do assertions.

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

GetUserInput() {
    Input := ...
    return Input.Assert( InstanceOf(String).AndNot(IsSpace) )
}

; By the way, assertions are great for unit tests!
; (exerpt from somewhere in `tests/.../Map.ahk`)
...
  static IsEmpty_should_eq_true() {
    Map().IsEmpty.Assert(Eq(true))
  }
...
```
