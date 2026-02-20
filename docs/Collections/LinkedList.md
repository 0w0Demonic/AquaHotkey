# <[Collections](./overview.md)/[LinkedList](../../src/Collections/LinkedList.ahk)>

- [Overview](#overview)

## Overview

An implementation of [IArray](../Interfaces/IArray.md) as doubly linked list.
On occasions where you need to frequently insert or remove elements from both
the front and back of a list, a LinkedList can be more efficient than an
Array. However, it is not optimized for random access.

```ahk
L := LinkedList(1, 2, 3, 4)
L.Shove(0)
L.Push(5)

L.Pop()  ; 5
L.Poll() ; 0
```

In addition to the regular array methods, this class also introduces its own
list iterator based on [`java.util.ListIterator`](https://docs.oracle.com/en/java/javase/24/docs/api/java.base/java/util/ListIterator.html).

```ahk
L := LinkedList(1, 2, 3, 4)

; [1 , 2 , 3 , 4]
;        ^
It := L.Iterator(3)

while (It.Next(&Value)) {
    It.Remove()
    MsgBox(Value) ; 3, 4
}

; 1, 2
L.Slurp().ForEach(MsgBox)

; 0
MsgBox(L.Length)
```
