# Any

## Piping with `.__Call()` and `.o0()`

This feature allows you to streamline code in the form of pipelines like you
would in languages like Bash or PowerShell.

### `(Any) __Call()`

(requires `>=2.0.5`)

When calling an undefined method on any value, it'll be assumed to be a
*global function*. In other words, `A.B()` will be converted into
`B(A)`, if `B()` is not a valid property of `A`.

One of the key features of AquaHotkeyX is that you can call undefined methods,
and they'll be **assumed to be global functions**.

```ahk
"  Hello  ".Trim().StrUpper()

; same as...
StrUpper(Trim("  Hello  "))
```

### `(Any) .o0()`

This method accepts a function to pipe to, followed by zero or more arguments.

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
