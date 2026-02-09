# <[Base](../../Base/overview.md)/[DuckTypes](../DuckTypes.md)/[Nullable](../../../src/Base/DuckTypes/Nullable.ahk)>

## Summary

A [type wrapper](../DuckTypes.md#nullable) that allows matching both `unset`
and values of an inner type.

```ahk
MaybeStr := Nullable(String)

MaybeStr.IsInstance(unset) ; true
MaybeStr.IsInstance("Str") ; true
MaybeStr.IsInstance(342.1) ; false
```

Because `Nullable` is a type wrapper, you can pass it between the brackets
when creating a generic array class.

```ahk
MaybeStrs := String[Nullable] ; array of nullable string
```

**Also See**:

- [generic arrays](../../Collections/GenericArray.md)
- [duck types](../DuckTypes.md)
