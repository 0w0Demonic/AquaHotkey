
# Primitive

## Method Summary

| Method Name                                                                                                        | Return Type | Description                                                   |
| ------------------------------------------------------------------------------------------------------------------ | ----------- | ------------------------------------------------------------- |
| [`MsgBox(Title?, Options?)`](#MsgBox)                                                                              | `this`      | Outputs this variable as text in a message box                |
| [`ToolTip(x?, y?, WhichToolTip?)`](#ToolTip)                                                                       | `this`      | Outputs this variable on a tooltip control                    |
| [`Send()`](#Send)<br>[`SendText()`](#SendText)<br>[`SendPlay()`](#SendPlay)<br>[`SendEvent()`](#SendEvent)         | `this`      | Outputs this variable using one of the `Send()` functions     |
| [`ToNumber()`](#ToNumber)<br>[`ToInteger()`](#ToInteger)<br>[`ToFloat()`](#ToFloat)<br>[`ToString()`](#ToString)   | `Primitive` | Converts this variable into the specified type                |
| [`ToClipboard()`](#ToClipboard)                                                                                    | `this`      | Puts this variable into the system clipboard                  |
| [`FormatTo(Pattern, Args*)`](#FormatTo)                                                                            | `String`    | Formats this variable into the given format pattern `Pattern` |

---

<a id="MsgBox"></a>

### `MsgBox(Title: String?, Options: Primitive?) => this`

**Description**:

Outputs this variable as text in a message box.

**Example**:

```ahk
"Hello, world!".MsgBox("AquaHotkey", MsgBox.Icon.Info)
```

**Parameters**:

| Parameter Name | Type         | Description                 |
| -------------- | ------------ | --------------------------- |
| `Title`        | `String?`    | Message box title           |
| `Options`      | `Primitive?` | Additional `MsgBox` options |

**Return Value**:

- **Type**: `this`

---

<a id="ToolTip"></a>

### `ToolTip(x: Integer?, y: Integer?, WhichToolTip: Integer?) => this`

**Description**:

Outputs this variable on a tooltip control.

**Example**:

```ahk
"Hello, world!".ToolTip(50, 50, 1)
```

**Parameters**:

| Parameter Name | Type      | Description                 |
| -------------- | --------- | --------------------------- |
| `x`            | `Integer` | x-coordinate of the tooltip |
| `y`            | `Integer` | y-coordinate of the tooltip |
| `WhichToolTip` | `Integer` | Which tooltip to operate on |

**Return Value**:

- **Type**: `this`

---

<a id="Send"></a>

### `Send() => this`

<a id="SendText"></a>

### `SendText() => this`

<a id="SendPlay"></a>

### `SendPlay() => this`

<a id="SendEvent"></a>

### `SendEvent() => this`

**Description**:

Outputs this variable using one of the `Send()` functions.

**Example**:

```ahk
"Four score and seven years ago".Send()
```

**Return Value**:

- **Type**: `this`

---

<a id="ToNumber"></a>

### `ToInteger() => Integer`

<a id="ToInteger"></a>

### `ToFloat() => Float`

<a id="ToFloat"></a>

### `ToNumber() => Number`

<a id="ToString"></a>

### `ToString() => String`

**Description**:

Converts this variable into the specified type.

**Example**:

```ahk
"9.123".ToNumber() ; 9.123
(81).ToString()    ; "81"
```

**Return Value**:

- **Type**: `Primitive`

---

<a id="ToClipboard"></a>

### `ToClipboard() => this`

**Description**:

Puts this variable into the system clipboard.

**Example**:

```ahk
"This is the new clipboard content".ToClipboard()
```

**Return Value**:

- **Type**: `this`

---

<a id="FormatTo"></a>

### `FormatTo(Pattern: String, Args: Any*) => String`

**Description**:

Formats this variable into the given format pattern `Pattern`, followed by zero or more additional arguments `Args*`.

Objects are converted using their `ToString()` method.

**Example**:

```ahk
"world".FormatTo("{2}, {1}!", "Hello") ; "Hello, world!"
```

**Parameters**:

| Parameter Name | Type     | Description                       |
| -------------- | -------- | --------------------------------- |
| `Pattern`      | `String` | The format pattern to use         |
| `Args`         | `Any*`   | Zero or more additional arguments |

**Return Value**:

- **Type**: `String`

---
