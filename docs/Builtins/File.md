# File

## Method Summary

| Method Name               | Return Type  | Description                                  |
| ------------------------- | ------------ | -------------------------------------------- |
| [`__Enum(n)`](#__Enum)    | `Enumerator` | Enumerates all lines of this file            |
| [`ToString()`](#ToString) | `String`     | Returns a string representation of this file |

---

## Property Summary

| Property Name   | Property Type | Return Type | Description                   |
| --------------- | ------------- | ----------- | ----------------------------- |
| [`Name`](#Name) | `get`         | `String`    | Returns the name of this file |

---

## Method Details

<a id="__Enum"></a>

### `__Enum(n: Integer) => Enumerator`

**Description**:

Returns an `Enumerator` that iterates through all lines of this file.

The file is properly closed after all lines have been enumerated.

The object returned by this method can also be used as a function stream.

**Example**:

```ahk
for LineNumber, Line in FileOpen("message.txt") {
    MsgBox("Line " . LineNumber . ": " . Line)
}

FileOpen("message.txt").Stream().ForEach(MsgBox)
```

**Parameters**:

| Parameter Name | Type      | Description                                 |
| -------------- | --------- | ------------------------------------------- |
| `n`            | `Integer` | Parameter length of the enumerator (1 or 2) |

**Return Value**:

- **Type**: `Enumerator`

---

<a id="ToString"></a>

### `ToString() => String`

**Description**:

Returns a string representation of this file object, consisting of file name,
position of file pointer, file encoding and the system file handle.

**Example**:

```ahk
; "File { Name: C:\...\foo.txt, Pos: 0, Encoding: UTF-8, Handle: 362 }"
FileObj.ToString()
```

**Return Value**:

- **Type**: `String`

---

## Property Details

<a id="Name"></a>

### `Name => String`

**Description**:

Returns the file name of this file object.

**Property Type**: `get`

**Example**:

```ahk
FileObj.Name ; "C:\...\hello.txt"
```

**Return Value**:

- **Type**: `String`
