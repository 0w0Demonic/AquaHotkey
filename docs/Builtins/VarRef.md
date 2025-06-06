# VarRef

## Method Summary

| Method Name               | Return Type | Description                                    |
| ------------------------- | ----------- | ---------------------------------------------- |
| [`ToString()`](#ToString) | `String`    | Returns a string representation of this VarRef |

---

## Property Summary

| Property Name | Property Type | Return Type | Description                                                |
| ------------- | ------------- | ----------- | ---------------------------------------------------------- |
| [`Ptr`](#Ptr) | `get`         | `Integer`   | Returns the pointer to the variable this VarRef references |

---

## Method Details

<a id="ToString"></a>

### `ToString() => String`

**Description**:

Returns a string representation of this VarRef.

**Example**:

```ahk
foo := "bar"
ref := &foo

ref.ToString() ; "&foo"
```

**Return Value**:

- **Type**: `String`

---

## Property Details

<a id="Ptr"></a>

### `Ptr => Integer`

**Description**:

Returns the pointer of the string or object that this VarRef references.

This property allows passing string to `DllCall()` as ByRef `&Str`.

**Example**:

```ahk
str := "foo"
ref := &str

; ref.Ptr == StrPtr(str)

obj := Object()
ref := &obj

; ref.Ptr == ObjPtr(obj)
```

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`
