# <[Stream](./overview.md)/[Gatherer](../../src/Stream/Gatherer.ahk)>

- [\<Stream/Gatherer\>](#streamgatherer)
  - [Overview](#overview)
  - [How to Implement](#how-to-implement)

## Overview

Gatherers are a highly customizable interface to help convert a stream of
input elements into a stream of output elements. Use the `.Gather()` method on
a (size-1) [Stream](./Stream.md) to apply a gatherer to it.

```ahk
; --> <(1, 2), (3, 4), (5, 6), (7, 8), (9, 10)>
Range(10).Stream().Gather(WindowFixed(2))

; --> <1, 3, 6, 10, 15>
Array(1, 2, 3, 4, 5).Gather(Scan(Sum))
```

At the moment, only size 1 gatherers are supported, but this might change
very soon.

## How to Implement

If you're curious about how to implement your own custom gatherers, you can
have a look at the source code of
[Gatherer.ahk](../../src/Extensions/Gatherer.ahk). Here's a quick rundown:

A gatherer is a subclass of `Func`. It must have the following signature:

```ahk
Gatherer(Upstream, Downstream) => Boolean
```

`Upstream` is a stream of input elements, and `Downstream` is a function that
pushes output elements to the downstream. The gatherer must return `true` to
indicate success, otherwise `false` to terminate the stream.

```ahk
GatherTimesTwo(Upstream, Downstream) {
    ; are there more values upstream?
    if (Upstream(&Value)) {
        Downstream(Value?, Value?) ; yes -> push to downstream twice
        return true ; return true to indicate success
    }
    ; no -> return false to terminate the stream
    return false
}

Array(1, 2, 3).Stream().Gather(GatherTimesTwo) ; --> <1, 1, 2, 2, 3, 3>
```