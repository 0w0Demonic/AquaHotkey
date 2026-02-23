# <[Stream](./overview.md)/[Count](../../src/Stream/Count.ahk)>

- [\<Stream/Count\>](#streamcount)
  - [Overview](#overview)

## Overview

`Count()` creates an infinite stream of numbers, starting at `Start` and
increasing by `Step` indefinitely. `Start` defaults to `1` and `Step` defaults
to `1` as well, so `Count()` by itself creates the stream of natural numbers.

```ahk
Count() ; <1, 2, 3, 4, ...>
Count(10, 2) ; <10, 12, 14, 16, ...>
```