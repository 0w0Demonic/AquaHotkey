# InputHook

## Method Summary

| Method Name                         | Return Type | Description                                                  |
| ----------------------------------- | ----------- | ------------------------------------------------------------ |
| [`GetKeyName(VK, SC)`](#GetKeyName) | `String`    | Returns the key name for virtual key `VK` and scan code `SC` |

---

## Method Details

<a id="GetKeyName"></a>

### `GetKeyName(VK: Integer, SC: Integer) => String`

**Description**:

Returns the key name associated with virtual key `VK` and scan code `SC`.

**Example**:

```ahk
Hook := InputHook()
Hook.OnKeyDown := Callback

Callback(Hook, VK, SC) {
    KeyName := InputHook.GetKeyName(VK, SC)
    ; ...
}
```

**Parameters**:

| Parameter Name | Type      | Description                 |
| -------------- | --------- | --------------------------- |
| `VK`           | `Integer` | Virtual key code of the key |
| `SC`           | `Integer` | Scan code of the key        |

**Return Value**:

- **Type**: `String`
