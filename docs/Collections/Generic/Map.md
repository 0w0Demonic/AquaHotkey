# <[Collections](../overview.md)/[Generic](./overview.md)/[Map](../../../src/Collections/Generic/Map.ahk)>

## Overview

A type-checked wrapper for [IMap](../../Interfaces/IMap.md) classes.
Generic maps wrap around any map class that implements `IMap`, and enforces
that their key-value mappings conform to specified
[duck types](../../Base/DuckTypes.md).

```ahk
MapCls := Map.OfType(String, String)

M := MapCls("key1", "value1", "key2", "value2")
M.Set("key3", [1, 2]) ; TypeError! Expected a String as value.
```

To create a new generic map class, use `IMap.OfType(T)`.

```ahk
; --> class Map<String, String>
Cls := Map.OfType(String, String)

; --> class HashMap<Tuple<String, String>, String>
Cls := HashMap.OfType(Tuple(String, String), String)
```

## Use as Type Pattern

If the tested value is another generic map, its types are checked for
compatibility via
[`.CanCastFrom()`](../../Base/DuckTypes.md#subclasses-and-cancastfromt).

Otherwise, the tested value must be instance of the class's map type, and all
key-value pairs must match the type pattern imposed by the generic map class.

```ahk
class Email extends String {
    static IsInstance(Val?) => ...
}

Cls := Map.OfType(Email, { name: String, age: Integer })
M := Cls()
```
