# <[Base](../overview.md)/[DuckTypes](../DuckTypes.md)/[Callable](./Callable.md)>

- [Overview](#overview)

## Overview

A [duck type](../DuckTypes.md) that represents any callable object.

`Callable` is considered a subtype of `Object`, and a supertype of `Func`.

```ahk
MsgBox.Is(Callable) ; true

Obj := { Call: (_) => MsgBox("calling method...") }
Obj.Is(Callable) ; true

Callable.CanCastFrom(Func) ; --> true
```
