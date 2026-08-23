# <[Base](../overview.md)/[DuckTypes](../DuckTypes.md)/[Callable](../../../src/Base/DuckTypes/Callable.ahk)>

- [\<Base/DuckTypes/Callable\>](#baseducktypescallable)
  - [Overview](#overview)

## Overview

A [duck type](../DuckTypes.md) that represents anything that is callable.

```ahk
MsgBox.Is(Callable) ; ==> true
{ Call: ... }.Is(Callable) ; ==> true
```

Not every instance of `Callable` might be an `Object`:

```ahk
DefineProp(String.Prototype, "Call", { Call: ... })
"str".Is(Callable) ; ==> true

Object.CanCastFrom(Callable) ; ==> false
```

Every class whose prototype defines `Call` is a subtype of `Callable`.

This includes `Func` and its subclasses:

```ahk
Callable.CanCastFrom(Func) ; ==> true

class Iterator {
    Call() {

    }
}
Callable.CanCastFrom(Iterator) ; ==> true
```
