# Array

---

## Method Summary

| Method Name                                                                        | Return Type   | Description                                                                  |
| ---------------------------------------------------------------------------------- | ------------- | ---------------------------------------------------------------------------- |
| [`SetDefault(Default)`](#SetDefault)                                               | `this`        | Sets the default value of this array                                         |
| [`SetLength(Length)`](#SetLength)                                                  | `this`        | Sets the length of this array                                                |
| [`SetCapacity(Capacity)`](#SetCapacity)                                            | `this`        | Sets the capacity of this array                                              |
| [`Slice(Begin, End, Step)`](#Slice)                                                | `Array`       | Returns a section of this array from `Begin` to `End` with interval `Step`   |
| [`Swap(a, b)`](#Swap)                                                              | `this`        | Swaps two elements at indices `a` and `b`                                    |
| [`Reverse()`](#Reverse)                                                            | `this`        | Reverses this array in place                                                 |
| [`Sort(Comparator?, Reversed := false)`](#Sort)                                    | `this`        | Sorts this array according to `Comparator`                                   |
| [`SortAlphabetically(CaseSense := false, Reversed := false)`](#SortAlphabetically) | `this`        | Sorts this array according to `StrCompare()`                                 |
| [`Max(Comparator?)`](#Max)                                                         | `Any`         | Returns the highest element according to `Comparator`                        |
| [`Min(Comparator?)`](#Min)                                                         | `Any`         | Returns the lowest element according to `Comparator`                         |
| [`Sum()`](#Sum)                                                                    | `Float`       | Returns the total sum of numbers                                             |
| [`Average()`](#Average)                                                            | `Float`       | Returns the arithmetic mean of numbers                                       |
| [`Map(Mapper, Args*)`](#Map)                                                       | `Array`       | Transforms items using `Mapper`                                              |
| [`ReplaceAll(Mapper, Args*)`](#ReplaceAll)                                         | `Array`       | Transforms items in place using `Mapper`                                     |
| [`FlatMap(Mapper?, Args*)`](#FlatMap)                                              | `Array`       | Transforms and flattens items using `Mapper`                                 |
| [`RetainIf(Condition, Args*)`](#RetainIf)                                          | `Array`       | Returns an array of all elements that satisfy `Condition`                    |
| [`RemoveIf(Condition, Args*)`](#RemoveIf)                                          | `Array`       | Returns an array of all elements that do not satisfy `Condition`             |
| [`Partition(Condition, Args*)`](#Partition)                                        | `Map`         | Splits elements into map entries `true` and `false` according to `Condition` |
| [`GroupBy(Classifier, CaseSense := true)`](#GroupBy)                               | `Map`         | Groups elements into a map according to `Classifier`                         |
| [`Distinct(CaseSense := true, Hasher?)`](#Distinct)                                | `Array`       | Returns all unique elements of the array                                     |
| [`Join(Delimiter := "", InitialCap?)`](#Join)                                      | `String`      | Concatenates all elements into a string, items separated by `Delimiter`      |
| [`JoinLine(InitialCap?)`](#JoinLine)                                               | `String`      | Concatenates all elements into a string, items separated by `\n`             |
| [`Reduce(Combiner, Identity?)`](#Reduce)                                           | `Any`         | Reduces all elements according to `Combiner`                                 |
| [`ForEach(Action, Args*)`](#ForEach)                                               | `this`        | Applies the given `Action` on every element                                  |
| [`ToString()`](#ToString)                                                          | `String`      | Returns a string representation of the array                                 |

---

## Property Summary

| Property Name | Property Type | Return Type | Description                              |
| ------------- | ------------- | ----------- | ---------------------------------------- |
| `IsEmpty`     | `get`         | `Boolean`   | Returns `true`, if this array is empty   |
| `HasElements` | `get`         | `Boolean`   | Returns `true`, if this array has values |

---

## Method Details

<a id="SetDefault"></a>

### `SetDefault(Default: Any) => this`

**Description**:

Sets the `Default` property of this array.

**Example**:

```ahk
Arr := Array(unset).SetDefault("(empty)")

MsgBox(Arr[1]) ; "(empty)"
```

**Parameters**:

| Parameter Name | Type  | Description                                              |
| -------------- | ----- | -------------------------------------------------------- |
| `Default`      | `Any` | The default value returned whenever an item has no value |

**Return Value**:

- **Type**: `this`

---

<a id="SetLength"></a>

### `SetLength(Length: Integer) => this`

**Description**:

Sets the `Length` property of this array.

**Example**:

```ahk
Arr := Array("foo").SetLength(2)
MsgBox(Arr.Length) ; 2
```

**Parameters**:

| Parameter Name | Type      | Description                  |
| -------------- | --------- | ---------------------------- |
| `Length`       | `Integer` | The new length of this array |

**Return Value**:

- **Type**: `this`

---

<a id="SetCapacity"></a>

### `SetCapacity(Capacity: Integer) => this`

**Description**:

Sets the capacity of this array.

**Example**:

```ahk
Arr := Array().SetCapacity(16)

MsgBox(Arr.Capacity) ; 16
```

**Parameters**:

| Parameter Name | Type      | Description                    |
| -------------- | --------- | ------------------------------ |
| `Capacity`     | `Integer` | The new capacity of this array |

**Return Value**:

- **Type**: `this`

---

<a id="Slice"></a>

### `Slice(Begin: Integer := 1, End: Integer := this.Length, Step: Integer := 1) => Array`

**Description**:

Returns a section of this array from range `Begin` to `End`, with an interval
`Step` between elements.

**Example**:

```ahk
Array(1, 2, 3, 4).Slice(3)             ; [3, 4]
Array("foo", "bar", "baz").Slice(, -1) ; ["foo", "bar"]
Array(1, 2, 3, 4, 5).Slice(,, 2)       ; [1, 3, 5]
```

**Parameters**:

| Parameter Name | Type                     | Description                |
| -------------- | ------------------------ | -------------------------- |
| `Begin`        | `Integer := 1`           | First index of array slice |
| `End`          | `Integer := this.Length` | Last index of array slice  |
| `Step`         | `Integer := 1`           | Interval between elements  |

**Return Value**:

- **Type**: `Array`

---

<a id="Swap"></a>

### `Swap(a: Integer, b: Integer) => this`

**Description**:

Swaps two elements at indices `a` and `b` in place.

**Example**:

```ahk
Arr := Array("foo", "bar")
Arr.Swap(1, 2)

MsgBox(Arr[1]) ; "bar"
```

**Parameters**:

| Parameter Name | Type      | Description             |
| -------------- | --------- | ----------------------- |
| `a`            | `Integer` | Index of first element  |
| `b`            | `Integer` | Index of second element |

**Return Value**:

- **Type**: `this`

---

<a id="Reverse"></a>

### `Reverse() => this`

**Description**:

Reverses all elements in this array in place.

**Example**:

```ahk
Arr := Array(1, 2, 3).Reverse()

MsgBox(Format("{} {} {}", Arr*)) ; "3 2 1"
```

**Return Value**:

- **Type**: `this`

---

<a id="Sort"></a>

### `Sort(Comparator: Comparator?, Reversed: Boolean := false) => this`

**Description**:

Sorts this array in place, according to a `Comparator` function which order two
elements. Otherwise, elements in this array are sorted using numerical
comparison.

This array is sorted in reverse order, if `Reversed` is set to `true`.

**See**:

[Comparator](./../Extensions/Comparator.md)

**Example**:

```ahk
Array(3, 2, 5, 1, 4).Sort()                 ; [1, 2, 3, 4, 5]
Array("foo", "bar", "baz").Sort(StrCompare) ; ["bar", "baz", "foo"]
Array(3, 2, 5, 1, 4).Sort(, true)           ; [5, 4, 3, 2, 1]
```

**Parameters**:

| Parameter Name | Type               | Description                       |
| -------------- | ------------------ | --------------------------------- |
| `Comparator`   | `Comparator?`      | Function that orders two values   |
| `Reversed`     | `Boolean := false` | Sort this array in reverse order  |

**Return Value**:

- **Type**: `this`

---

<a id="SortAlphabetically"></a>

### `SortAlphabetically(CaseSense: Primitive := false, Reversed: Boolean := false) => this`

**Description**:

Lexicographically sorts this array in place using `StrCompare()`.

**Example**:

```ahk
Array("foo", "bar", "baz").SortAlphabetically() ; ["bar", "baz", "foo"]
```

**Parameters**:

| Parameter Name | Type                 | Description                               |
| -------------- | -------------------- | ----------------------------------------- |
| `CaseSense`    | `Primitive := false` | Case-sensitivity of the string comparison |
| `Reversed`     | `Boolean := false`   | Sort this array in reverse order          |

**Return Value**:

- **Type**: `this`

---

<a id="Max"></a>

### `Max(Comparator: Comparator?) => Any`

**Description**:

Returns the highest element in this array, according to the given `Comparator`
function.

If no comparator is specified, the largest number in this array is returned.

Unset elements are ignored. An `UnsetError` is thrown, if this array has no
values.

**See**:

[Comparator](./../Extensions/Comparator.md)

**Example**:

```ahk
Array(23, 1, 45, -2).Max() ; 45
```

**Parameters**:

| Parameter Name | Type          | Description                      |
| -------------- | ------------- | -------------------------------- |
| `Comparator`   | `Comparator?` | Function that orders two values  |

**Return Value**:

- **Type**: `Any`

---

<a id="Min"></a>

### `Min(Comparator: Comparator?) => Any`

**Description**:

Returns the lowest element in this array, according to the given `Comparator`
function.

If no comparator function is specified, the smallest number in this array is
returned.

Unset elements are ignored. An `UnsetError` is thrown, if this array
has no values.

**See**:

[Comparator](./../Extensions/Comparator.md)

**Example**:

```ahk
Array(23, 1, 45, -2).Min() ; -2
```

**Parameters**:

| Parameter Name | Type          | Description                      |
| -------------- | ------------- | -------------------------------- |
| `Comparator`   | `Comparator?` | Function that orders two values  |

**Return Value**:

- **Type**: `Any`

---

<a id="Sum"></a>

### `Sum() => Float`

**Description**:

Returns the total sum of numbers and numerical strings in this array.

**Example**:

```ahk
Array(1, 2, "3", unset, "foo") ; 6.0
```

**Return Value**:

- **Type**: `Float`

---

<a id="Average"></a>

### `Average() => Float`

Returns the arithmetic mean of all numbers and numerical strings of this array.

**Example**:

```ahk
Array(1, 2, "6", unset, "foo").Average() ; 3.0
```

**Return Value**:

- **Type**: `Float`

---

<a id="Map"></a>

### `Map(Mapper: Func, Args: Any*) => Array`

**Description**:

Returns a new array containing all values in this array transformed by applying
the given `Mapper` function.

`Mapper` is called using items in the array as first argument,
followed by zero or more additional arguments `Args*`.

Unset elements are ignored, unless `Mapper` explicitly supports unset
parameters.

**Example**:

```ahk
Array(1, 2, 3).Map(x => x * 2)        ; [2, 4, 6]
Array("foo", "bar").Map(SubStr, 1, 1) ; ["f", "b"]
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Mapper`       | `Func` | Function that returns a new element |
| `Args`         | `Any*` | Zero or more additional arguments   |

**Return Value**:

- **Type**: `Array`

---

<a id="ReplaceAll"></a>

### `ReplaceAll(Mapper: Func, Args: Any*) => this`

**Description**:

Transforms all values in the array in place, by applying the given `Mapper`
function.

`Mapper` is called using items in the array as first argument, followed by zero
or more additional arguments `Args*`.

**Example**:

```ahk
Arr := Array(1, 2, 3)
Arr.ReplaceAll(x => (x * 2))

Arr.Join(", ").MsgBox() ; "1, 2, 3"
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Mapper`       | `Func` | Function that returns a new element |
| `Args`         | `Any*` | Zero or more additional arguments   |

**Return Value**:

- **Type**: `this`

---

<a id="FlatMap"></a>

### `FlatMap(Mapper: Func?, Args: Any*) => Array`

**Description**:

Returns a new array containing all elements in this array transformed by the
given `Mapper` function, resulting arrays flattened into separate elements.

`Mapper` is called using items in this array as first argument, followed by
zero or more additional arguments `Args*`.

Unset elements are ignored, unless `Mapper` has optional parameters.

If `Mapper` is unset, no transformation is done and existing arrays are
flattened.

**Example**:

```ahk
Array("hel", "lo").FlatMap(StrSplit)       ; ["h", "e", "l", "l", "o"]
Array([1, 2], [3, 4]).FlatMap()            ; [1, 2, 3, 4]
Array("a,b", "c,d").FlatMap(StrSplit, ",") ; ["a", "b", "c", "d"]
```

**Parameters**:

| Parameter Name | Type   | Description                                    |
| -------------- | ------ | ---------------------------------------------- |
| `Mapper`       | `Func` | Function that transforms zero or more elements |
| `Args`         | `Any*` | Zero or more additional arguments              |

**Return Value**:

- **Type**: `Array`

---

<a id="RetainIf"></a>

### `RetainIf(Condition: Predicate, Args: Any*) => Array`

**Description**:

Returns a new array containing all elements in this array that match the
given predicate function `Condition`.

`Condition` is called using items in this array as first argument, followed
by zero or more arguments `Args*`.

Unset elements are removed, unless `Condition` has optional parameters.

**Example**:

```ahk
Array(1, 2, 3, 4).RetainIf(x => x > 2)                    ; [3, 4]
Array(unset, 2, 3).RetainIf(x => x > 2)                   ; [3]
Array(unset, 2, 3).RetainIf((x?) => (!IsSet(x) || x > 2)) ; [unset, 3]
Array("foo", "bar").RetainIf(InStr, "f")                  ; ["foo"]
```

**Parameters**:

| Parameter Name | Type        | Description                              |
| -------------- | ----------- | ---------------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition      |
| `Args`         | `Any*`      | Zero or more additional arguments        |

**Return Value**:

- **Type**: `Array`

---

<a id="RemoveIf"></a>

### `RemoveIf(Condition: Predicate, Args: Any*) => Array`

**Description**:

Returns a new array containing all elements in this array that do not match
the given predicate function `Condition`.

`Condition` is called using items in this array as first argument, followed
by zero or more arguments `Args*`.

Unset elements are removed, unless `Predicate` has optional parameters.

**Example**:

```ahk
Array(1, 2, 3, 4).RemoveIf(x => x > 2)                   ; [1, 2]
Array(unset, 2, 3).RemoveIf(x => x > 2)                  ; [2]
Array(unset, 2, 3).RemoveIf((x?) => (IsSet(x) && x > 2)) ; [unset, 2]
Array("foo", "bar").RemoveIf(InStr, "f")                 ; ["bar"]
```

**Parameters**:

| Parameter Name | Type        | Description                              |
| -------------- | ----------- | ---------------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition      |
| `Args`         | `Any*`      | Zero or more additional arguments        |

**Return Value**:

- **Type**: `Array`

---

<a id="Partition"></a>

### `Partition(Condition: Predicate, Args: Any*) => Map`

**Description**:

Separates all elements in this array into a `Map` object with two entries
`true` and `false`, based on whether they satisfy a given predicate
function `Condition`.

`Condition` is called using items in this array as first argument,
followed by zero or more additional arguments `Args*`.

Unset elements are removed, unless `Predicate` has optional parameters.

**Example**:

```ahk
IsEven(x) {
    return !(x & 1)
}

; Map {
;     true  => [2, 4],
;     false => [1, 3]
; }
Array(1, 2, 3, 4).Partition(IsEven)

IsUnsetOrEven(x?) {
    return !IsSet(x) || !(x & 1)
}

; Map {
;     true  => [2, unset],
;     false => [1, 3]
; }
Array(1, 2, 3, unset).Partition(IsUnsetOrEven)

; Map {
;     true  => ["foo"],
;     false => ["bar"]
; }
Array("foo", "bar").Partition(InStr, "f")
```

**Parameters**:

| Parameter Name | Type        | Description                              |
| -------------- | ----------- | ---------------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition      |
| `Args`         | `Any*`      | Zero or more additional arguments        |

**Return Value**:

- **Type**: `Map`

---

<a id="GroupBy"></a>

### `GroupBy(Classifier: Func, CaseSense: Primitive := true, Args: Any*) => Map`

**Description**:

Returns a map of all elements in this array grouped by a given function
`Classifier`, which returns the key used for the map.

`Classifier` is called using items in this array as first argument, followed
by zero or more additional parameters `Args*`.

Unset elements are ignored, unless `Classifier` has optional parameters.

Parameter `CaseSense` determines case-sensitivity of the underlying `Map`.

**Example**:

```ahk
LastDigit(x?) {
    if (!IsSet(x) || !IsNumber(x)) {
        return "undefined"
    }
    return Mod(x, 10)
}

; Map {
;     2 => [2],
;     3 => [3, 13],
;     4 => [4],
;     "undefined" => ["foo", unset]
; }
Array(2, 3, 34, 13, "foo", unset).GroupBy(LastDigit)

; Map {
;     "f" => ["foo"],
;     "b" => ["bar"]
; }
Array("foo", "bar").GroupBy(SubStr, false, 1, 1)
```

**Parameters**:

| Parameter Name | Type                | Description                            |
| -------------- | ------------------- | -------------------------------------- |
| `Classifier`   | `Func`              | Function that creates a map key        |
| `CaseSense`    | `Primitive := true` | Case-sensitivity of the map            |
| `Args`         | `Any*`              | Zero or more additional arguments      |

**Return Value**:

- **Type**: `Map`

---

<a id="Distinct"></a>

### `Distinct(CaseSenseOrHasher: Primitive/Func := true, CaseSense: Primitive?) => Array`

**Description**:

Returns a new array containing all unique elements of this array. This method
ensures that only unique elements remain in the resulting array.

Unset elements are removed.

`CaseSenseOrHasher`:

If a `Boolean` (`true` or `false`) or `String` (`"On"`, `"Off"` or `"Locale"`)
is provided, it determines the case-sensitivity of the internal `Map` used
for equality checks.

If a function object is provided, it is treated as a custom `Hasher` for
generating keys. This is useful for comparing objects based on their
values instead of their identity.

`CaseSense`:

Specifies case-sensitivity of the internal `Map`.
This method uses an underlying map object to keep track of previous
values, its case-sensitivity is determined by `CaseSense`.

**Example**:

```ahk
; [1, 2, 3]
Array(1, 2, 3, 1).Distinct()

; ["foo"]
Array("foo", "Foo", "FOO").Distinct(false)

; [{ Value: 1 }, { Value: 2 }]
Array({ Value: 1 }, { Value: 2 }, { Value: 1 }).Distinct(Obj => Obj.Value)
```

**Parameters**:

| Parameter Name     | Type                     | Description                            |
| ------------------ | ------------------------ | -------------------------------------- |
| `CaseSenseOrHasher`| `Primitive/Func := true` | Case-sensitivity or object hasher      |
| `CaseSense`        | `Primitive?`             | Case-sensitivity                       |

**Return Value**:

- **Type**: `Array`

---

<a id="Join"></a>

### `Join(Delimiter: String := "", InitialCap: Integer := 0) => String`

**Description**:

Concatenates all elements in this array into a string, each element separated by
`Delimiter`. Objects are converted to a string using their `.ToString()` method
whereas unset elements are ignored.

`InitialCap` specifies the initial capacity of the resulting string (default
`0`). This can improve performance when working with large strings by
pre-allocating the necessary memory.

**Example**:

```ahk
Array(1, 2, 3, 4).Join() ; "1234"
Array(1, unset, 2).Join(", ") ; "1, 2"
ReallyLargeArray.Join(", ", 1048576) ; 1 megabyte initial capacity
```

**Parameters**:

| Parameter Name | Type            | Description                        |
| -------------- | --------------- | ---------------------------------- |
| `Delimiter`    | `String`        | A string separating each element   |
| `InitialCap`   | `Integer := 0`  | Initial string capacity            |

**Return Value**:

- **Type**: `String`

---

<a id="JoinLine"></a>

### `JoinLine(InitialCap: Integer := 0) => String`

**Description**:

Concatenates all elements in this array into a string, each element separated
by a newline character `\n`.

**Example**:

```ahk
Array(1, 2, 3, 4).JoinLine() ; "1`n2`n3`n4"
```

**Parameters**:

| Parameter Name | Type            | Description                        |
| -------------- | --------------- | ---------------------------------- |
| `InitialCap`   | `Integer := 0`  | Initial string capacity            |

**Return Value**:

- **Type**: `String`

<a id="Reduce"></a>

### `Reduce(Combiner: Combiner, Identity: Any?) => Any`

**Description**:

Performs a reduction on the elements of this array, using the given `Combiner`
function. This method iteratively combines elements to produce a single
result, optionally starting with an `Identity` value.

Unset elements are ignored.

If specified, `Identity` is used as the starting value of the reduction.
Otherwise, the first elements is taken as initial value and reduction
starts on the second element. An error is thrown, if the array has no elements.

**Example**:

```ahk
Sum(a, b) {
    return a + b
}
Array(1, 2, unset, 3, unset, 4).Reduce(Sum) ; 10
Array(unset, unset, unset).Reduce(Sum)      ; Error!
Array(unset, unset, unset).Reduce(Sum, 2)   ; 2
```

**Parameters**:

| Parameter Name | Type       | Description                               |
| -------------- | ---------- | ----------------------------------------- |
| `Combiner`     | `Combiner` | Function that combines two values         |
| `Identity`     | `Any?`     | Starting value of the reduction operation |

**Return Value**:

- **Type**: `Any`

<a id="ForEach"></a>

### `ForEach(Action: Func, Args: Any*) => this`

**Description**:

Applies the given function `Action` on each element of this array.

`Action` is called using elements in this array as first argument, followed
by zero or more additional arguments `Args*`.

Unset elements are ignored, unless `Action` has optional parameters.

**Example**:

```ahk
Arr := Array()
Array(1, 2, 3, 4).ForEach(x => Arr.Push(x))
MsgBox(Arr.Length) ; 4

Array(1, 2, 3, 4).ForEach(MsgBox, "Listing numbers in array", 0x40)
```

**Parameters**:

| Parameter Name | Type   | Description                          |
| -------------- | ------ | ------------------------------------ |
| `Action`       | `Func` | The function to call on each element |
| `Args`         | `Any?` | Zero or more additional arguments    |

**Return Value**:

- **Type**: `this`

---

## Property Details

<a id="IsEmpty"></a>

### `IsEmpty => Boolean`

**Description**: Returns `true`, if this array is empty (its length is zero).

**Property Type**: `get`

**Example**:

```ahk
Array().IsEmpty   ; true
Array(42).IsEmpty ; false
```

**Return Value**:

- **Type**: `Boolean`

---

<a id="HasElements"></a>

### `HasElements => Boolean`

**Description**:

Returns `true` if this array has values (determined by `IsSet()`).

**Property Type**: `get`

**Example**:

```ahk
Array(unset, 42).HasElements    ; true
Array(unset, unset).HasElements ; false
```

**Return Value**:

- **Type**: `Boolean`

---

<a id="ToString"></a>

### `ToString() => String`

**Description**:

Returns a string representation of this array.

**Example**:

```ahk
Array(1, 2, 3, "4", unset).ToString() ; "[1, 2, 3, "4", unset]"
```

**Return Value**:

- **Type**: `String`
