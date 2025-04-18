# Error

## Method Summary

| Property Name                          | Return Type | Description     |
| -------------------------------------- | ----------- | --------------- |
| [`Throw(Msg?, What?, Extra?)`](#Throw) | (none)      | Throws an error |

---

## Method Details

<a id="Throw"></a>

### `Throw(Msg: Primitive?, What: Primitive?, Extra: Primitive?) => (none)`

**Description**:

Throws an error of this class.

**Example**:

```ahk
class Foo {
    static DoSomething() => MethodError.Throw("not implemented")
}

HWND := (WinExist("Untitled - Notepad") || TargetError.Throw("notepad.exe not opened"))
```

**Parameters**:

| Parameter Name | Type         | Description                       |
| -------------- | ------------ | --------------------------------- |
| `Msg`          | `Primitive?` | Message of the error object       |
| `What`         | `Primitive?` | What threw the exception          |
| `Extra`        | `Primitive?` | Extra information about the error |

**Return Value**:

- **Type**: (none)
