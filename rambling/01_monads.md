# My Obsession With Monads

I've always found functional programming languages to be super interesting, because of how abstract and pretty they feel ("this function *is* ...") compared to imperative languages ("this function *does* ...").

What's a monad?

Let's take `Optional` as an example: An object that may or may not contain a value.
... it sounds a lot like `unset`. Because it's really similar.

1. Monads wrap around a single value, to give it more *context*.

An object saying "it's this value, but with an additional feature". In this case, nullability.

2. You can take the internal value of this wrapper, make changes, and create a new wrapper.

A way to take the internal value, and transform it into another monad with a different value.
Sounds weird, so let me show you an example:

```ahk
class Optional {
  ...

  Map(Mapper) {
    if (this.IsEmpty) {
      return Optional.Empty()
    }
    return Optional(Mapper(this.Value))
  }
}
```

If the optional is empty, an empty optional is returned. Otherwise, the internal value is taken, transformed by applying `Mapper`, and then put into a new optional.
Really convenient when you want to avoid if-checks after every operation you're doing.

```ahk
Optional("foo").RetainIf(InStr, "f")
    .RemoveIf(s => StrLen(s) > 6)
    .IfPresent(MsgBox)
    .ElseThrow()

; same as...
Str := "foo"
if (InStr(Str, "f") && !(StrLen(Str) > 6)) {
    MsgBox(Str)
} else {
    throw Error()
}
```

Pretty neat, right? It's one reason why AquaHotkeyX leans so much into FP; I'm just into wacky stuff.
As of now, we have...

- `Supplier`: A single zero-param function that gives back a value on demand
- `Optional`: Container that might or might not have a value
- `Lazy`: Like a supplier, but memoized after the first call
- `Stream`: A lazy-eval pipeline / absolute powerhouse

There's more coming in the near future, but I don't know what to continue with. I'm guessing a monad for `try/catch` would be interesting, the way Vavr does it.