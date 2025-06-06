# Comparator

## Overview

A `Comparator` is a function object used for comparison and sorting, which
orders its two arguments by value and returns:

- a positive integer, if `a < b`,
- zero, if `a == b`, and
- a negative integer, if `a > b`.

To allow more sophisticated sorting, this class composes and stacks multiple
comparator instances using the `.AndThen()` and `.Compose()` methods.

Methods `.NullsFirst()` and `.NullsLast()` create null-friendly comparators,
which order `unset` higher or lower than other elements, sorting them at the
beginning or end of an array. When creating such a comparator, they must be
used as last operation.

```ahk
ByStrLen   := Comparator.Numeric().Compose(StrLen)
Alphabetic := Comparator.Alphabetic()

; [unset, "a", "bar", "foo", "Hello, world!"]
Array("foo", "bar", "a", "Hello, world!", unset).Sort(
    ByStrLen.AndThen(Alphabetic).NullsFirst())
```

---

## Method Summary

| Method Name                                            | Return Type  | Description                                                      |
| ------------------------------------------------------ | ------------ | ---------------------------------------------------------------- |
| [`__New(Comp)`](#__New)                                | `Comparator` | Creates a new comparator                                         |
| [`AndThen(Other)`](#AndThen)                           | `Comparator` | Specifies a second comparator to use when two elements are equal |
| [`Compose(Other)`](#Compose)                           | `Comparator` | Makes the comparator extract a value before comparison           |
| [`Reversed()`](#Reversed)                              | `Comparator` | Reverses the comparator                                          |
| [`NullsFirst()`](#NullsFirst)                          | `Comparator` | Orders `unset` before other elements                             |
| [`NullsLast()`](#NullsLast)                            | `Comparator` | Orders `unset` after other elements                              |
| [`static Numeric()`](#Numeric)                         | `Comparator` | Returns a numerical comparator                                   |
| [`static Alphabetic(CaseSense := false)`](#Alphabetic) | `Comparator` | Returns a lexicographical comparator                             |

---

## Method Details

<a id="__New"></a>

### `__New(Comp: Func) => Comparator`

**Description**:

Constructs a new `Comparator` from the given callback function `Comp`, which
compares two elements.

**Example**:

```ahk
Callback(a, b) {
    if (a > b) {
        return 1
    }
    if (a < b) {
        return -1
    }
    return 0
}
```

**Parameters**:

| Parameter Name | Type   | Description                          |
| -------------- | ------ | ------------------------------------ |
| `Comp`         | `Func` | Callback that is used for comparison |

**Return Value**:

- **Type**: `Comparator`

---

<a id="AndThen"></a>

### `AndThen(Other: Comparator) => Comparator`

**Description**:

Specifies a second `Comparator` to use whenever two elements are evaluated
as equal (whenever `Comp(a, b) == 0`)

**Example**:

```ahk
ByLength := Comparator.Numeric().Compose(StrLen)
Alphabetical := Comparator.Alphabetical(false)

; ["", "zz", "bar", "foo"]
Array("foo", "zz", "bar", "").Sort(ByLength.AndThen(Alphabetical))
```

**Parameters**:

| Parameter Name | Type         | Description              |
| -------------- | ------------ | ------------------------ |
| `Other`        | `Comparator` | Second comparator to use |

**Return Value**:

- **Type**: `Comparator`

---

<a id="Compose"></a>

### `Compose(Mapper: Func, Args: Any*) => Comparator`

**Description**:

Returns a new `Comparator` that first extracts a value to be used for comparison
by applying the given `Mapper` function.

`Mapper` is called using each elements as first argument respectively,
followed by zero or more additional arguments `Args*`.

**Example**:

```ahk
ByStringLength := Comparator.Alphabetic().Compose(StrLen)

; ["", "a", "l9", "foo"]
Array("foo", "a", "", "l9").Sort(ByStringLength)
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Mapper`       | `Func` | Function that extracts a sort key |

**Return Value**:

- **Type**: `Comparator`

---

<a id="Reversed"></a>

### `Reversed() => Comparator`

**Description**:

Reverses the order of this `Comparator`.

**Example**:

```ahk
; [4, 3, 2, 1]
Array(4, 2, 3, 1).Sort(Comparator.Numeric().Reversed())
```

**Return Value**:

- **Type**: `Comparator`

---

<a id="NullsFirst"></a>

### `NullsFirst() => Comparator`

**Description**:

Returns a new `Comparator` which considers `unset` to be lesser than the
non-null elements.

**Example**:

```ahk
NullsFirst := Comparator.Numeric().NullsFirst()

; [unset, unset, 1, 2, 3, 4]
Array(4, 3, 2, unset, unset, 1).Sort(NullsFirst)
```

**Return Value**:

- **Type**: `Comparator`

---

<a id="NullsLast"></a>

### `NullsLast() => Comparator`

**Description**:

Returns a new `Comparator` which considers `unset` to be lesser than the
non-null elements.

**Example**:

```ahk
NullsLast := Comparator.Numeric().NullsLast()
```

**Return Value**:

- **Type**: `Comparator`

---

<a id="Numeric"></a>

### `static Numeric() => Comparator`

**Description**:

Returns a `Comparator` that orders numbers or numeric strings by their
natural order.

**Example**:

```ahk
Comp := Comparator.Numeric()

; [1, 2, 3, 4, 5]
Array(2, 5, 3, 4, 1).Sort(Comp)
```

**Return Value**:

- **Type**: `Comparator`

---

<a id="Alphabetic"></a>

### `static Alphabetic(CaseSense := false) => Comparator`

**Description**:

Returns a `Comparator` which lexicographically orders two strings with
the given case sensitivity `CaseSense`.

**Example**:

```ahk
Comp := Comparator.Alphabetic()

; ["apple", "banana", "kiwi"]
Array("kiwi", "apple", "banana").Sort(Comp)
```

**Parameters**:

| Parameter Name       | Type             | Description                         |
| -------------------- | ---------------- | ----------------------------------- |
| `CaseSense := false` | `Boolean/String` | Case sensitivity of the comparison  |

**Return Value**:

- **Type**: `Comparator`

---
