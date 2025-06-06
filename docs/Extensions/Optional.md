# Optional

## Overview

The `Optional` class provides a container object which may or may not
contain a non-null value. It is directly inspired by Java's
`java.util.Optional` type but tailored for AquaHotkey's ecosystem.

Commonly used for safe handling of potentially `unset` values, the
`Optional` class includes operations for mapping, filtering, and
consuming the contained value.

---

## Method Summary

| Method Name                                              | Return Type | Description                                                       |
| -------------------------------------------------------- | ----------- | ----------------------------------------------------------------- |
| [`static Empty()`](#Empty)                               | `Optional`  | Returns an `Optional` with no value                               |
| [`__New(Value?)`](__New)                                 | `Optional`  | Constructs a new `Optional`                                       |
| [`Get()`](#Get)                                          | `Any`       | Returns the contained value, if present                           |
| [`IfPresent(Action, Args*)`](#IfPresent)                 | `this`      | Calls `Action`, if a value is present                             |
| [`IfAbsent(Action, Args*)`](#IfAbsent)                   | `this`      | Calls `Action`, if no value is present                            |
| [`RetainIf(Condition, Args*)`](#RetainIf)                | `Optional`  | Filters the value based on `Condition`                            |
| [`RemoveIf(Condition, Args*)`](#RemoveIf)                | `Optional`  | Filters the value based on `Condition`                            |
| [`Map(Mapper, Args*)`](#Map)                             | `Optional`  | If present, transforms the value by applying `Mapper`             |
| [`OrElse(Default)`](#OrElse)                             | `Any`       | If present, returns the value, otherwise `Default`                |
| [`OrElseGet(Supplier, Args*)`](#OrElseGet)               | `Any`       | If present, returns the value, otherwise the result of `Supplier` |
| [`OrElseThrow(ExceptionSupplier?, Args*)`](#OrElseThrow) | `Any`       | If present, returns the value, otherwise throws an error          |
| [`ToString()`](#ToString)                                | `String`    | Returns a string representation of the `Optional`                 |

---

## Property Summary

| Property Name             | Property Type | Return Type | Description                                         |
| ------------------------- | ------------- | ----------- | --------------------------------------------------- |
| [`IsPresent`](#IsPresent) | `get`         | `Boolean`   | Returns `true`, if the `Optional` contains a value  |
| [`IsAbsent`](#IsAbsent)   | `get`         | `Boolean`   | Returns `true`, if the `Optional` contains no value |

---

## Method Details

<a id="Empty"></a>

### `static Empty() => Optional`

**Description**:

Returns an `Optional` with no value present.

**Example**:

```ahk
Opt := Optional.Empty()
Opt.IsPresent ; false
```

**Return Value**:

- **Type**: `Optional`

---

<a id="__New"></a>

### `__New(Value: Any?) => Optional`

**Description**:

Constructs a new `Optional` that contains the given value, if present.

**Example**:

```ahk
Opt   := Optional("foo")
Empty := Optional()
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Value`        | `Any?` | The value contained in the optional |

**Return Value**:

- **Type**: `Optional`

---

<a id="Get"></a>

### `Get() => Any`

**Description**:

If present, returns the value of the optional, otherwise throws an `UnsetError`.

**Example**:

```ahk
Optional("foo").Get()  ; "foo"
Optional.Empty().Get() ; Error!
```

**Return Value**:

- **Type**: `Any`

---

<a id="IfPresent"></a>

### `IfPresent(Action: Func, Args: Any*) => this`

**Description**:

If present, calls the given function `Action` on the value.

`Action` is called using the value as first argument, followed by zero or more
additional arguments `Args*`.

**Example**:

```ahk
Optional("Hello, world!").IfPresent(MsgBox)
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Action`       | `Func` | The function to call              |
| `Args`         | `Any*` | Zero or more additional arguments |

**Return Value**:

- **Type**: `this`

---

<a id="IfAbsent"></a>

### `IfAbsent(Action: Func, Args: Any*) => this`

**Description**:

If no value is present, calls the given `Action` function.

`Action` is called using zero or more argument `Args*`.

**Example**:

```ahk
Optional.Empty().IfAbsent(() => MsgBox("no value present"))
```

**Parameters**:

| Parameter Name | Type   | Description            |
| -------------- | ------ | ---------------------- |
| `Action`       | `Func` | The function to call   |
| `Args`         | `Any*` | Zero or more arguments |

**Return Value**:

- **Type**: `this`

---

<a id="RetainIf"></a>

### `RetainIf(Condition: Predicate, Args: Any*) => Optional`

**Description**:

If present, filters the value based on the given predicate function `Condition`.
The optional becomes empty, if `Condition` evaluates to `false`.

`Condition` is called using the value as first argument, followed by zero or more
additional arguments `Args*`.

**Example**:

```ahk
Optional().RetainIf(x => (x is Number)) ; Optional(4)
```

**Parameters**:

| Parameter Name | Type        | Description                         |
| -------------- | ----------- | ----------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition |
| `Args`         | `Any*`      | Zero or more additional arguments   |

**Return Value**:

- **Type**: `Optional`

---

<a id="RemoveIf"></a>

### `RemoveIf(Condition: Predicate, Args: Any*) => Optional`

**Description**:

If present, filters the values based on the given predicate function `Condition`.
The optional becomes empty, if `Condition` evaluates to `true`.

`Condition` is called using the value as first argument, followed by zero or more
additional arguments `Args*`.

**Example**:

```ahk
Optional(4).RemoveIf(x => (x is Number)) ; Optional(unset)
```

**Parameters**:

| Parameter Name | Type        | Description                         |
| -------------- | ----------- | ----------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition |
| `Args`         | `Any*`      | Zero or more additional arguments   |

**Return Value**:

- **Type**: `Optional`

---

<a id="Map"></a>

### `Map(Mapper: Func, Args: Any*) => Optional`

**Description**:

If present, applies the given `Mapper` function to the value and returns a new optional
containing its result.

`Mapper` is called using the value as first argument, followed by zero or more additional
arguments `Args*`.

**Example**:

```ahk
Multiply(x, y) {
    return x * y
}
Optional(4).Map(Multiply, 2)      ; Optional(8)
Optional.Empty().Map(Multiply, 2) ; Optional.Empty()
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Mapper`       | `Func` | Function to transform the value   |
| `Args`         | `Any*` | Zero or more additional arguments |

**Return Value**:

- **Type**: `Optional`

---

<a id="OrElse"></a>

### `OrElse(Default: Any) => Any`

**Description**:

If present, returns the value, otherwise returns the given default value.

**Example**:

```ahk
Optional(2).OrElse("")      ; 2
Optional.Empty().OrElse("") ; ""
```

**Parameters**:

| Parameter Name | Type  | Description                                    |
| -------------- | ----- | ---------------------------------------------- |
| `Default`      | `Any` | Default value to return if no value is present |

**Return Value**:

- **Type**: `Any`

---

<a id="OrElseGet"></a>

### `OrElseGet(Supplier: Func, Args: Any*) => Any`

**Description**:

If present, returns the value, otherwise calls the `Supplier` function to obtain
a default value.

**Example**:

```ahk
Optional(4).OrElseGet(() => 0)      ; 4
Optional.Empty().OrElseGet(() => 0) ; ""
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Supplier`     | `Func` | Function to provide a default value |
| `Args`         | `Any*` | Zero or more additional arguments   |

**Return Value**:

- **Type**: `Any`

---

<a id="OrElseThrow"></a>

### `OrElseThrow(ExceptionSupplier: Func?, Args: Any*) => Any`

**Description**:

If present, returns the value, otherwise throws an exception provided by the
`ExceptionSupplier`. If none is specified, this method throws a default `UnsetError`.

**Example**:

```ahk
; `throw ValueError("argument is not a number")`
Optional("foo").RetainIf(IsNumber)
               .OrElseThrow(ValueError, "argument is not a number")
```

**Parameters**:

| Parameter Name      | Type    | Description                      |
| ------------------- | ------- | -------------------------------- |
| `ExceptionSupplier` | `Func?` | Function to provide an exception |
| `Args`              | `Any*`  | Zero or more arguments           |

**Return Value**:

- **Type**: `Any`

---

<a id="ToString"></a>

### `ToString() => String`

**Description**:

Returns a string representation of the optional.

**Example**:

```ahk
Array(1, 2, 3).Optional().ToString() ; "Optional { [1, 2, 3] }"
```

**Return Value**:

- **Type**: `String`

---

## Property Details

<a id="IsPresent"></a>

### `IsPresent => Boolean`

**Description**:

Returns `true`, if the optional contains a value.

**Property Type**: `get`

**Example**:

```ahk
Optional("foo").IsPresent  ; true
Optional.Empty().IsPresent ; false
```

**Return Value**:

- **Type**: `Boolean`

---

<a id="IsAbsent"></a>

### `IsAbsent => Boolean`

**Description**:

Returns `true`, if no value is present in the optional.

**Property Type**: `get`

**Example**:

```ahk
Optional("foo").IsAbsent  ; false
Optional.Empty().IsAbsent ; true
```

**Return Value**:

- **Type**: `Boolean`
