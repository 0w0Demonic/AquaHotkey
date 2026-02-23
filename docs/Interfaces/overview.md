# Module `<Interfaces>`

- [All Modules](../api-overview.md)o
  
---

- [Module `<Interfaces>`](#module-interfaces)
  - [Overview](#overview)
  - [List of Features](#list-of-features)
  - [Enumerable1 and Enumerable2](#enumerable1-and-enumerable2)
  - [Collection Interfaces](#collection-interfaces)
  - [Other Interfaces](#other-interfaces)

## Overview

Interfaces represent contracts that classes can implement to guarantee the
presence of certain methods or properties. In AquaHotkeyX, they either act
as abstract classes, or as mixins for default implementations.

## List of Features

- [Enumerable1](./Enumerable1.md)
- [Enumerable2](./Enumerable2.md)
- [IArray](./IArray.md)
- [IBuffer](./IBuffer.md)
- [IMap](./IMap.md)
- [ISet](./ISet.md)

## Enumerable1 and Enumerable2

- [`<Interfaces/Enumerable1>`](./Enumerable1.md)
- [`<Interfaces/Enumerable2>`](./Enumerable2.md)

Interface for types supporting iteration via the for-loop. Defines the
contract for single-parameter iteration.

```ahk
; `IArray` implements both `Enumerable1` and `Enumerable2` which contain
; a big variety of methods like `.ForEach()` or `.JoinLine()`
; 
Array(1, 2, 3, 4).ForEach(MsgBox)
Array(1, 2, 3, 4).JoinLine()
```

## Collection Interfaces

- [<Interfaces/IArray>](./Interfaces/IArray.md)
- [<Interfaces/IMap>](./Interfaces/IMap.md)
- [<Interfaces/ISet>](./Interfaces/ISet.md)

These interfaces represent the abstract classes that are used as the basis for
the collection classes in AquaHotkeyX. They define the core methods and
properties that they must implement, as well as some default implementations
for common operations.

```ahk
Object
|- IArray
|  |- Array
|  |- ImmutableArray
|  `- LinkedList
|
`- etc.
```

`Array` and `Map` are the main implementations of `IArray` and `IMap`,
respectively, but there are also other classes that implement these interfaces,
such as `ImmutableArray` and `LinkedList`. This makes it very easy to switch
between different implementations of the same interface.

**See Also**:

- [Duck Types](../Base/DuckTypes.md)
- [Collection Classes](../Collections/overview.md)

## Other Interfaces

- [<Interfaces/IBuffer>](./Interfaces/IBuffer.md)

Interface for buffer-like objects with pointer and size properties.
It implements many buffer related methods such as reading/writing, and hex
dumps.
