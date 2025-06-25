# Map

## Misc

- Use `.Keys()` and `.Values()` to retrieve all keys or values in the map.

```ahk
M := Map("foo", "bar", "hotel", "Trivago")

; ["foo", "hotel"]
M.Keys()

; ["bar", "Trivago"]
M.Values()
```

## Stream-Like Methods

Just like [Arrays](./Array.md), maps support stream-like methods like `.Map()`,
`.RetainIf()`, `.ForEach()` etc.
Each function receives `(Key, Value)` as its first arguments, followed by
additional `Args*` (just like for arrays, you should
[use `Args*` judiciously](./Array.md#Using-args)).

```ahk
MyMap.Map((Key, Value) => StrUpper(Value))
```

## Conditional Operations

You can use `.PutIfAbsent()`, `.ComputeIfAbsent()`, `.ComputeIfPresent()`,
`.Compute()` and `.Merge()` - they behave just like their Java counterparts.

```ahk
MyMap.PutIfAbsent("foo", "bar")

MyMap.Merge(Key, 1, Combiner.Sum)
```

## Matching

Use `.AnyMatch()`, `.AllMatch()` and `.NoneMatch()` to test whether the
key-value pairs satisfy a condition:

```ahk
; returns either { key: ..., value: ... } or `false`
MyMap.AnyMatch((k, v) => ...)
```

These method names might be changed to `.Any()`, `.All()` and `.None()` in
future versions and likely added to arrays.
