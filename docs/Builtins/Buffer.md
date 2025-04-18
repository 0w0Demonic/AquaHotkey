
# Buffer

## Method Summary

| Method Name                                                      | Return Type | Description                                               |
| ---------------------------------------------------------------- | ----------- | --------------------------------------------------------- |
| [`Get<NumType>(Offset := 0)`](#NumGet)                           | `<NumType>` | Returns a binary number from this buffer at `Offset`      |
| [`Put<NumType>(Value, Offset := 0)`](#NumPut)                    | `<NumType>` | Puts a binary number `Value` into this buffer at `Offset` |
| [`static HexDump(Delimiter := " ", LineLength := 16)`](#HexDump) | `String`    | Returns a hex dump of this buffer                         |
| [`static OfString(Str, Encoding?)`](#OfString)                   | `Buffer`    | Returns a buffer containing string `Str`                  |
| [`ToString()`](#ToString)                                        | `String`    | Returns a string representation of this buffer            |

---

## Method Details

<a id="NumGet"></a>

### `Get<NumType>(Offset: Integer) => <NumType>`

**Description**:

Returns a binary number from this buffer at `this.Ptr + Offset`.

**Example**:

```ahk
Num := Buf.GetChar(16) ; same as `NumGet(Buf, 16, "Char")`
```

**Parameters**:

| Method Name | Return Type | Description         |
| ----------- | ----------- | ------------------- |
| `Offset`    | `Integer`   | The offset in bytes |

**Return Value**:

- **Type**: `<NumType>`

---

<a id="NumPut"></a>

## `Put<NumType>(Value: Number, Offset: Integer := 0) => <NumType>`

**Description**:

Puts a binary number `Value` into this buffer at `this.Ptr + Offset` and then
returns the previously stored value.

**Example**:

```ahk
OldValue := Buf.PutChar(34, 8) ; same as `NumPut("Char", 34, Buf, 8)`
```

**Parameters**:

| Parameter Name | Type        | Description            |
| -------------- | ----------- | ---------------------- |
| `Value`        | `<NumType>` | New value to be stored |
| `Offset`       | `Integer`   | The offset in bytes    |

**Return Value**:

- **Type**: `<NumType>` - the previously contained number

---

<a id="HexDump"></a>

### `static HexDump(Delimiter: String := " ", LineLength: Integer := 16) => String`

**Description**:

Returns a hexadecimal representation of this buffer.

**Example**:

```ahk
Buf := Buffer()
; ...
Buf.HexDump() ; 48 65 6C 6C 6F 2C 20 77 6F 72 6C 64 21 ...
```

**Parameters**:

| Parameter Name  |  Type           | Description                   |
| --------------- | --------------- | ----------------------------- |
| `Delimiter`     | `String := " "` | Any string                    |
| `LineLength`    | `Integer := 16` | Target encoding of the string |

**Return Value**:

- **Type**: `String`

---

<a id="OfString"></a>

### `static OfString(Str: String, Encoding: Primitive?) => Buffer`

**Description**:

Returns a buffer entirely containing the string `Str` encoded in `Encoding`
(default UTF-16).

**Example**:

```ahk
Buf := Buffer.OfString("foo", "utf-8")
```

**Parameters**:

| Parameter Name | Type         | Description            |
| -------------- | ------------ | ---------------------- |
| `Str`          | `String`     | Any string             |
| `Encoding`     | `Primitive?` | Encoding of the string |

**Return Value**:

- **Type**: `Buffer`

---

<a id="ToString"></a>

### `ToString() => String`

**Description**:

Returns a string representation of this buffer consisting of its
type, memory address pointer and size in bytes.

**Example**:

```ahk
Buffer(128).ToString() ; "Buffer { Ptr: 000000000024D080, Size: 128 }"
```

**Return Value**:

- **Type**: `String`
