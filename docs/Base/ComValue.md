# ComValue

- [Overview](#overview)
- [VARIANT Type Constants](#variant-type-constants)
  - [As Constants](#as-constants)
  - [As Constructors](#as-constructors)
- [Automatic Inclusion of `VT_ARRAY` and `VT_BYREF` Flags](#automatic-inclusion-of-vt_array-and-vt_byref-flags)
- [Improvements for `ComValueRef`](#improvements-for-comvalueref)
  - [Constructor Method](#constructor-method)
  - [Getter and Setter Methods](#getter-and-setter-methods)
- [List of All VARIANT Types](#list-of-all-variant-types)

## Overview

The built-in AutoHotkey class `ComValue` and its subtypes `ComValueRef` and
`ComObjArray` receive additional extensions to make it easier working with
COM objects by abstracting away the direct usage of VARIANT type constants.

```ahk
; Buf := Buffer(24, 0)
; Ref := ComValue(0x4000 | 0xC, Buf.Ptr)
; Buf[] := "in value"
Ref := ComValueRef.VARIANT(Buffer(24, 0)).Set("in value")

sc.Run("Example", var)

; MsgBox(Ref[])
Ref.Get().MsgBox()
```

## VARIANT Type Constants

`ComValue` now includes properties for each VARIANT type (e.g.
`BOOL`, `BSTR`, `INT32`, etc.)

These properties serve two purposes:

### As Constants

Accessing the property directly returns the associated
VARIANT type

```ahk
MsgBox(ComValue.BSTR) ; 8
```

### As Constructors

Calling the property constructs a new instance of
`ComValue` without requiring the VARIANT type as the first parameter.

```ahk
Str := ComValue.BSTR("in value")
```

## Automatic Inclusion of `VT_ARRAY` and `VT_BYREF` Flags

Users no longer have to manually specify the `VT_ARRAY` and `VT_BYREF`
flags when creating new instances. Instead, the built-in classes
`ComObjArray` and `ComValueRef` automatically include these flags when
their constructors are called.

- `ComObjArray`
  - Automatically adds the `VT_ARRAY` flag

  ```ahk
  Arr := ComObjArray.VARIANT(3) ; ComValue(0x2000 | 0xC, 3)
  ```

- `ComValueRef`
  - Automatically adds the `VT_BYREF` flag

  ```ahk
  Ref := ComValueRef.VARIANT(Buffer(24, 0)) ; ComValue(0x4000 | 0xC, Buffer(24, 0).Ptr)
  ```

## Improvements for `ComValueRef`

### Constructor Method

The `ComValueRef` class now supports passing buffer-like objects with a `Ptr` property
when creating `BYREF` values, instead of requiring raw pointer values.

```ahk
ComValueRef.VARIANT(Buffer(24, 0))
```

### Getter and Setter Methods

Instead of using the `__Item()` Values of `ComValueRef` instances can be set using
methods `Get()` and `Set()`.

```ahk
Ref := ComValueRef.VARIANT(Buffer(24, 0)).Set("in value") ; `Set(Value) => this`

MsgBox(Ref.Get()) ; "in value"
```

## List of All VARIANT Types

| Class Member Name       | VARIANT Type Name | Value    |
| ----------------------- | ----------------- | -------- |
| `EMPTY`                 | `VT_EMPTY`        | `0x0`    |
| `NULL`                  | `VT_NULL`         | `0x1`    |
| `INT16`                 | `VT_I2`           | `0x2`    |
| `INT32`                 | `VT_I4`           | `0x3`    |
| `FLOAT32`               | `VT_R4`           | `0x4`    |
| `FLOAT64`               | `VT_R8`           | `0x5`    |
| `CURRENCY`              | `VT_CY`           | `0x6`    |
| `DATE`                  | `VT_DATE`         | `0x7`    |
| `BSTR`                  | `VT_BSTR`         | `0x8`    |
| `DISPATCH`              | `VT_DISPATCH`     | `0x9`    |
| `ERROR`                 | `VT_ERROR`        | `0xA`    |
| `BOOL`                  | `VT_BOOL`         | `0xB`    |
| `VARIANT`               | `VT_VARIANT`      | `0xC`    |
| `UNKNOWN`               | `VT_UNKNOWN`      | `0xD`    |
| `DECIMAL`               | `VT_DECIMAL`      | `0xE`    |
| `INT8`                  | `VT_I1`           | `0x10`   |
| `UINT8`                 | `VT_UI1`          | `0x11`   |
| `UINT16`                | `VT_UI2`          | `0x12`   |
| `UINT32`                | `VT_UI4`          | `0x13`   |
| `INT64`                 | `VT_I8`           | `0x14`   |
| `UINT64`                | `VT_UI8`          | `0x15`   |
| `INT`                   | `VT_INT`          | `0x16`   |
| `UINT`                  | `VT_UINT`         | `0x17`   |
| `RECORD`                | `VT_RECORD`       | `0x24`   |
| `ARRAY`                 | `VT_ARRAY`        | `0x2000` |
| `BYREF`                 | `VT_BYREF`        | `0x4000` |
