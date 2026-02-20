# <[Func](./overview.md)/[Transducer](./Transducer.md)>

## Overview

Transducers are composable higher-order reducers. They are used to create
reducer functions that can be used with
[`.Reduce()`](../Interfaces/Enumerable1.md#reduction).

```ahk
Times(x) => (n) => (n * x)

Reducer := Transducer().Map(Times(2)).Finally(Sum)
```

**See Also**:

- [predicate functions](./Predicate.md)

## Methods

### `.RetainIf()`

Returns a transducer that retains only the values that satisfy the given
predicate.

```ahk
.RetainIf(Even)
```

### `.RemoveIf()`

Same as `.RetainIf()`, but removes the values that satisfy the given predicate.

```ahk
.RemoveIf(Lt(10))
```

### `.Map()`

Transform elements as they're being collected.

```ahk
.Map(Times(2))
```

### `.Finally()`

Accepts the final reducer function that will be used to reduce the transformed
values. You should prefer using `.Finally()` instead of directly creating a
reducer via `.Call()`.
