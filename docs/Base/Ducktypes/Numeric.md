# <[Base](../../Base/overview.md)/[DuckTypes](../DuckTypes.md)/[Numeric](../../../src/Base/DuckTypes/Numeric.ahk)>

## Summary

A [duck type](../DuckTypes.md) that represents any numeric value, including
numeric strings.

```ahk
"-123.2".Is(Numeric) ; true
```

`Numeric` is considered a subtype of `Primitive`, and a supertype of `Number`.

```ahk
Numeric.CanCastFrom(Number)    ; true
Primitive.CanCastFrom(Numeric) ; true
```
