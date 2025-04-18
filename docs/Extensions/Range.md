# Range

**Synopsis**:

`Range(Start: Number, End: Number?, Step: Number?) => Stream`

**Description**:

Returns a stream containing an arithmetic progression of numbers between
`Start` and `End`, inclusive, optionally at a specified interval of `Step`
(otherwise `1` or `-1`).

If parameter `End` is not specified, the resulting stream will range from `1` to the first parameter `Start`.

**Example**:

```ahk
Range(10)      ; <1, 2, 3, 4, 5, 6, 7, 8, 9, 10>
Range(4, 7)    ; <4, 5, 6, 7>
Range(5, 3)    ; <5, 4, 3>
Range(3, 8, 2) ; <3, 5, 7>
```

**Parameters**:

| Parameter Name | Type      | Description               |
| -------------- | --------- | ------------------------- |
| `Start`        | `Number`  | Start of the sequence     |
| `End`          | `Number?` | End of the sequence       |
| `Step`         | `Number?` | Interval between elements |

**Return Value**:

- **Type**: `Stream`
