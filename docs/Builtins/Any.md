# Any

## Piping with `__Call()` and `.o0()`

One of the key features of AquaHotkeyX is that you can call undefined methods,
and they'll be **assumed to be global functions**.

```ahk
"Hello".StrUpper()

StrUpper("Hello")
```

It works because the `Any.__Call()` method is overwritten not to throw an
error, but to search for a function to be piped to.

This feature is directly inspired by Elixir's `|>` operator and lets you write
code in the form of long method chains.

```ahk
"Hello, world!".DoThis().DoThat("foo").StrUpper().MsgBox()

MsgBox(StrUpper(DoThat(DoThis("Hello, world!"), "foo")))
```

The `.o0()` method is more explicit and directly accepts the function to be
called. It is also marginally faster than `__Call()`.

```ahk
"Hello, world!".o0(StrUpper).o0(MsgBox)
```

### Performance

For most cases, the performance overhead is negligible and outweighed by
readability gains.

However:

- Avoid use with large strings. They are copied each time you call a method,
  adding significant overhead.
- For numbers, objects, arrays - performance is solid and will likely improve
  further.

---

## Class Identification

You can access the defining class of an object by accessing the `.Class`
property. This is useful whenever you want to call a static property from the
class that defines the object.

```ahk
"foo".Class ; String

MyObject.Class.StaticProp()
```

---

## Assertions and Testing

The `.Assert()` method (and related ones like `.AssertEquals()` and
`.AssertType()`) make testing in one-liners more straightforward. They work
great together with the `Mapper`, `Condition` utility classes for building
test cases or error checks.

```ahk
MyArr.AssertType(Array)

"foo".Assert(StrLen.AndThen(Condition.Greater(2)))
```
