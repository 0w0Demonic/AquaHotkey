# Module `<Interfaces>`

- [All Modules](../api-overview.md)

## List of Features

- [Enumerable1](./Enumerable1.md)
- [Enumerable2](./Enumerable2.md)
- [IArray](./IArray.md)
- [IBuffer](./IBuffer.md)
- [IDelegatingMap](./IDelegatingMap.md)
- [IMap](./IMap.md)
- [Indexable](./Indexable.md)
- [ISet](./ISet.md)
- [Sizeable](./Sizeable.md)

## Enumerable1 and Enumerable2

- [Enumerable1](./Enumerable1.md)
- [Enumerable2](./Enumerable2.md)

Interface for types supporting iteration via the for-loop. Defines the
contract for single-parameter iteration.

```ahk
; `IArray` implements both `Enumerable1` and `Enumerable2` which contain
; a big variety of methods like `.ForEach()` or `.JoinLine()`
; 
Array(1, 2, 3, 4).ForEach(MsgBox)
Array(1, 2, 3, 4).JoinLine()
```

**Collection Interfaces**:

- [<Interfaces/IArray>](./Interfaces/IArray.md)
- [<Interfaces/IMap>](./Interfaces/IMap.md)
- [<Interfaces/ISet>](./Interfaces/ISet.md)

(TODO)

**See Also**:

- [duck types](../Base/DuckTypes.md)

**Other Interfaces**:

- [<Interfaces/IBuffer>](./Interfaces/IBuffer.md)

Interface for buffer-like objects with pointer and size properties.

- [<Interfaces/IDelegatingMap>](./Interfaces/IDelegatingMap.md)

Interface for maps that delegate operations to an underlying map implementation.

- [<Interfaces/Indexable>](./Interfaces/Indexable.md)

Interface for types supporting random access via indexing operators.

- [<Interfaces/Sizeable>](./Interfaces/Sizeable.md)

Interface for types with a measurable `.Length` or `.Size` property.

- [<Interfaces/Deque>](./Interfaces/Deque.md)

Interface for double-ended queue collections supporting efficient operations
at both ends.
