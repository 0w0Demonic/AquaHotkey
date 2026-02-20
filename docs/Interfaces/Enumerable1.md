# <[Interfaces](./overview.md)/[Enumerable1](../../src/Interfaces/Enumerable1.ahk)>

- [Overview](#overview)
- [Collection](#collection)
- [Side Effects](#side-effects)
- [Find Values](#find-values)
- [Quantifiers](#quantifiers)
- [Reduction](#reduction)

## Overview

`Enumerable1` is the base interface for all things that are enumerable with
exactly one parameter. It provides methods for collection, side effects,
finding values, quantifiers, and reduction of elements.

**Also See**:

- [<Interfaces/Enumerable2>](./Enumerable2.md)

## Collection

Use `.ToArray()` or `.ToSet()` to collect the elements of an enumerable
into an array or set, respectively.

```ahk
Range(10).ToArray() ; [1, 2, 3, ..., 10]
Range(10).ToSet()   ; {1, 2, 3, ..., 10}
```

`.ToArray()` allows you to specify any class that implements [IArray](../Interfaces/IArray.md) as the target collection type.

```ahk
Range(10).ToArray(LinkedList) ; LinkedList(1, 2, 3, ..., 10)
```

`.ToSet()` works similarly, but with the [ISet parameter](../Interfaces/ISet.md#construction).

```ahk
Range(10).ToSet(HashSet) ; HashSet(1, 2, 3, ..., 10)
```

To collect elements using any varargs function, use `.Collect()`.

```ahk
Range(10).Collect(Array) ; same as Array(Range(10)*) --> [1, 2, ..., 10]
```

## Side Effects

To perform a side-effect for every element, use `.ForEach()`.

```ahk
Range(5).ForEach(MsgBox, "Title", 0x40)

; equivalent to:
;   for Value in Range(5) {
;       MsgBox(Value, "Title", 0x40)
;   }
```

## Find Values

You can search for elements that match a
[predicate function](../Func/Predicate.md) by using `.Find()`.

To find elements by value, use `.FindValue()` or `.Contains()`. These methods
both use [`.Eq()`](../Base/Eq.md) to determine equality.

```ahk
Range(10).Find(Gt(5))  ; Optional<6>
Range(10).FindValue(5) ; Optional<5> (determined by `5.Eq(5)`)
```

To instead find the index of matching elements, use `.FindIndex()` and
`.IndexOf()`:

```ahk
A := Array("apple", "banana", "cherry")

A.FindIndex(InStr, "b") ; 2 ("banana")
A.IndexOf("cherry")     ; 3 (determined via `.Eq()`)
```

## Quantifiers

To test whether all, any, or none of the elements satisfy a predicate, use
`.All()`, `.Any()`, or `.None()`, respectively.

```ahk
Even(x) => !(x & 1)

Range(10).All(IsNumber) ; true
Range(10).Any(Even) ; true
Range(10).None(InstanceOf(String)) ; true
```

## Reduction

To combine the elements of an enumerable into a single value, use `.Reduce()`
or one of the many reduction methods like `.Sum()`, `.Product()`, `.Min()`.
`.Max()`, and `.Join()`.

```ahk
Range(10).Reduce(Sum) ; 55
Range(10).Join(", ")  ; "1, 2, 3, ..., 10"
Range(10).Max()       ; 10 (via `.Compare()` - see <Base/Comparable>)
```

Currently, `.Reduce()` will throw an error if the enumerable is empty
whenever no initial value is specified, because there is nothing to reduce.
However, if the provided function is a [monoid](../Func/Monoid.md), it will
use its identity as the default value instead.

```ahk
Array().Reduce(Sum) ; 0 (fallback to default value `Sum.Identity`)
```

In the future, reduction methods that otherwise don't support empty enumerables
might return [optional values](../Monads/Optional.md) instead of throwing
an error, so that you can handle empty enumerables more gracefully.

**Also See**:

- [Monoids](../Func/Monoid.md)
- [Transducers](../Func/Transducer.md)
