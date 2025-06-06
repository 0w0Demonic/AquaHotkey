
# Map

## Method Summary

| Method Name                                              | Return Type | Description                                                                               |
| -------------------------------------------------------- | ----------- | ----------------------------------------------------------------------------------------- |
| [`SetDefault(Default)`](#SetDefault)                     | `this`      | Sets the `Default` property of this map                                                   |
| [`SetCapacity(Capacity)`](#SetCapacity)                  | `this`      | Sets the capacity of this map                                                             |
| [`SetCaseSense(CaseSense)`](#SetCaseSense)               | `this`      | Sets the case-sensitivity of this map                                                     |
| [`Keys()`](#Keys)                                        | `Array`     | Returns all key contained in this map                                                     |
| [`Values()`](#Values)                                    | `Array`     | Returns all values contained in this map transformed by applying `Mapper`                 |
| [`RetainIf(Condition, Args*)`](#RetainIf)                | `Map`       | Returns a map of all entries that match the given predicate function `Condition`          |
| [`RemoveIf(Condition, Args*)`](#RemoveIf)                | `Map`       | Returns a map of all entries that do match the given predicate function `Condition`       |
| [`ReplaceAll(Mapper, Args*)`](#ReplaceAll)               | `this`      | Changes all values in this map in place by applying the given `Mapper` function           |
| [`Map(Mapper, Args*)`](#Map)                             | `Map`       | Returns a map consisting of all entries in this map                                       |
| [`ForEach(Action, Args*)`](#ForEach)                     | `this`      | Applies a function `Action` on each map entry                                             |
| [`PutIfAbsent(Key, Value)`](#PutIfAbsent)                | `this`      | Adds a new entry `Key` and `Value`, if not present in this map                            |
| [`ComputeIfAbsent(Key, Mapper)`](#ComputeIfAbsent)       | `this`      | If an entry is not present, puts an entry `Key: Mapper(Key)` into this map                |
| [`ComputeIfPresent(Key, Mapper)`](#ComputeIfPresent)     | `this`      | If present, changes the value of an entry by applying `Mapper`                            |
| [`Compute(Key, Mapper)`](#Compute)                       | `this`      | Computes a mapping for the specified `Key` using the given `Mapper` function              |
| [`Merge(Key, Value, Mapper)`](#Merge)                    | `this`      | Merges a map entry `Key` with value `Value` using the given `Mapper` function             |
| [`AnyMatch(Condition, Args*)`](#AnyMatch)                | `Object`    | Returns `true`, if any entry in this map matches the given predicate function `Condition` |
| [`AllMatch(Condition, Args*)`](#AllMatch)                | `Boolean`   | Returns `true`, if all entries in this map match the given predicate function `Condition` |
| [`NoneMatch(Condition, Args*)`](#NoneMatch)              | `Boolean`   | Returns `true`, if no entry in this map matches the given predicate function `Condition`  |

---

## Property Summary

| Property Name         | Property Type | Return Type | Description                                |
| --------------------- | ------------- | ----------- | ------------------------------------------ |
| [`IsEmpty`](#IsEmpty) | `get`         | `Boolean`   | Returns `true`, if this map has no entries |

---

## Method Details

<a id="SetDefault"></a>

### `SetDefault(Default: Any) => this`

**Description**:

Sets the `Default` property of this map which is returned whenever an unset
item is requested.

**Example**:

```ahk
M := Map().SetDefault("")

M["foo"] ; ""
```

**Parameters**:

| Parameter Name | Type  | Description |
| -------------- | ----- | ----------- |
| `Default`      | `Any` | Any value   |

**Return Value**:

- **Type**: `this`

---

<a id="SetCapacity"></a>

### `SetCapacity(Capacity: Integer) => this`

**Description**:

Sets the capacity of this map.

**Example**:

```ahk
M := Map().SetCapacity(128)
```

**Parameters**:

| Parameter Name | Type      | Description                  |
| -------------- | --------- | ---------------------------- |
| `Capacity`     | `Integer` | The new capacity of this map |

**Return Value**:

- **Type**: `this`

---

<a id="SetCaseSense"></a>

### `SetCaseSense(CaseSense: Primitive) => this`

**Description**:

Sets the case-sensitivity of this map.

**Example**:

```ahk
M := Map().SetCaseSense("Off")

M["foo"] := "bar"
M["FOO"] := "baz"

MsgBox(M["foo"]) ; "baz"
```

**Parameters**:

| Parameter Name | Type        | Description              |
| -------------- | ----------- | ------------------------ |
| `CaseSense`    | `Primitive` | The new case-sensitivity |

**Return Value**:

- **Type**: `this`

---

<a id="Keys"></a>

### `Keys() => Array`

**Description**:

Returns an array containing all keys in this map.

**Example**:

```ahk
Map("foo", "bar", 1, 2).Keys() ; ["foo", 1]
```

**Return Value**:

- **Type**: `Array`

---

<a id="Values"></a>

### `Values() => Array`

**Description**:

Returns an array containing all values in this map.

**Example**:

```ahk
Map("foo", "bar", 1, 2).Values() ; ["bar", 2]
```

**Return Value**:

- **Type**: `Array`

---

<a id="RetainIf"></a>

### `RetainIf(Condition: Predicate, Args: Any*) => Map`

**Description**:

Returns a new map containing all current elements which satisfy the given
predicate function `Condition`.

`Condition` is called using key and value as first two arguments, followed
by zero or more optional arguments `Args*`.

**Example**:

```ahk
KeyIsString(Key, Value) {
    return (Key is String)
}

; Map {
;     "foo" ==> "bar"
; }
Map(1, 2, "foo", "bar").RetainIf(KeyEquals1)
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Predicate`    | `Func` | Function that evaluates a condition |
| `Args`         | `Any*` | Zero or more additional arguments   |

**Return Value**:

- **Type**: `Map`

---

<a id="RemoveIf"></a>

### `RemoveIf(Condition: Predicate, Args: Any*) => Map`

**Description**:

Returns a new map containing all current elements which do not satisfy the
given predicate function `Condition`.

`Condition` is called using key and value as first two arguments, followed
by zero or more additional arguments `Args*`

**Example**:

```ahk
KeyIsString(Key, Value) {
    return (Key is String)
}

; Map {
;     1 => 2
; }
Map(1, 2, "foo", "bar").RemoveIf(KeyEquals1)
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Predicate`    | `Func` | Function that evaluates a condition |
| `Args`         | `Any*` | Zero or more additional arguments   |

**Return Value**:

- **Type**: `Map`

---

<a id="ReplaceAll"></a>

### `ReplaceAll(Mapper: Func, Args: Any*) => this`

**Description**:

Replaces all values in this map *in place*, by applying the given
`Mapper` function on each element.

`Mapper` is called using key and value as first two arguments, followed by
zero or more additional parameters `Args*`.

**Example**:

```ahk
Increment(Key, Value) {
    return ++Value
}

; Map {
;     1 => 3,
;     2 => 5
; }
Map(1, 2, 3, 4).ReplaceAll(Increment)
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Mapper`       | `Func` | Function that returns a new value |

**Return Value**:

- **Type**: `this`

---

<a id="Map"></a>

### `Map(Mapper: Func, Args: Any*) => Map`

**Description**:

Returns a new map containing all current elements transformed by applying
the given `Mapper` function to generate a new value.

`Mapper` is called using key and value as first two arguments, followed by
zero or more additional arguments `Args*`.

**Example**:

```ahk
Increment(Key, Value) {
    return ++Value
}

; Map {
;     1 => 3,
;     2 => 5
; }
Map(1, 2, 3, 4).Map(Increment)
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Mapper`       | `Func` | Function that returns a new value |
| `Args`         | `Any*` | Zero or more additional arguments |

**Return Value**:

- **Type**: `Map`

---

<a id="ForEach"></a>

### `ForEach(Action: Func, Args: Any*) => this`

**Description**:

Calls the given `Action` function on each element of this map.

`Action` is called using key and value as first two arguments, followed
by zero or more additional arguments `Args*`.

**Example**:

```ahk
Print(Key, Value) {
    Msg := Format("key: {}, value: {}", Key, Value)
    MsgBox(Msg)
}

Map(1, 2, 3, 4, "foo", "bar").ForEach(Print)
```

**Parameters**:

| Parameter Name | Type   | Description                          |
| -------------- | ------ | ------------------------------------ |
| `Action`       | `Func` | The function to call on each element |
| `Args`         | `Any*` | Zero or more additional arguments    |

**Return Value**:

- **Type**: `this`

---

<a id="PutIfAbsent"></a>

### `PutIfAbsent(Key: Any, Value: Any) => this`

**Description**:

If absent, adds a new element `Key ==> Value` to this map.

**Example**:

```ahk
; Map {
;     "foo" => "bar"
; }

Map().PutIfAbsent("foo", "bar")
     .PutIfAbsent("foo", "baz")
```

**Parameters**:

| Parameter Name | Type  | Description              |
| -------------- | ----- | ------------------------ |
| `Key`          | `Any` | Key of the new element   |
| `Value`        | `Any` | Value of the new element |

**Return Value**:

- **Type**: `this`

---

<a id="ComputeIfAbsent"></a>

### `ComputeIfAbsent(Key: Any, Mapper: Func) => this`

**Description**:

If absent, adds a new element `Key` to this map, with its value computed
by applying the given `Mapper` function, using `Key` as argument.

**Example**:

```ahk
Times2(Key) {
    return (Key * 2)
}

; Map {
;     1 => 2
; }
Map().ComputeIfAbsent(1, Times2)
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Key`          | `Any`  | Key of the map entry              |
| `Mapper`       | `Func` | Function that returns a new value |

**Return Value**:

- **Type**: `this`

---

<a id="ComputeIfPresent"></a>

### `ComputeIfPresent(Key: Any, Mapper: Func) => this`

**Description**:

If present, replaces the value of element `Key` by applying the given
`Mapper` function, using key and value as arguments.

**Example**:

```ahk
Sum(Key, Value) {
    return Key + Value
}
; Map {
;     1 ==> 3
; }
Map(1, 2).ComputeIfPresent(1, Sum)
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Key`          | `Any`  | Key of the map entry              |
| `Mapper`       | `Func` | Function that returns a new value |

**Return Value**:

- **Type**: `this`

---

<a id="Compute"></a>

### `Compute(Key: Any, Mapper: Func) => this`

**Description**:

Puts an element `Key` into this map with its value computed by applying
the given `Mapper` function.

`Mapper` is called using key and value as arguments. If there is not yet anj
element present, `unset` is passed as current value.

**Example**:

```ahk
Frequency(Key, Value?) {
    return (Value ?? 0) + 1
}

; Map {
;     "foo" => 2,
;     "bar" => 1,
;     "baz" => 2
; }

M := Map()
for Value in Array("foo", "bar", "foo", "baz", "baz") {
    M.Compute(Value, Frequency)
}
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Key`          | `Any`  | Key of the map entry              |
| `Mapper`       | `Func` | Function that returns a new value |

**Return Value**:

- **Type**: `this`

---

<a id="Merge"></a>

### `Merge(Key: Any, Value: Any, Mapper: Func) => this`

**Description**:

If absent, adds a new element `Key ==> Value` to this map. Otherwise,
the value of element `Key` is replaced by applying the given `Mapper`
function.

`Mapper` is called using the current value and `Value` as arguments.

**Example**:

```ahk
Sum(OldValue, Value) {
    return (OldValue + Value)
}

; Map {
;     "foo" => 6
; }
Map().Merge("foo", 2, Sum)
     .Merge("foo", 4, Sum)
```

**Parameters**:

| Parameter Name | Type   | Description                     |
| -------------- | ------ | ------------------------------- |
| `Key`          | `Any`  | Key of the map entry            |
| `Value`        | `Any`  | Value of the map entry          |
| `Mapper`       | `Func` | Function that merges two values |

**Return Value**:

- **Type**: `this`

---

<a id="AnyMatch"></a>

### `AnyMatch(Condition: Predicate, Args: Any*) => Object`

**Description**:

Returns `true`, if any element in this map satisfies the given predicate
function `Condition`.

`Condition` is called using key and value as arguments, followed by zero or more
additional arguments `Args*`.

The first element that satisfies `Condition` (if present) is returned as
an object with properties `Key` and `Value`. Otherwise, `false` is returned.

**Example**:

```ahk
KeyEquals1(Key, Value) {
    return (Key == 1)
}

M := Map(1, 2, 3, 4).AnyMatch(KeyEquals1, &Key, &Value) ; true
if (Match := M.AnyMatch(KeyEquals1)) {
    MsgBox(Match.Key)
    MsgBox(Match.Value)
}

MsgBox(Key)   ; 1
MsgBox(Value) ; 2
```

**Parameters**:

| Parameter Name | Type      | Description                         |
| -------------- | --------- | ----------------------------------- |
| `Condition`    | `Func`    | Function that evaluates a condition |
| `Args`         | `Any*`    | Zero or more additional arguments   |

**Return Value**:

- **Type**: `Object`

---

<a id="AllMatch"></a>

### `AllMatch(Condition: Predicate, Args: Any*) => Boolean`

**Description**:

Returns `true`, if all elements in this map satisfy the given predicate function
`Condition`.

`Condition` is called using key and value as arguments, followed by zero or more
additional arguments `Args*`.

**Example**:

```ahk
KeyNotEquals6(Key, Value) {
    return (Key != 6)
}

Map(1, 2, 3, 4).AllMatch(KeyNotEquals6) ; true
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Condition`    | `Func` | Function that evaluates a condition |
| `Args`         | `Any*` | Zero or more additional arguments   |

**Return Value**:

- **Type**: `Boolean`

---

<a id="NoneMatch"></a>

### `NoneMatch(Condition: Func, Args: Any*) => Boolean`

**Description**:

Returns `true`, if none of the elements in this map satisfy the
given predicate function `Condition`.

`Condition` is called using key and value as first two arguments, followed by
zero or more additional arguments `Args*`.

**Example**:

```ahk
KeyEquals3(Key, Value) {
    return (Key == 3)
}

Map(1, 2, 3, 4).NoneMatch(KeyEquals3) ; false
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Condition`    | `Func` | Function that evaluates a condition |
| `Args`         | `Any*` | Zero or more additional arguments   |

**Return Value**:

- **Type**: `Boolean`

---

## Property Details

<a id="IsEmpty"></a>

### `IsEmpty => Boolean`

**Description**:

Returns `true`, if this map is empty (has no entries).

**Property Type**: `get`

**Example**:

```ahk
Map().IsEmpty     ; true
Map("foo", "bar") ; false
```

**Return Value**:

- **Type**: `Boolean`
