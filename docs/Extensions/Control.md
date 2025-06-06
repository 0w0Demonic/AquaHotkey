# Control

## Overview

The `Control` class provides an object-oriented interface for interacting
with GUI controls in AutoHotkey. It serves as an abstraction over
control-related functions such as `ControlClick`, `ControlGetText`,
`ControlSetText`, and others. This class encapsulates these operations into
a class and focuses on code readability and conciseness.

---

## Method Summary

| Method Name                                                                   | Return Type  | Description                                    |
| ----------------------------------------------------------------------------- | ------------ | ---------------------------------------------- |
| [`__New(Value?, WinTitle?, WinText?, ExcludeTitle?, ExcludeText?)`](#__New)   | `Control`    | Constructs a new `Control`                     |
| [`__Enum(n)`](#__Enum)                                                        | `Enumerator` | Enumerates all control and WinTitle parameters |
| [`AddItem(Str)`](#AddItem)                                                    | `this`       | Adds a new entry `Str` to the control          |
| [`DeleteItem(n)`](#DeleteItem)                                                | `this`       | Deletes an item at index `n` from the control  |
| [`FindItem(Str)`](#FindItem)                                                  | `Integer`    | Returns the index for an entry of name `Str`   |
| [`ChooseIndex(Value)`](#ChooseIndex)                                          | `this`       | Sets the index of the entry of the control     |
| [`ChooseString(Str)`](#ChooseString)                                          | `this`       | Chooses the first entry which matches `Str`    |
| [`Click(Button?, n?, Options?)`](#Click)                                      | `this`       | Sends a mouse event to the control             |
| [`Focus()`](#Focus)                                                           | `this`       | Sets input focus to the control                |
| [`Enable(Value)`](#Enable)                                                    | `this`       | Enables or disables the control                |
| [`static Focus(WinTitle?, WinText?, ExcludeTitle?, ExcludeText?)`](#GetFocus) | `Control`    | Retrieves the currently focused control        |
| [`SetStyle(Value)`](#SetStyle)                                                | `this`       | Changes the style of the control               |
| [`SetExStyle(Value)`](SetExStyle)                                             | `this`       | Changes the extended style of the control      |
| [`SetText(Value)`](#SetText)                                                  | `this`       | Changes the text of the control                |
| [`SetVisible(Value)`](#SetVisible)                                            | `this`       | Shows or hides the control                     |
| [`Check(Value)`](#Check)                                                      | `this`       | Checks or unchecks the control                 |
| [`HideDropDown()`](#HideDropDown)                                             | `this`       | Hides the drop-down list of the control        |
| [`Move(x?, y?, Width?, Height?)`](#Move)                                      | `this`       | Moves the control to the specified position    |
| [`Send(Keys)`](#Send)                                                         | `this`       | Sends simulated keystrokes to the control      |
| [`SendText(Keys)`](#SendText)                                                 | `this`       | Sends raw text to the window                   |
| [`Paste(Str)`](#Paste)                                                        | `this`       | Pastes the given string in the edit control    |
| [`SendMessage(MsgNumber, wParam?, lParam?, Timeout?)`](#SendMessage)          | `Integer`    | Sends a message to the control                 |
| [`PostMessage(MsgNumber, wParam?, lParam?)`](#PostMessage)                    | `this`       | Posts a message to the control                 |

---

## Property Summary

| Property Name                   | Property Type | Return Type | Description                                   |
| ------------------------------- | ------------- | ----------- | --------------------------------------------- |
| [`Index`](#Index)               | `get/set`     | `Integer`   | The index of an entry                         |
| [`Choice`](#Choice)             | `get/set`     | `String`    | The name of the entry chosen                  |
| [`ClassNN`](#ClassNN)           | `get`         | `String`    | The ClassNN of the control                    |
| [`Enabled`](#Enabled)           | `get/set`     | `Boolean`   | Enabled status of the control                 |
| [`Hwnd`](#Hwnd)                 | `get`         | `Integer`   | Handle of the control                         |
| [`Items`](#Items)               | `get`         | `Array`     | All items of the control                      |
| [`Pos`](#Pos)                   | `get`         | `Object`    | Position of the control                       |
| [`Style`](#Style)               | `get/set`     | `Integer`   | Style of the control                          |
| [`ExStyle`](#ExStyle)           | `get/set`     | `Integer`   | Extended style of the control                 |
| [`Text`](#Text)                 | `get/set`     | `String`    | Text of the control                           |
| [`Visible`](#Visible)           | `get/set`     | `Boolean`   | Visibility of the control                     |
| [`Checked`](#Checked)           | `get/set`     | `Boolean`   | Whether the control is checked/unchecked      |
| [`CurrentCol`](#CurrentCol)     | `get`         | `Integer`   | Current column of the edit control            |
| [`CurrentLine`](#CurrentLine)   | `get`         | `Integer`   | Current line of the edit control              |
| [`Line[n]`](#Line)              | `get`         | `String`    | Line content of the edit control              |
| [`LineCount`](#Line)            | `get`         | `Integer`   | Amount of lines contained in the edit control |
| [`SelectedText`](#SelectedText) | `get`         | `String`    | Selected text in the edit control             |

---

## Method Details

<a id="__New"></a>

### `__New(Value: Any, WinTitle: Any?, WinText: String?, ExcludeTitle: Any?, ExcludeText: String) => Control`

**Description**:

Creates a new `Control` object from the given control parameter, followed by WinTitle parameters.

**Parameters**:

| Parameter Name | Type      | Description           |
| -------------- | --------- | --------------------- |
| `Value`        | `Any`     | GUI control parameter |
| `WinTitle`     | `Any?`    | window title          |
| `WinText`      | `String?` | window text           |
| `ExcludeTitle` | `Any?`    | excluded window title |
| `ExcludeText`  | `String?` | excluded window text  |

**Return Value**:

- **Type**: `Control`

---

<a id="__Enum"></a>

### `__Enum(n: Integer) => Enumerator`

**Description**:

Enumerates the control and WinTitle parameters of this `Control` object in a for-loop.

**Parameters**:

| Parameter Name | Type      | Description                      |
| -------------- | --------- | -------------------------------- |
| `n`            | `Integer` | Parameter length of the for-loop |

**Return Value**:

- **Type**: `Enumerator`

---

<a id="AddItem"></a>

### `AddItem(Str: String) => this`

**Description**:

Adds the specified string as new entry at the bottom of a ListBox or ComboBox.

**Parameters**:

| Parameter Name | Type     | Description       |
| -------------- | -------- | ----------------- |
| `Str`          | `String` | The string to add |

**Return Value**:

- **Type**: `this`

---

<a id="DeleteItem"></a>

### `DeleteItem(n: Integer) => this`

**Description**:

Deletes the specified entry number from a ListBox or ComboBox.

**Parameters**:

| Parameter Name | Type      | Description                 |
| -------------- | --------- | --------------------------- |
| `n`            | `Integer` | Index of the item to delete |

**Return Value**:

- **Type**: `this`

---

<a id="FindItem"></a>

### `FindItem(Str) => this`

**Description**:

Returns the entry number of a ListBox or ComboBox that is a complete match
for the specified string `Str`.

**Parameters**:

| Parameter Name | Type     | Description        |
| -------------- | -------- | ------------------ |
| `Str`          | `String` | The string to find |

**Return Value**:

- **Type**: `this`

---

<a id="ChooseIndex"></a>

### `ChooseIndex(n: Integer) => this`

**Description**:

Sets the index of the currently selected entry or tab in a ListBox, ComboBox or Tab control.

**Parameters**:

| Parameter Name | Type      | Description         |
| -------------- | --------- | ------------------- |
| `n`            | `Integer` | The index to choose |

**Return Value**:

- **Type**: `this`

---

<a id="ChooseString"></a>

### `ChooseString(Str: String) => this`

**Description**:

Chooses the first entry which matches the given string `Str`.

**Parameters**:

| Parameter Name | Type     | Description          |
| -------------- | -------- | -------------------- |
| `Str`          | `String` | The string to choose |

**Return Value**:

- **Type**: `this`

---

<a id="Click"></a>

### `Click(Button: String?, n: Integer?, Options: String?) => this`

**Description**:

Sends a mouse event to the specified control.

**Parameters**:

| Parameter Name | Type       | Description                                  |
| -------------- | ---------- | -------------------------------------------- |
| `Button`       | `String?`  | Name of the button to press                  |
| `n`            | `Integer?` | Number of times to click or turn mouse wheel |
| `Options`      | `String?`  | Additional options (see AHK docs)            |

**Return Value**:

- **Type**: `this`

---

<a id="Focus"></a>

### `Focus() => this`

**Description**:

Sets input focus to the control.

**Return Type**:

- **Type**: `this`

---

<a id="Enable"></a>

### `Enable(Value: Integer) => this`

Enables or disables the control.

**Parameters**:

| Parameter Name | Type      | Description     |
| -------------- | --------- | --------------- |
| `Value`        | `Integer` | The new setting |

**Return Value**:

- **Type**: `this`

---

<a id="GetFocus"></a>

### `static Focus(WinTitle: Any?, WinText: String?, ExcludeTitle: Any?, ExcludeText: String?) => Control`

**Description**:

Retrieves the control of the target window that has keyboard focus. If none,
this method returns `false`.

**Parameters**:

| Parameter Name | Type      | Description           |
| -------------- | --------- | --------------------- |
| `WinTitle`     | `Any?`    | window title          |
| `WinText`      | `String?` | window text           |
| `ExcludeTitle` | `Any?`    | excluded window title |
| `ExcludeText`  | `String?` | excluded window text  |

**Return Value**:

- **Type**: `Control`

---

<a id="SetStyle"></a>

### `SetStyle(Value: Integer/String) => this`

**Description**:

Changes the style of the control.

**Parameters**:

| Parameter Name | Type             | Description  |
| -------------- | ---------------- | ------------ |
| `Value`        | `Integer/String` | New settings |

**Return Value**:

- **Type**: `this`

---

<a id="SetExStyle"></a>

### `SetExStyle(Value: Integer/String) => this`

**Description**:

Changes the extended style of the control.

**Parameters**:

| Parameter Name | Type             | Description  |
| -------------- | ---------------- | ------------ |
| `Value`        | `Integer/String` | New settings |

**Return Value**:

- **Type**: `this`

---

<a id="SetText"></a>

### `SetText(Value: String) => this`

**Description**:

Changes the text of the control.

**Parameters**:

| Parameter Name | Type     | Description                 |
| -------------- | -------- | --------------------------- |
| `Value`        | `String` | The new text of the control |

**Return Value**:

- **Type**: `this`

---

<a id="SetVisible"></a>

### `SetVisible(Value: Integer) => this`

**Description**:

Shows or hides the control.

**Parameters**:

| Parameter Name | Type      | Description               |
| -------------- | --------- | ------------------------- |
| `Value`        | `Integer` | Visibility of the control |

**Return Value**:

- **Type**: `this`

---

<a id="Check"></a>

### `Check(Value: Integer) => this`

**Description**:

Checks or unchecks the checkbox or radio button.

**Parameters**:

| Parameter Name | Type      | Description               |
| -------------- | --------- | ------------------------- |
| `Value`        | `Integer` | Visibility of the control |

**Return Value**:

- **Type**: `this`

---

<a id="ShowDropDown"></a>

### `ShowDropDown() => this`

**Description**:

Shows the drop-down list of the ComboBox control.

**Return Value**:

- **Type**: `this`

---

<a id="HideDropDown"></a>

### `HideDropDown() => this`

**Description**:

Hides the drop-down list of the ComboBox control.

**Return Value**:

- **Type**: `this`

---

<a id="Move"></a>

### `Move(x: Integer?, y: Integer?, Width: Integer?, Height: Integer?) => this`

**Description**:

Moves the control to the specified position.

**Parameters**:

| Parameter Name | Type      | Description                       |
| -------------- | --------- | --------------------------------- |
| `x`            | `Integer` | x-coordinate of upper left corner |
| `y`            | `Integer` | y-coordinate of upper left corner |
| `Width`        | `Integer` | Width of the control              |
| `Height`       | `Integer` | Height of the control             |

**Return Value**:

- **Type**: `this`

---

<a id="Send"></a>

### `Send(Keys: String) => this`

**Description**:

Sends simulated keystrokes or text to the control.

**Parameters**:

| Parameter Name | Type     | Description      |
| -------------- | -------- | ---------------- |
| `Keys`         | `String` | The keys to send |

**Return Value**:

- **Type**: `this`

---

<a id="SendText"></a>

### `SendText(Keys: String) => this`

**Description**:

Sends text to the control without translating special keys.

**Parameters**:

| Parameter Name | Type     | Description      |
| -------------- | -------- | ---------------- |
| `Keys`         | `String` | The text to send |

**Return Value**:

- **Type**: `this`

---

<a id="Paste"></a>

### `Paste(Str: String) => this`

**Description**:

Pastes the given string `Str` at the caret of the edit control.

**Parameters**:

| Parameter Name | Type     | Description         |
| -------------- | -------- | ------------------- |
| `Str`          | `String` | The string to paste |

**Return Value**:

- **Type**: `this`

---

<a id="SendMessage"></a>

### `SendMessage(MsgNumber: Integer, wParam: Integer?/Buffer?, lParam: Integer?/Buffer?, Timeout: Integer?) => Integer`

**Description**:

Sends a message to the control and waits for acknowledgement.

**Parameters**:

| Parameter Name | Type               | Description                     |
| -------------- | ------------------ | ------------------------------- |
| `MsgNumber`    | `Integer`          | The message number to send      |
| `wParam`       | `Integer?/Buffer?` | First component of the message  |
| `lParam`       | `Integer?/Buffer?` | Second component of the message |
| `Timeout`      | `Integer`          | Timeout in milliseconds         |

**Return Value**:

- **Type**: `this`

---

<a id="PostMessage"></a>

### `PostMessage(MsgNumber: Integer, wParam: Integer?/Buffer?, lParam: Integer?/Buffer?) => this`

**Description**:

Places a message in the message queue of the control.

**Parameters**:

| Parameter Name | Type               | Description                     |
| -------------- | ------------------ | ------------------------------- |
| `MsgNumber`    | `Integer`          | The message number to send      |
| `wParam`       | `Integer?/Buffer?` | First component of the message  |
| `lParam`       | `Integer?/Buffer?` | Second component of the message |

**Return Value**:

- **Type**: `this`

---

## Property Details

<a id="Index"></a>

### `Index => Integer`

**Description**:

Gets and sets the index of the currently selected entry or tab in a ListBox,
ComboBox or Tab control.

**Property Type**: `get/set`

**Parameters**:

| Parameter Name | Type      | Description           |
| -------------- | --------- | --------------------- |
| `Value`        | `Integer` | `The index to choose` |

**Return Value**:

- **Type**: `Integer`

---

<a id="Choice"></a>

### `Choice => String`

**Description**:

Returns the name of the currently selected entry in the ListBox or ComboBox.
Chooses the first entry in the ListBox or ComboBox which matches the given
string `Value`.

**Property Type**: `get/set`

**Parameters**:

| Parameter Name | Type     | Description          |
| -------------- | -------- | -------------------- |
| `Value`        | `String` | The string to choose |

**Return Value**:

- **Type**: `String`

---

<a id="ClassNN"></a>

### `ClassNN => String`

**Description**:

Returns the ClassNN (class name and sequence number) of the control.

**Property Type**: `get`

**Return Value**:

- **Type**: `String`

---

<a id="Enabled"></a>

### `Enabled => Boolean`

**Description**:

Returns whether the control is current enabled and enables/disables the control.

**Property Type**: `get/set`

**Return Value**:

- **Type**: `Boolean`

---

<a id="Hwnd"></a>

### `Hwnd => Integer`

**Description**:

Returns the HWND of the control.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="Items"></a>

### `Items => Array`

**Description**:

Returns an array of all items from a ListBox, ComboBox or DropDownList.

**Property Type**: `get`

**Return Value**:

- **Type**: `Array`

---

<a id="Pos"></a>

### `Pos => Object`

**Description**:

Returns positional information of the control in the form of an object with
properties `x`, `y`, `Width` and `Height`.

**Property Type**: `get`

**Return Value**:

- **Type**: `Object`

---

<a id="Style"></a>

### `Style => Integer`

**Description**:

Gets and sets the style of the control.

**Property Type**: `get/set`

**Parameters**:

| Parameter Name | Type             | Description  |
| -------------- | ---------------- | ------------ |
| `Value`        | `Integer/String` | New settings |

**Return Value**:

- **Type**: `Integer`

---

<a id="ExStyle"></a>

### `ExStyle => Integer`

**Description**:

Gets and sets the extended style of the control.

**Property Type**: `get/set`

**Parameters**:

| Parameter Name | Type             | Description  |
| -------------- | ---------------- | ------------ |
| `Value`        | `Integer/String` | New settings |

**Return Value**:

- **Type**: `Integer`

---

<a id="Text"></a>

### `Text => String`

**Description**:

Retrieves and changes the text of the control.

**Property Type**: `get/set`

**Parameters**:

| Parameter Name | Type     | Description                 |
| -------------- | -------- | --------------------------- |
| `Value`        | `String` | The new text of the control |

**Return Value**:

- **Type**: `String`

---

<a id="Visible"></a>

### `Visible => Boolean`

**Description**:

Shows or hides the control.

**Property Type**: `get/set`

**Parameters**:

| Parameter Name | Type      | Description               |
| -------------- | --------- | ------------------------- |
| `Value`        | `Integer` | Visibility of the control |

**Return Value**:

- **Type**: `Boolean`

---

<a id="Checked"></a>

### `Checked => Boolean`

**Description**:

Returns and changes whether the checkbox or radio button is checked.

**Property Type**: `get/set`

**Parameters**:

| Parameter Name | Type      | Description |
| -------------- | --------- | ----------- |
| `Value`        | `Integer` | New setting |

**Return Value**:

- **Type**: `Boolean`

---

<a id="CurrentCol"></a>

### `CurrentCol => Integer`

**Description**:

Returns the current column number of the caret in the edit control.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="CurrentLine"></a>

### `CurrentLine => Integer`

**Description**:

Returns the current line number of the caret in the edit control.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="Line"></a>

### `Line[n: Integer] => String`

**Description**:

Returns the contents of the specified line in the edit control.

**Property Type**: `get`

**Parameters**:

| Parameter Name | Type      | Description             |
| -------------- | --------- | ----------------------- |
| `n`            | `Integer` | Line number to retrieve |

**Return Value**:

- **Type**: `String`

---

<a id="LineCount"></a>

### `LineCount => Integer`

**Description**:

Returns the number of lines present in the edit control.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="SelectedText"></a>

### `SelectedText => String`

**Description**:

Returns the currently selected text in the edit control.

**Property Type**: `get`

**Return Value**:

- **Type**: `String`
