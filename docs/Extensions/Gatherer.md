# Gatherer

Gatherers are a highly customizable interface to help convert a stream of
input elements into a stream of output elements.

Note that they are exclusively used alongside streams and a warning
is thrown whenever they're not imported.

```ahk
#Include .../Gatherer.ahk

; oops! missing "Stream.ahk".
```

## Quick Overview

```ahk
G := Gatherer

; <(1, 2, 3), (4, 5, 6), (7, 8, 9), (10, 11)>
Range(11).Stream().Gather(  G.WindowFixed(3)  )

; <(1, 2, 3), (2, 3, 4), (3, 4, 5)>
Range(5).Stream().Gather(  G.WindowSliding(3)  )

; <1, 3, 6, 10, 15>
Array(1, 2, 3, 4, 5).Gather(  G.Scan(Combiner.Sum)  )
```
