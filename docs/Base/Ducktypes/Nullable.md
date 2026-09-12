# <[Base](../../Base/overview.md)/[DuckTypes](../DuckTypes.md)/[Nullable](../../../src/Base/DuckTypes/Nullable.ahk)>

- [\<Base/DuckTypes/Nullable\>](#baseducktypesnullable)
  - [Overview](#overview)
  - [Checking Properties of an Object](#checking-properties-of-an-object)
  - [Also See](#also-see)

## Overview

The nullable type defines a variation of an existing type which can be `unset`.

```ahk
MaybeStr := Nullable(String)

MaybeStr.IsInstance(unset) ; true
MaybeStr.IsInstance("Str") ; true
MaybeStr.IsInstance(342.1) ; false
```

Not to be confused with [`Optional`](../../Monads/Optional.md). It's a container for a value that might be present or absent, whereas `Nullable` is exclusively for representing types.

Instances of `Nullable` are also classes, which means you can use the "square bracket" syntax to create [generic array classes](../../Collections/Generic/Array.md):

```ahk
MaybeStrs := Nullable(String)[] ; class Array<Nullable<String>>

; works too, but avoid -- see *type wrappers* in <Base/DuckTypes>
MaybeStrs := String[Nullable]
```

## Checking Properties of an Object

You can also use them in plain objects to assert that a property is either absent or has a certain type:

```ahk
T := { Value: Nullable(String) }

T.IsInstance({ Value: unset })     ; true
T.IsInstance({ Value: "Hello" })   ; true
T.IsInstance({ Value: [1, 2, 3] }) ; false
```

## Also See

- [generic arrays](../../Collections/GenericArray.md)
- [duck types](../DuckTypes.md)
- [`Nothing`](./Nothing.md)
