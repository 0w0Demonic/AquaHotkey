# <[Collections](./overview.md)/[ByteArray](../../src/Collections/ByteArray.ahk)>

- [\<Collections/ByteArray\>](#collectionsbytearray)
  - [Overview](#overview)

## Overview

A buffer or buffer-like object viewed as an array of bytes.

```ahk
; [103, 0, 105, 0, 114, 0, 97, 0, 102, 0, 102, 0, 101, 0, 0, 0]
Buffer.OfString("giraffe", "UTF-16").AsByteArray()
```

**See Also**:

- [<Interfaces/IArray>](../Interfaces/IArray.md)
- [<Interfaces/IBuffer>](../Interfaces/IBuffer.md)