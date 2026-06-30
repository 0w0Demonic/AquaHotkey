# <[Base](../overview.md)/[DuckTypes](../DuckTypes.md)/[Callable](../../../src/Base/DuckTypes/Callable.ahk)>

- [\<Base/DuckTypes/Callable\>](#baseducktypescallable)
  - [Overview](#overview)

## Overview

A [duck type](../DuckTypes.md) that represents any callable object.

`Callable` is considered a subtype of `Object`, and a supertype of `Func`.

```ahk
MsgBox.Is(Callable) ; true

Obj := { Call: (_) => MsgBox("calling method...") }
Obj.Is(Callable) ; true

; every `Func` is callable by definition
Callable.CanCastFrom(Func) ; --> true
```
