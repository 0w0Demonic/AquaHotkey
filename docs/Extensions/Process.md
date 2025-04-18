# Process

## Method Summary

| Method Name                           | Return Type | Description                               |
| ------------------------------------- | ----------- | ----------------------------------------- |
| [`__New(Value)`](#__New)              | `Process`   | Constructs a new `Process`                |
| [`static List()`](#List)              | `Array`     | Returns a list of all processes           |
| [`Close()`](#Close)                   | `Integer`   | Closes the first matching process         |
| [`CloseAll()`](#CloseAll)             | `Array`     | Closes all matching processes             |
| [`SetPriority(Value)`](#SetPriority)  | `String`    | Changes the priority level of the process |
| [`Wait(Timeout?)`](#Wait)             | `Process`   | Waits for the process to exist            |
| [`WaitClose(Timeout?)`](#WaitClose)   | `Integer`   | Waits for the process to close            |

---

## Property Summary

| Property Name           |  Property Type | Return Type | Description                                |
| ----------------------- | ------------- | ----------- | ------------------------------------------ |
| [`static Self`](#Self)  | `get`         | `Process`   | Returns this script as process             |
| [`Priority`](#Priority) | `set`         | `String`    | Changes the priority of the process        |
| [`Exists`](#Exists)     | `get`         | `Boolean`   | Returns the the PID, if the process exists |
| [`Name`](#Name)         | `get`         | `String`    | Returns the name of the process            |
| [`Parent`](#Parent)     | `get`         | `Process`   | Returns the parent of the process          |
| [`Path`](#Path)         | `get`         | `String`    | Returns the path of the process            |

---

<a id="__New"></a>

### `__New(Value: Integer/String) => Process`

**Description**:

Returns a new `Process` from the given process ID or process name.

**Parameters**:

| Parameter Name | Type             | Description                |
| -------------- | ---------------- | -------------------------- |
| `Value`        | `Integer/String` | Process ID or process name |

**Return Value**:

- **Type**: `Process`

---

<a id="List"></a>

### `static List() => Array`

**Description**:

Returns a list of all processes.

**Return Value**:

- **Type**: `Array`

---

<a id="Close"></a>

### `Close() => Integer`

**Description**:

Closes the first matching process.

**Return Value**:

- **Type**: `Integer`

---

<a id="CloseAll"></a>

### `CloseAll() => Array`

**Description**:

Closes all matching processes.

**Return Value**:

- **Type**: `Array`

---

<a id="SetPriority"></a>

### `SetPriority(Value) => Integer`

**Description**:

Changes the priority level of the process.

**Parameters**:

| Parameter Name | Type     | Description                |
| -------------- | -------- | -------------------------- |
| `Value`        | `String` | New process priority level |

**Return Value**:

- **Type**: `Integer`

---

<a id="Wait"></a>

### `Wait(Timeout: Number?) => Process`

**Description**:

Waits the the process to exist, with a given timeout in seconds.

**Parameters**:

| Parameter Name | Type      | Description     |
| -------------- | --------- | --------------- |
| `Timeout`      | `Number?` | Seconds to wait |

**Return Value**:

- **Type**: `Process`

---

<a id="WaitClose"></a>

### `WaitClose(Timeout: Number?) => Integer`

**Description**:

Waits for the process to close, with a given timeout in seconds.

**Parameters**:

| Parameter Name | Type      | Description     |
| -------------- | --------- | --------------- |
| `Timeout`      | `Number?` | Seconds to wait |

**Return Value**:

- **Type**: ``

---

## Property Details

<a id="Self"></a>

### `static Self => Process`

**Description**:

Returns this script as `Process`.

**Property Type**: `get`

**Return Value**:

- **Type**: `Process`

---

<a id="Priority"></a>

### `Priority => String`

**Description**:

Changes the priority level of the process.

**Parameter Type**: `set`

**Return Value**:

- **Type**: `String`

---

<a id="Exist"></a>

### `Exists => Integer`

**Description**:

Returns the PID, if the process exists.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="Name"></a>

### `Name => String`

**Description**:

Returns the name of the process.

**Parameter Type**: `get`

**Return Value**:

- **Type**: `String`

---

<a id="Parent"></a>

### `Parent => Process`

**Description**:

Returns the parent of the process.

**Parameter Type**: `get`

**Return Value**:

- **Type**: `Process`

---

<a id="Path"></a>

### `Path => String`

**Description**:

Returns the path of the process.

**Parameter Type**: `get`

**Return Value**:

- **Type**: `String`
