# <[Base](../../Base/overview.md)/[DuckTypes](../DuckTypes.md)/[Nothing](../../../src/Base/DuckTypes/Nothing.ahk)>

## Overview

A [duck type](../DuckTypes.md) that represents the `unset`, the absence of a value.

## As Type Pattern

The only instance of `Nothing` is `unset`.

```ahk
Nothing.IsInstance(42)    ; false
Nothing.IsInstance(unset) ; true
```

`Nothing` can be used as part of a larger type pattern (e.g. in plain objects or arrays) to assert that a property does not exist / an array item is unset:

```ahk
{ Value: 42 }.Is({ Value: Nothing }) ; => false (because `42` is not `Nothing`)

( [unset, 42] ).Is( [Nothing, Number] ) ; ==> true
```

## Type Relation

`Nothing` is a subclass of `Nullable( ... )`. It can only be cast from `Nothing` itself, or from `unset`, but nothing else.

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
