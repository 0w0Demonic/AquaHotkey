# Window

## Overview

The `Window` class wraps around the built-in window function and minimizes
boilerplate code by summary WinTitle parameter into an object with various
methods and properties.

**Example Usage**:

```ahk
cmd := Window.Run("cmd.exe").WaitActive().Maximize()
```

---

## Method Summary

| Method Name                                                              | Return Type  | Description                                                       |
| ------------------------------------------------------------------------ | ------------ | ----------------------------------------------------------------- |
| [`__New(WinTitle?, WinText?, ExcludeTitle?, ExcludeText?)`](#__New)      | `Window`     | Constructs a new `Window` from WinTitle parameters                |
| [`static Run(Target, WorkingDir?, Options?)`](#Run)                      | `Window`     | Constructs a new `Window` by executing a program                  |
| [`__Enum(n)`](#__Enum)                                                   | `Enumerator` | Enumerates the WinTitle parameters of the window in a for-loop    |
| [`Activate()`](#Activate)                                                | `this`       | Activates the top matching window                                 |
| [`ActivateBottom()`](#ActivateBottom)                                    | `this`       | Activates the bottom matching window                              |
| [`Close(SecondsToWait?)`](#Close)                                        | `this`       | Closes the first matching window                                  |
| [`SetStyle(Value)`](#SetStyle)                                           | `this`       | Sets the style of the window                                      |
| [`SetExStyle(Value)`](#SetExStyle)                                       | `this`       | Sets the extended style of the window                             |
| [`SetTitle(Value)`](#SetTitle)                                           | `this`       | Sets the title of the window                                      |
| [`SetTransColor(Value)`](#SetTransColor)                                 | `this`       | Sets the transparent color of the window                          |
| [`SetTransparent(Value)`](#SetTransparent)                               | `this`       | Sets the transparency of the window                               |
| [`Hide()`](#Hide)                                                        | `this`       | Hides the window                                                  |
| [`Show()`](#Show)                                                        | `this`       | Shows the window                                                  |
| [`Kill(Timeout?)`](#Kill)                                                | `this`       | Forces the window to close                                        |
| [`Maximize()`](#Maximize)                                                | `this`       | Maximizes the window                                              |
| [`Minimize()`](#Minimize)                                                | `this`       | Minimizes the window                                              |
| [`Move(x?, y?, Width?, Height?)`](#Move)                                 | `this`       | Moves and resizes the window                                      |
| [`MoveBottom()`](#MoveBottom)                                            | `this`       | Moves the window to the bottom of the stack                       |
| [`MoveTop()`](#MoveTop)                                                  | `this`       | Moves the window to the top of the stack                          |
| [`Redraw()`](#Redraw)                                                    | `this`       | Redraw the window                                                 |
| [`Restore()`](#Restore)                                                  | `this`       | Restores the window                                               |
| [`SetAlwaysOnTop(Value)`](#SetAlwaysOnTop)                               | `this`       | Makes the window stay on top of all other windows                 |
| [`SetEnabled(Value)`](#SetEnabled)                                       | `this`       | Enables and disables the window                                   |
| [`Wait(Timeout?)`](#Wait)                                                | `Window`     | Waits until the window exists                                     |
| [`WaitActive(Timeout?)`](#WaitActive)                                    | `Window`     | Waits until the window is active                                  |
| [`WaitNotActive(Timeout?)`](#WaitNotActive)                              | `Window`     | Waits until the window is not active                              |
| [`WaitClose(Timeout?)`](#WaitClose)                                      | `Window`     | Waits until the window closes                                     |
| [`StatusBarWait(BarText?, Timeout?, Index?, Interval?)`](#StatusBarWait) | `Boolean`    | Waits until the window's status bar contains the specified string |

---

## Property Summary

| Property Name                             | Property Type | Return Type | Description                                                    |
| ----------------------------------------- | ------------- | ----------- | -------------------------------------------------------------- |
| [`Active`](#Active)                       | `get`         | `Integer`   | Returns the HWND if the window is currently active             |
| [`Exists`](#Exists)                       | `get`         | `Integer`   | Returns the HWND if the window exists                          |
| [`ClassName`](#ClassName)                 | `get`         | `String`    | Returns the class name of the window                           |
| [`ClientPos`](#ClientPos)                 | `get`         | `Object`    | Returns the client position as an object                       |
| [`Controls`](#Controls)                   | `get`         | `Array`     | Returns an array of names for all controls                     |
| [`ControlsHwnd`](#ControlsHwnd)           | `get`         | `Array`     | Returns an array of HWND for all controls                      |
| [`Control[Ctl]`](#Control)                | `get`         | `Control`   | Returns a `Control` by name or HWND                            |
| [`Count`](#Count)                         | `get`         | `Integer`   | Returns the number of windows matching the WinTitle parameters |
| [`ID`](#ID)                               | `get`         | `Integer`   | Returns the HWND                                               |
| [`Hwnd`](#Hwnd)                           | `get`         | `Integer`   | Returns the HWND                                               |
| [`IDLast`](#IDLast)                       | `get`         | `Integer`   | Returns the HWND of the last matching window                   |
| [`Minimized`](#Minimized)                 | `get`         | `Boolean`   | Returns `true` if the window is minimized                      |
| [`Maximized`](#Maximized)                 | `get`         | `Boolean`   | Returns `true` if the window is maximized                      |
| [`PID`](#PID)                             | `get`         | `Integer`   | Returns the process ID                                         |
| [`Pos`](#Pos)                             | `get`         | `Object`    | Returns the position                                           |
| [`ProcessName`](#ProcessName)             | `get`         | `String`    | Returns the process name                                       |
| [`ProcessPath`](#ProcessPath)             | `get`         | `String`    | Returns the process path                                       |
| [`Style`](#Style)                         | `get/set`     | `Integer`   | Retrieves and changes the style                                |
| [`ExStyle`](#ExStyle)                     | `get/set`     | `Integer`   | Retrieves and changes the extended style                       |
| [`Text`](#Text)                           | `get`         | `String`    | Returns the window text                                        |
| [`Title`](#Title)                         | `get/set`     | `String`    | Retrieves and changes the window title                         |
| [`TransColor`](#TransColor)               | `get/set`     | `String`    | Retrieves and changes the transparent color                    |
| [`Transparent`](#Transparent)             | `get/set`     | `Integer`   | Returns and changes the transparency setting                   |
| [`AlwaysOnTop`](#AlwaysOnTop)             | `set`         | `Integer`   | Makes the window stay on top of all other windows              |
| [`Enabled`](#Enabled)                     | `get/set`     | `Integer`   | Enables and disables the window                                |
| [`Region`](#Region)                       | `set`         | `String`    | Sets the window to be the specified shape                      |
| [`StatusBarText[Index?]`](#StatusBarText) | `get`         | `String`    | Retrieves the text from a standard status bar control          |

---

<a id="__New"></a>

### `__New(WinTitle: Any?, WinText: String?, ExcludeTitle: Any?, ExcludeText: String?) => Window`

**Description**:

Creates a new `Window` from the given WinTitle parameters.

**Parameters**:

| Parameter Name | Type      | Description           |
| -------------- | --------- | --------------------- |
| `WinTitle`     | `Any?`    | Window title          |
| `WinText`      | `String?` | Window text           |
| `ExcludeTitle` | `Any?`    | Excluded window title |
| `ExcludeText`  | `String?` | Excluded window text  |

**Return Value**:

- **Type**: `Window`

---

<a id="Run"></a>

### `static Run(Target: String, WorkingDir: String?, Options: String?) => Window`

**Description**:

Constructs a new `Window` by running an external program `Target`.

**Parameters**:

| Parameter Name | Type      | Description               |
| -------------- | --------- | ------------------------- |
| `Target`       | `String`  | The program to execute    |
| `WorkingDir`   | `String?` | Initial working directory |
| `Options`      | `String?` | Additional options        |

**Return Value**:

- **Type**: `Window`

---

<a id="__Enum"></a>

### `__Enum(n: Integer) => Enumerator`

**Description**:

Enumerates the WinTitle parameters of the window in a for-loop.

**Parameters**:

| Parameter Name | Type      | Description                      |
| -------------- | --------- | -------------------------------- |
| `n`            | `Integer` | Parameter length of the for-loop |

**Return Value**:

- **Type**: `Enumerator`

---

<a id="Activate"></a>

### `Activate() => this`

**Description**:

Activates the top matching window.

**Return Value**:

- **Type**: `this`

---

<a id="ActivateBottom"></a>

### `ActivateBottom() => this`

**Description**:

Activates the bottom matching window.

**Return Value**:

- **Type**: `this`

---

<a id="Close"></a>

### `Close(SecondsToWait: Number?) => this`

**Description**:

Closes the first matching window with the given number of seconds to wait.

**Parameters**:

| Parameter Name  | Type      | Description               |
| --------------- | --------- | ------------------------- |
| `SecondsToWait` | `Number?` | Number of seconds to wait |

**Return Value**:

- **Type**: `this`

---

<a id="SetStyle"></a>

### `SetStyle(Value: Integer/String) => this`

**Description**:

Changes the style of the window.

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

Changes the extended style of the window.

**Parameters**:

| Parameter Name | Type             | Description  |
| -------------- | ---------------- | ------------ |
| `Value`        | `Integer/String` | New settings |

**Return Value**:

- **Type**: `this`

---

<a id="SetTitle"></a>

### `SetTitle(Value: String) => this`

**Description**:

Changes the title of the window.

**Parameters**:

| Parameter Name | Type     | Description      |
| -------------- | -------- | ---------------- |
| `Value`        | `String` | New window title |

**Return Value**:

- **Type**: `this`

---

<a id="SetTransColor"></a>

### `SetTransColor(Value: String) => this`

**Description**:

Makes all pixels of the chosen color in the window invisible.

**Parameters**:

| Parameter Name | Type     | Description                                    |
| -------------- | -------- | ---------------------------------------------- |
| `Value`        | `String` | Color name or RGB value, optional transparency |

**Return Value**:

- **Type**: `this`

---

<a id="SetTransparent"></a>

### `SetTransparent(Value: Integer/String) => this`

**Description**:

Makes the window semi-transparent.

**Parameters**:

| Parameter Name | Type             | Description              |
| -------------- | ---------------- | ------------------------ |
| `Value`        | `Integer/String` | New transparency setting |

**Return Value**:

- **Type**: `this`

---

<a id="Hide"></a>

### `Hide() => this`

**Description**:

Hides the window.

**Return Value**:

- **Type**: `this`

---

<a id="Show"></a>

### `Show() => this`

**Description**:

Shows the window.

**Return Value**:

- **Type**: `this`

---

<a id="Kill"></a>

### `Kill(Timeout: Number?) => this`

**Description**:

Forces the window to close with the given max number of seconds to wait.

**Parameters**:

| Parameter Name | Type      | Description                   |
| -------------- | --------- | ----------------------------- |
| `Timeout`      | `Number?` | Max number of seconds to wait |

**Return Value**:

- **Type**: `this`

---

<a id="Maximize"></a>

### `Maximize() => this`

**Description**:

Maximizes the window.

**Return Value**:

- **Type**: `this`

---

<a id="Minimize"></a>

### `Minimize() => this`

**Description**:

Minimizes the window.

**Return Value**:

- **Type**: `this`

---

<a id="Move"></a>

### `Move(x: Integer?, y: Integer?, Width: Integer?, Height: Integer?) => this`

**Description**:

Moves the window to the specified position or size.

**Parameters**:

| Parameter Name | Type       | Description                           |
| -------------- | ---------- | ------------------------------------- |
| `x`            | `Integer?` | x-coordinate of the upper left corner |
| `y`            | `Integer?` | y-coordinate of the upper left corner |
| `Width`        | `Integer?` | Width in pixels                       |
| `Height`       | `Integer?` | Height in pixels                      |

**Return Value**:

- **Type**: `this`

---

<a id="MoveBottom"></a>

### `MoveBottom() => this`

**Description**:

Sends the window to the bottom of the stack.

**Return Value**:

- **Type**: `this`

---

<a id="MoveTop"></a>

### `MoveTop() => this`

**Description**:

Sends the window to the top of the stack.

**Return Value**:

- **Type**: `this`

---

<a id="Redraw"></a>

### `Redraw() => this`

**Description**:

Redraws the window.

**Return Value**:

- **Type**: `this`

---

<a id="Restore"></a>

### `Restore() => this`

**Description**:

Restores the window.

**Return Value**:

- **Type**: `this`

---

<a id="SetAlwaysOnTop"></a>

### `SetAlwaysOnTop(Value: Integer?) => this`

**Description**:

Makes the window stay on top of all other windows.

**Parameters**:

| Parameter Name | Type       | Description |
| -------------- | ---------- | ----------- |
| `Value`        | `Integer?` | New setting |

**Return Value**:

- **Type**: `this`

---

<a id="SetEnabled"></a>

### `SetEnabled(Value: Integer) => this`

**Description**:

Enables or disables the window.

**Parameters**:

| Parameter Name | Type      | Description |
| -------------- | --------- | ----------- |
| `Value`        | `Integer` | New setting |

**Return Value**:

- **Type**: `this`

---

<a id="SetRegion"></a>

### `SetRegion(Value: Integer) => this`

**Description**:

Sets the window to be the specified rectangle, ellipse or polygon.

**Parameters**:

| Parameter Name | Type      | Description |
| -------------- | --------- | ----------- |
| `Value`        | `Integer` | New setting |

**Return Value**:

- **Type**: `this`

---

<a id="Wait"></a>

### `Wait(Timeout: Number?) => Window`

**Description**:

Waits until the window exists with the given timeout in seconds.

**Parameters**:

| Parameter Name | Type      | Description                   |
| -------------- | --------- | ----------------------------- |
| `Timeout`      | `Number?` | Max number of seconds to wait |

**Return Value**:

- **Type**: `Window`

---

<a id="WaitActive"></a>

### `WaitActive(Timeout: Number?) => Window`

**Description**:

Waits until the window is active with the given timeout in seconds.

**Parameters**:

| Parameter Name | Type      | Description                   |
| -------------- | --------- | ----------------------------- |
| `Timeout`      | `Number?` | Max number of seconds to wait |

**Return Value**:

- **Type**: `Window`

---

<a id="WaitNotActive"></a>

### `WaitNotActive(Timeout: Number?) => this`

**Description**:

Waits until the window is not active anymore with the given timeout
in seconds

**Parameters**:

| Parameter Name | Type      | Description                   |
| -------------- | --------- | ----------------------------- |
| `Timeout`      | `Number?` | Max number of seconds to wait |

**Return Value**:

- **Type**: `this`

---

<a id="WaitClose"></a>

### `WaitClose(Timeout: Number?) => Window`

**Description**:

Waits until no windows matching the WinTitle parameter of the `Window` can be
found, with the given timeout in seconds.

**Parameters**:

| Parameter Name | Type      | Description                   |
| -------------- | --------- | ----------------------------- |
| `Timeout`      | `Number?` | Max number of seconds to wait |

**Return Value**:

- **Type**: `Window`

---

<a id="StatusBarWait"></a>

### `StatusBarWait(BarText: String?, Timeout: Number?, Index: Integer?, Interval: Integer?) => Boolean`

**Description**:

Waits until the window's status bar contains the specified string.

**Parameters**:

| Parameter Name | Type       | Description                   |
| -------------- | ---------- | ----------------------------- |
| `BarText`      | `String?`  | The text to wait for          |
| `Timeout`      | `Number?`  | Max number of seconds to wait |
| `Index`        | `Integer?` | Number of the bar to retrieve |
| `Interval`     | `Integer?` | Interval in milliseconds      |

**Return Value**:

- **Type**: `Boolean`

---

## Property Details

<a id="Active"></a>

### `Active => Integer`

**Description**:

Returns the HWND if the window is currently active, otherwise `false`.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="Exists"></a>

### `Exists => Integer`

**Description**:

Returns the HWND if the window exists, otherwise `false`.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="ClassName"></a>

### `ClassName => String`

**Description**:

Returns the class name of the window.

**Property Type**: `get`

**Return Value**:

- **Type**: `String`

---

<a id="ClientPos"></a>

### `ClientPos => Object`

**Description**:

Returns the client position of the window in the form of an object.

**Property Type**: `get`

**Return Value**:

- **Type**: `Object`

---

<a id="Controls"></a>

### `Controls => Array`

**Description**:

Returns an array of names for all controls of the window.

**Property Type**: `get`

**Return Value**:

- **Type**: `Array`

---

<a id="ControlsHwnd"></a>

### `ControlsHwnd => Array`

**Description**:

Returns an array of unique ID numbers (HWND) for all controls of the window

**Property Type**: `get`

**Return Value**:

- **Type**: `Array`

---

<a id="Control"></a>

### `Control[Ctl: Integer/String] => Control`

**Description**:

Returns a `Control` by the given control name (ClassNN) or its HWND.

**Property Type**: `get`

**Return Value**:

- **Type**: `Control`

---

<a id="Count"></a>

### `Count => Integer`

**Description**:

Returns the number of windows that match the WinTitle parameters.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="ID"></a>

### `ID => Integer`

**Description**:

Returns the unique ID (HWND) of the window.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="Hwnd"></a>

### `Hwnd => Integer`

**Description**:

Returns the unique ID (HWND) of the window.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="IDLast"></a>

### `IDLast => Integer`

**Description**:

Returns the unique ID (HWND) of the last matching window.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="Minimized"></a>

### `Minimized => Boolean`

**Description**:

Returns `true` if the window is minimized.

**Property Type**: `get`

**Return Value**:

- **Type**: `Boolean`

---

<a id="Maximized"></a>

### `Maximized => Boolean`

**Description**:

Returns `true` if the window is maximized.

**Property Type**: `get`

**Return Value**:

- **Type**: `Boolean`

---

<a id="PID"></a>

### `PID => Integer`

**Description**:

Returns the process ID (PID) of the window.

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`

---

<a id="Pos"></a>

### `Pos => Object`

**Description**:

Returns the position of the window in the form of an object.

**Property Type**: `get`

**Return Value**:

- **Type**: `Object`

---

<a id="ProcessName"></a>

### `ProcessName => String`

**Description**:

Returns the process name of the window.

**Property Type**: `get`

**Return Value**:

- **Type**: `String`

---

<a id="ProcessPath"></a>

### `ProcessPath => String`

**Description**:

Returns the process path of the window,

**Property Type**: `get`

**Return Value**:

- **Type**: `String`

---

<a id="Style"></a>

### `Style => Integer`

**Description**:

Retrieves and changes the current style of the window.

**Property Type**: `get/set`

**Parameters**:

| Property Name | Type             | Description  |
| ------------- | ---------------- | ------------ |
| `Value`       | `Integer/String` | New settings |

**Return Value**:

- **Type**: `Integer`

---

<a id="ExStyle"></a>

### `ExStyle => Integer`

**Description**:

Retrieves and changes the current extended style of the window.

**Property Type**: `get/set`

**Parameters**:

| Property Name | Type             | Description  |
| ------------- | ---------------- | ------------ |
| `Value`       | `Integer/String` | New settings |

**Return Value**:

- **Type**: `Integer`

---

<a id="Text"></a>

### `Text => String`

**Description**:

Retrieves the text from the window.

**Property Type**: `get`

**Return Value**:

- **Type**: `String`

---

<a id="Title"></a>

### `Title => String`

**Description**:

Retrieves and changes the window title.

**Property Type**: `get/set`

**Parameters**:

| Property Name | Type     | Description      |
| ------------- | -------- | ---------------- |
| `Value`       | `String` | New window title |

**Return Value**:

- **Type**: ``

---

<a id="TransColor"></a>

### `TransColor => String`

**Description**:

Retrieves and changes the transparent color in the window.

**Property Type**: `get/set`

**Parameters**:

| Property Name | Type             | Description                                    |
| ------------- | ---------------- | ---------------------------------------------- |
| `Value`       | `Integer/String` | Color name or RGB value, optional transparency |

**Return Value**:

- **Type**: `String`

---

<a id="Transparent"></a>

### `Transparent => Integer`

**Description**:

Retrieves and changes the transparency setting of the window.

**Property Type**: `get/set`

**Parameters**:

| Property Name | Type             | Description              |
| ------------- | ---------------- | ------------------------ |
| `Value`       | `Integer/String` | New transparency setting |

**Return Value**:

- **Type**: `Integer`

---

<a id="AlwaysOnTop"></a>

### `AlwaysOnTop => Integer`

**Description**:

Makes the window stay on top of all other windows.

**Property Type**: `set`

**Parameters**:

| Property Name | Type      | Description |
| ------------- | --------- | ----------- |
| `Value`       | `Integer` | New setting |

**Return Value**:

- **Type**: `Integer`

---

<a id="Enabled"></a>

### `Enabled => Integer`

**Description**:

Enables or disables the window.

**Property Type**: `set`

**Parameters**:

| Property Name | Type      | Description |
| ------------- | --------- | ----------- |
| `Value`       | `Integer` | New setting |

**Return Value**:

- **Type**: `Integer`

---

<a id="Region"></a>

### `Region => String`

**Description**:

Sets the window to be the specified rectangle, ellipse or polygon.

**Property Type**: `set`

**Parameters**:

| Property Name | Type     | Description |
| ------------- | -------- | ----------- |
| `Value`       | `String` | New setting |

**Return Value**:

- **Type**: `String`

---

<a id="StatusBarText"></a>

### `StatusBarText[Index: Integer?] => String`

**Description**:

Retrieves the text from a standard status bar control.

**Property Type**: `get`

**Parameters**:

| Property Name | Type       | Description                  |
| ------------- | ---------- | ---------------------------- |
| `Index`       | `Integer?` | Index of the bar to retrieve |

**Return Value**:

- **Type**: `String`
