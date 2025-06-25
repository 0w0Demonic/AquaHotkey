# Range

Returns an enumerable functions that returns an arithmetic progression
between `Start` and `End`, optionally at the specified interval `Step`
(otherwise defaults to `1` or `-1`).

```ahk
Range(10)      ; <1, 2, 3, 4, 5, 6, 7, 8, 9, 10>
Range(4, 7)    ; <4, 5, 6, 7>
Range(5, 3)    ; <5, 4, 3>
Range(3, 8, 2) ; <3, 5, 7>
```
