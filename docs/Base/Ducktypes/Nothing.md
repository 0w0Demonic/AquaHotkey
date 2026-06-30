# <[Base](../../Base/overview.md)/[DuckTypes](../DuckTypes.md)/[Nothing](../../../src/Base/DuckTypes/Nothing.ahk)>

## Overview

A type that represents `unset`.

## As Type Pattern

The only instance of `Nothing` is `unset`.

```ahk
Nothing.IsInstance(42)    ; false
Nothing.IsInstance(unset) ; true
```

You can also use it in a "plain object pattern" to assert that a property does not exist:

```ahk
{ Value: 42 }.Is({ Value: Nothing }) ; => false (because `42` is not `Nothing`)
```

## Type Relation

`Nothing` is a subclass of `Nullable( ... )`. It can only be cast from `Nothing`
itself, or from `unset`, but nothing else.

```ahk
Nothing.CanCastFrom(unset) ; true

; `Nullable(String)` is essentially `String | unset`, whereas `Nothing`
; is equivalent to just `unset`. Therefore, it is a subtype.
Nullable(String).CanCastFrom(Nothing) ; => true


Nothing.CanCastFrom(Nothing) ; true
Nothing.CanCastFrom(unset)   ; true

Nothing.CanCastFrom(Any) ; false
Any.CanCastFrom(Nothing) ; false
```

**Also See**:

- [duck types](../DuckTypes.md)
- [`Nullable`](./Nullable.md)
