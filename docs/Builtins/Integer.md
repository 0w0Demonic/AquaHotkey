# Integer

## Method Summary

| Method Name                           | Return Type | Description                                               |
| ------------------------------------- | ----------- | --------------------------------------------------------- |
| [`ToHexString()`](#ToHexString)       | `String`    | Converts this integer into its hexadecimal representation |
| [`ToBinaryString()`](#ToBinaryString) | `String`    | Converts this integer into its binary representation      |
| [`Signum()`](#Signum)                 | `Integer`   | Returns the signum function of this integer               |

---

## Method Details

<a id="ToHexString"></a>

### `ToHexString() => String`

**Description**:

Returns this integer converted into its hexadecimal representation.

**Example**:

```ahk
31.ToHexString() ; "1F"
```

**Return Value**:

- **Type**: `String`

---

<a id="ToBinaryString"></a>

### `ToBinaryString() => String`

**Description**:

Returns this integer converted into its binary representation.

**Example**:

```ahk
14.ToBinaryString() ; 1110
```

**Return Value**:

- **Type**: `String`

---

<a id="Signum"></a>

### `Signum() => Integer`

**Description**:

Returns the signum function of this integer.

**Example**:

```ahk
-23.Signum()   ; -1
0.Signum()     ; 0
91283.Signum() ; 1
```

**Return Value**:

- **Type**: `Integer`
