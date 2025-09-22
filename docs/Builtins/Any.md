# Any

## Piping with `.__Call()` and `.o0()`

One of the key features of AquaHotkeyX is that you can call undefined methods,
and they'll be **assumed to be global functions**.

Inspired by Elixir's `|>` operator, this feature lets you write very
streamlined code in the form of method chains.

### `.__Call()`

Whenever a variable calls an unknown property, it searches for a global function
to pipe to.

```ahk
"  Hello  ".Trim().StrUpper()

; same as...
StrUpper(Trim("  Hello  "))
```

### `.o0()`

The `.o0()` method is a more explicit version of `.__Call()`, and directly
accepts the function to pipe to. It's also slightly faster because of that.

```ahk
"  Hello, world!  ".o0(Trim).o0(StrUpper).o0(MsgBox)
```

I recommend using this version over `.__Call()`, because you're not limited
to global function and it performs better.

<sub>(Note: `.o0()` kind of looks like water bubbles, hence the name)</sub>

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
