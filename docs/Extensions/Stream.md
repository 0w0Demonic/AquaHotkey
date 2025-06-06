# Streams in AquaHotkey

## What is a stream?

```ahk
Array(1, 2, 3, 4, 5, 6).Stream().RetainIf(x => x > 2).ForEach(MsgBox)
```

Streams are a powerful abstraction for processing sequences of data in a
declarative way. Originating from the `java.util.stream` package in the JDK,
streams allow developers to focus on what to do with data rather than how to
iterate and manipulate it.

The primary purpose of streams is to enable cleaner and more readable code by
removing boilerplate iteration logic. They operate lazily, meaning intermediate
operations (like `.Map()`) are not executed until a terminal operation
(like `.ForEach()` or `.ToArray()`) triggers the pipeline and returns a final
result. This architecture allows streams to efficiently handle both finite
and infinite data sequences.

In AquaHotkey, streams adopt the same declarative approach. The
underlying implementation builds on multiple enumerator objects, stacked on top
of each other to form a pipeline. Because of this, streams can very easily be
used in for-loops:

```ahk
DivisibleBy2(x) {
    return !(x & 1)
}

Stream := Array(1, 2, 3, 4).Stream(2).RetainIf(DivisibleBy2)

; streams can directly be used in for-loops
for Index, Value in Stream {
    MsgBox(Format("index {}: {}", Index, Value))
}
```

---

## Notation Used in Examples

To make examples concise and easy to follow, this documentation uses the
following notation:

- `<` and `>`: Denote an instance of a stream. For example, `<1, 2, 3, 4>`
  - **Example**: `<1, 2, 3, 4>` represents a stream containing the elements
                 `1`, `2`, `3` and `4`.

- `(` and `)`: Denote a single element in the stream when it has multiple
               parameters.
  - **Example**: `<(1, "foo"), (2, "bar"), (3, "baz")>` represents a stream
                 where each element is a tuple of values.

---

## Comparison with Java's Stream API

This feature is directly inspired by streams found in the `java.util.stream`
package of the JDK and behaves similarly, allowing lazy evaluation and infinite
data sequences. The naming of the basic operations, such as `.Map()`,
`.Reduce()`, and `.ForEach()`, mirrors those in Java's API.

### Key Difference: Filter Operations

Unlike Java's `.Filter()` operation, AquaHotkey uses:

- **`.RetainIf()`**: Filters elements by retaining only those that match a
  given predicate (equivalent to `.Filter()` in Java).
- **`.RemoveIf()`**: Removes elements that match a given predicate, effectively
  the opposite of `.RetainIf()`.

This approach applies not only to streams but also to mutable containers such
as `Array` and `Map`.

---

## Performance and Best Practices

### Performance Characteristics

When dealing with numbers, streams are reasonably fast, while significantly
reducing code size and improving readability.

However, there is a dramatic performance overhead when working with large
strings. This overhead arises because many unnecessary copies are made due
to the nature of how strings are passed and returned from functions in
AutoHotkey.

### Best Practices for Reducing Overhead

1. **Optimize Stream Operations**:
   - Combine consecutive operations where possible. For example, summarize
     two `.RetainIf()` operations into one to reduce overhead.
   - Use `.FlatMap()` strategically to minimize intermediate steps.

2. **Be Aware of the Lack of Automatic Optimizations**:
   - Unlike the Java Stream API, AquaHotkey does not perform optimizations such
     as skipping redundant operations (e.g., ensuring `.Distinct()` does nothing
     on already distinct streams).
   - It is assumed that users will design their streams thoughtfully to
     avoid unnecessary computations.

3. **Pass Large Strings by Reference**:
   - This is by far the most effective change to ensure good performance.
     To minimize the creation of unnecessary string copies, avoid passing large
     strings as argument or return value of a function. The best workaround is
     passing variables by reference (&).

   ```ahk
   A_Desktop.Append("\*").FindFiles().Stream()
            .Map((FilePath) => &(FileRead(FilePath)))
            .RetainIf((&FileContent) => InStr(FileContent, "foo"))

   #Requires AutoHotkey >=v2.1-alpha.3
   A_Desktop.Append("\*").FindFiles().Stream().Map((FilePath) {
       Str := FileRead(FilePath)
       return &Str
   }).RetainIf((&Str) {
       return InStr(Str, "foo")
   })
   ```

By following these guidelines, you can ensure that streams remain efficient and
practical, even for more complex expressions.

---

## Known Issues

### Function Property Limitations

Streams rely on the properties `MinParams`, `MaxParams`, and `IsVariadic` of
functions to decide how many parameters are used in the given stream operation.
These properties have incorrect values for some built-in functions such as the
enumerator returned by the `.OwnProps()` method, and for any function of type
`BoundFunc`. In future versions, the `Bind` method for function objects might
be overridden to correctly set these properties.

### Arbitrary Length Limitation

Streams with arbitrary length are not supported because of the way values are
passed through the pipeline of enumerators. However, a maximum of 4 parameters
is implemented, which should be sufficient for most use cases. If more
parameters are needed, summarizing them into objects is recommended to
keep the implementation clean.

---

## Behavior of Stream Parameter Length

The stream always takes the longest possible length it can, depending on
the intermediate operation it receives. For example:

- A stream has 3 parameters.
- An intermediate operation accepts only 2 parameters.
- The resulting stream has only 2 parameters.

To retain the 3rd set of elements, the function used in the intermediate
operation must accept all 3 parameters:

```ahk
IndexGreater2(Index, Value) {
    return (Index > 2)
}

Formatting(Index, Value) {
    return Format("{} = {}", Index, Value)
}

Array("foo", "bar", "hello", "world")
        .Stream(2) ; for Index, Value in ...
        .RetainIf(IndexGreater2)
        .Map(Formatting)
        .Join(", ")

#Requires AutoHotkey >=v2.1-alpha.3
Array("foo", "bar", "hello", "world").Stream(2).RetainIf((Index, Value) {
    return Index > 2
}).Map(Index, Value) {
    return Format("{} = {}", Index, Value)
}.Join(", ")
```

### Behavior of Specific Methods

1. **`.Map()` and `.FlatMap()`**:
   - These methods always result in a stream with a parameter length of 1
     because elements are mapped into the final result of the mapper
     function.

3. **`.Max()`, `.Min()`, and `.Join()`**:
   - These methods only use the first parameter of the stream. To access
     other parameters, `.Map()` or `.FlatMap()` should be used to rearrange or
     extract them as needed.

4. **`.ToArray()`**:
   - This method accepts an additional argument `n`, which
     specifies the index of the parameter to include in the resulting array.
     This approach avoids the use of `.Map()` or `.FlatMap()` and has better
     performance.

---

## Method Summary

| Method Name                                                    | Return Type | Description                                                                                         |
| -------------------------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------- |
| [`ArgSize(Function)`](#StreamArgSize)                          | `Integer`   | Calculates the parameter length of the new stream after adding an intermediate operation            |
| [`RetainIf(Condition)`](#RetainIf)                             | `Stream`    | Returns a stream that retains all elements that match `Condition`                                   |
| [`RemoveIf(Condition)`](#RemoveIf)                             | `Stream`    | Returns a stream that removed all elements that match `Condition`                                   |
| [`Map(Mapper)`](#Map)                                          | `Stream`    | Returns a stream that transforms elements by applying the given `Mapper` function                   |
| [`FlatMap(Mapper)`](#FlatMap)                                  | `Stream`    | Returns a stream that transforms and flattens elements by applying the given `Mapper` function      |
| [`MapByRef(Mapper)`](#MapByRef)                                | `Stream`    | Returns a stream that mutates its current elements by reference using `Mapper`                      |
| [`FindFirst()`](#FindFirst)                                    | `Stream`    | Returns a stream limited to its first element set                                                   |
| [`Limit(n)`](#Limit)                                           | `Stream`    | Returns a stream limited to `n` elements                                                            |
| [`Skip(n)`](#Skip)                                             | `Stream`    | Returns a stream that skips the first `n` elements                                                  |
| [`TakeWhile(Predicate)`](#TakeWhile)                           | `Stream`    | Returns a stream that closes immediately after elements stop satisfying `Condition`                 |
| [`DropWhile(Predicate)`](#DropWhile)                           | `Stream`    | Returns a stream that skips elements as long as elements satisfy `Condition`                        |
| [`Distinct(CaseSenseOrHasher := true, CaseSense?)`](#Distinct) | `Stream`    | Returns a stream that removes all its duplicates                                                    |
| [`Peek(Action)`](#Peek)                                        | `Stream`    | Returns a stream that performs `Action` on each element as intermediate operation                   |
| [`ForEach(Action)`](#ForEach)                                  | (none)      | Performs `Action` on each element set of the stream                                                 |
| [`AnyMatch(Predicate, &Match)`](#AnyMatch)                     | `Boolean`   | Returns `true`, if any element set in the stream satisfies `Condition`                              |
| [`AllMatch(Predicate)`](#AllMatch)                             | `Boolean`   | Returns `true`, if all element sets in the stream satisfy `Condition`                               |
| [`NoneMatch(Predicate)`](#NoneMatch)                           | `Boolean`   | Returns `true` if none of the element sets in the stream satisfy `Condition`                        |
| [`Max(Comparator?)`](#Max)                                     | `Any`       | Returns the highest element in the stream                                                           |
| [`Min(Comparator?)`](#Min)                                     | `Any`       | Returns the lowest element in the stream                                                            |
| [`Sum()`](#Sum)                                                | `Float`     | Returns the total sum of numbers in the stream                                                      |
| [`ToArray(n)`](#ToArray)                                       | `Array`     | Returns an array by collecting elements from the stream                                             |
| [`Collect(Supplier, Accumulator, Finisher?)`](#Collect)        | `Any`       | Performs a mutable reduction on the elements in the stream                                          |
| [`Reduce(Combiner, Identity?)`](#Reduce)                       | `Any`       | Performs a reduction on the elements in the stream                                                  |
| [`Join(Delimiter := "", InitialCap := 0)`](#Join)              | `String`    | Concatenates elements of the stream into a single string                                            |
| [`JoinLine(InitialCap := 0)`](#JoinLine)                       | `String`    | Concatenates elements of the stream into a single string, separated by `\n`                         |
| [`static Generate(Supplier)`](#Generate)                       | `Stream`    | Returns a stream where each element is generated by `Supplier`                                      |
| [`static Iterate(Seed, Mapper)`](#Iterate)                     | `Stream`    | Returns a stream that repeatedly applies `Mapper` to generate the next value                        |

---

## Property Summary

| Property Name                                      | Property Type | Return Type | Description                                                     |
| -------------------------------------------------- | ------------- | ----------- | --------------------------------------------------------------- |
| [`static MaxSupportedParams`](#MaxSupportedParams) | `get`         | `Integer`   | Returns the maximum parameter length supported by streams (`4`) |

---

## Method Details

<a id="StreamArgSize"></a>

### `StreamArgSize(Function: Func) => Integer`

**Description**:

Calculates the parameter length of the stream that is returned when adding
an intermediate operation such as `.RetainIf()` to this stream.

A stream takes the longest possible parameter length it can, depending on how
many parameters `Function` accepts.

**Example**:

```ahk
IndexGreaterThan2(Index) {
    return (Index > 2)
}

Nums := Array(1, 2, 3, 4, 5).Stream(2)

; old stream: 2 params
; predicate:  1 param
; new stream: 1 param
Nums.StreamArgSize(IndexGreaterThan2)

; "3, 4, 5"
Nums.RetainIf(IndexGreaterThan2).Join(", ").MsgBox()
```

**Parameters**:

| Parameter Name | Type   | Description                               |
| -------------- | ------ | ----------------------------------------- |
| `Function`     | `Func` | Function that is used in stream operation |

**Return Value**:

- **Type**: `Integer`

---

<a id="RetainIf"></a>

### `RetainIf(Condition: Predicate) => Stream`

**Description**:

Returns a new stream that retains elements only if they match the given
predicate function `Condition`.

The parameter length of the new stream depends on the maximum supported
parameter length of `Condition`.

**Example**:

```ahk
Array(1, 2, 3, 4).Stream().RetainIf(x => x > 2) ; <3, 4>
```

**Parameters**:

| Parameter Name | Type        | Description                         |
| -------------- | ----------- | ----------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition |

**Return Value**:

- **Type**: `Stream`

---

<a id="RemoveIf"></a>

### `RemoveIf(Condition: Predicate) => Stream`

**Description**:

Returns a new stream that removes all elements which match the given predicate
function `Condition`.

The parameter length of the new stream depends on the maximum supported
parameter length of `Condition`.

**Example**:

```ahk
Array(1, 2, 3, 4).Stream().RemoveIf(x => x > 2) ; <1, 2>
```

**Parameters**:

| Parameter Name | Type        | Description                         |
| -------------- | ----------- | ----------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition |

**Return Value**:

- **Type**: `Stream`

---

<a id="Map"></a>

### `Map(Mapper: Func) => Stream`

**Description**:

Returns a new stream which transforms its elements by applying the given
`Mapper` function.

Streams returned by this method have a parameter length of 1.

**Example**:

```ahk
; <2, 4, 6, 8>
Array(1, 2, 3, 4).Stream().Map(x => x * 2)

; <[1, "foo"], [2, "bar"], [3, "baz"]>
Array("foo", "bar", "baz").Stream(2).Map(Array) 
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Mapper`       | `Func` | Function that returns a new element |

**Return Value**:

- **Type**: `Stream`

---

<a id="FlatMap"></a>

### `FlatMap(Mapper: Func) => Stream`

**Description**:

Returns a new stream which transforms its elements by applying the given
`Mapper` function, resulting arrays flattened into separate elements.

Streams returned by this method have a parameter length of 1.

**Example**:

```ahk
; <"f", "o", "o", "b", "a", "r">
Array("foo", "bar").Stream().FlatMap(StrSplit)

; <1, "foo", 2, "bar">
Array("foo", "bar").Stream(2).FlatMap(Array)
```

**Parameters**:

| Parameter Name | Type   | Description                                     |
| -------------- | ------ | ----------------------------------------------- |
| `Mapper`       | `Func` | Function that returns zero or more new elements |

**Return Value**:

- **Type**: `Stream`

---

<a id="MapByRef"></a>

### `MapByRef(Mapper: Func) => Stream`

**Description**:

Returns a new stream which mutates the current elements by reference, by
applying the given `Mapper` function.

The parameter length of the new stream remains the same.

**Example**:

```ahk
MutateValues(&Index, &Value) {
    ++Index
    Value .= "_"
}

; <[2, "foo_"], [3, "bar_"]>
Array("foo", "bar").Stream(2).MapByRef(MutateValues)
```

**Parameters**:

| Parameter Name | Type     | Description                                 |
| -------------- | -------- | ------------------------------------------- |
| `Func`         | `Mapper` | Function that mutates elements by reference |

**Return Value**:

- **Type**: `Stream`

---

<a id="FindFirst"></a>

### `FindFirst() => Stream`

**Description**:

Returns a new stream which is limited to its first element set. Note that this
operation is intermediate, which means that variables must be accessed by using
a for-loop or a terminal stream operation such as `.ForEach()`.

The parameter length of the new stream remains the same.

**Example**:

```ahk
Array(1, 2, 3, 4).Stream().RetainIf(x => x > 2).FindFirst() ; <3>
```

**Return Value**:

- **Type**: `Stream`

---

<a id="Limit"></a>

### `Limit(n: Integer) => Stream`

**Description**:

Returns a new stream that returns not more than `n` elements.

The parameter length of the new stream remains the same.

**Example**:

```ahk
Array(1, 2, 3, 4).Stream().Limit(2) ; <1, 2>
```

**Parameters**:

| Parameter Name | Type      | Description                               |
| -------------- | --------- | ----------------------------------------- |
| `n`            | `Integer` | Maximum amount of elements to be returned |

**Return Value**:

- **Type**: `Stream`

---

<a id="Skip"></a>

### `Skip(n: Integer) => Stream`

**Description**:

Returns a new stream that skips the first `x` elements.

The parameter length of the new stream remains the same.

**Example**:

```ahk
Array(1, 2, 3, 4).Stream().Skip(2) ; <3, 4>
```

**Parameters**:

| Parameter Name | Type      | Description                      |
| -------------- | --------- | -------------------------------- |
| `x`            | `Integer` | Amount of elements to be skipped |

**Return Value**:

- **Type**: `Stream`

---

<a id="TakeWhile"></a>

### `TakeWhile(Condition: Predicate) => Stream`

**Description**:

Returns a new stream which closes as soon as the given predicate function
`Condition` evaluates to `false`.

The parameter length of the new stream depends on the maximum supported
parameter length of `Condition`.

**Example**:

```ahk
Array(1, -2, 4, 6, 2, 1).Stream().TakeWhile(x => x < 5) ; <1, -2, 4>
```

**Parameters**:

| Parameter Name | Type        | Description                         |
| -------------- | ----------- | ----------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition |

**Return Value**:

- **Type**: `Stream`

---

<a id="DropWhile"></a>

### `DropWhile(Condition: Predicate) => Stream`

**Description**:

Returns a new stream which skips the first set of elements as long as the given
predicate function `Condition` evaluates to `true`.

**Example**:

```ahk
Array(1, 2, 3, 4, 2, 1).Stream().DropWhile(x => x < 3) ; <4, 2, 1>
```

**Parameters**:

| Parameter Name | Type        | Description                         |
| -------------- | ----------- | ----------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition |

**Return Value**:

- **Type**: `Stream`

---

<a id="Distinct"></a>

### `Distinct(CaseSenseOrHasher: Primitive/Func := true, CaseSense: Primitive?) => Stream`

**Description**:

Removes duplicate elements from the stream by using a `Map` object to track
previously seen keys. This method ensures that only unique elements remain
in the resulting stream.

The method determines behavior based on the type of the first parameter:

If a `Boolean` (`true` or `false`) or `String` (`"On"`, `"Off"` or `"Locale"`)
is provided as first parameter, it determines the case-sensitivity of the
internal `Map` used for equality checks.

If a function object is provided, it is treated as a custom `Hasher` for
generating keys. This is useful for comparing objects based on their values
instead of their identity.

A custom `Hasher` is required for supporting functions with a parameter length
greater than 1.

**Example**:

```ahk
Array(1, 2, 3, 1, 2, 3).Stream().Distinct()        ; <1, 2, 3>
Array("foo", "FOO", "Foo").Stream().Distinct(true) ; <"foo">

; <{ Value: 2 }, { Value: 3 }>
Array({ Value: 2 }, { Value: 2 }, { Value: 3 })
        .Stream().Distinct(Obj => Obj.Value)
```

**Parameters**:

| Parameter Name      | Type                     | Description                       |
| ------------------- | ------------------------ | --------------------------------- |
| `CaseSenseOrHasher` | `Primitive/Func := true` | Case-sensitivity or object hasher |
| `CaseSense`         | `Primitive?`             | Case-sensitivity                  |

**Return Value**:

- **Type**: `Stream`

---

<a id="Peek"></a>

### `Peek(Action: Func) => Stream`

**Description**:

Returns a new stream which applies the given function `Action` on every element
set as intermediate stream operation.

The parameter length of the new stream remains the same.

**Example**:

```ahk
Foo(Value) {
    MsgBox("Intermediate stream operation: " . Value)
}

Bar(Value) {
    MsgBox("Terminal stream operation: " . Value)
}

Array(1, 2, 3, 4).Stream().Peek(Foo).ForEach(Bar)
```

**Parameters**:

| Parameter Name | Type   | Description                              |
| -------------- | ------ | ---------------------------------------- |
| `Action`       | `Func` | The function to call on each element set |

**Return Value**:

- **Type**: `Stream`

---

<a id="ForEach"></a>

### `ForEach(Action: Func) => (none)`

**Description**:

Applies the given `Action` function on every element set as terminal stream
operation.

**Example**:

```ahk
Array(1, 2, 3, 4).Stream().ForEach(MsgBox)
```

**Parameters**:

| Parameter Name | Type   | Description                                  |
| -------------- | ------ | -------------------------------------------- |
| `Action`       | `Func` | The function to call on each set of elements |

**Return Value**:

- **Type**: (none)

---

<a id="AnyMatch"></a>

### `AnyMatch(Condition: Predicate, &Match: VarRef?) => Boolean`

**Description**:

Returns `true`, if this stream contains an element set which satisfies the
given predicate function `Condition`.

The first element that satisfies `Condition` is outputted into `&Match` in the
form of an array, if present.

**Example**:

```ahk
Array(1, 2, 3, 8, 4).Stream().AnyMatch(x => x < 5, &Output) ; true

Output.ToString() ; "[8]"
```

**Parameters**:

| Parameter Name | Type        | Description                         |
| -------------- | ----------- | ----------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition |
| `&Match`       | `VarRef?`   | First matching element set          |

**Return Value**:

- **Type**: `Boolean`

---

<a id="AllMatch"></a>

### `AllMatch(Condition: Predicate) => Boolean`

**Description**:

Returns `true`, if all elements sets in this stream satisfy the given predicate
function `Condition`.

**Example**:

```ahk
Array(1, 2, 3, 4).Stream().AllMatch(x => x < 10) ; true
```

**Parameters**:

| Parameter Name | Type        | Description                         |
| -------------- | ----------- | ----------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition |

**Return Value**:

- **Type**: `Boolean`

---

<a id="NoneMatch"></a>

### `NoneMatch(Condition: Predicate) => Boolean`

**Description**:

Returns `true`, if none of the  elements sets in this stream satisfy the given
predicate function `Condition`.

**Example**:

```ahk
Array(1, 2, 3, 4, 5, 92).Stream().AllMatch(x => x > 10) ; false
```

**Parameters**:

| Parameter Name | Type        | Description                         |
| -------------- | ----------- | ----------------------------------- |
| `Condition`    | `Predicate` | Function that evaluates a condition |

**Return Value**:

- **Type**: `Boolean`

---

<a id="Max"></a>

### `Max(Comparator: Comparator?) => Any`

**Description**:

Returns the highest element in this stream.

If a custom `Comparator` function is provided, it is used to determine the
ordering of elements; otherwise, numerical ordering is used.

If the stream is empty, this method throws an error.

Only the *first parameter* of each element set is considered for comparison. If
comparing beyond the the first parameter is required, use `.Map()` to
preprocess the stream, or use methods such as `.Reduce()` or `.ToArray().Max()`
instead.

**See**: `Comparator`

**Example**:

```ahk
Array(1, 2, 3, 4).Stream().Max()                   ; 4
Array("banana", "zigzag").Stream().Max(StrCompare) ; "zigzag"
```

**Parameters**:

| Parameter Name | Type          | Description                         |
| -------------- | ------------- | ----------------------------------- |
| `Comparator`   | `Comparator?` | Function that compares two elements |

**Return Value**:

- **Type**: `Any`

---

<a id="Min"></a>

### `Min(Comparator: Comparator?) => Any`

**Description**:

Returns the lowest element in this stream.

If a custom `Comparator` function is provided, it is used to determine the
ordering of elements; otherwise, numerical ordering is used.

If the stream is empty, this method throws an error.

Only the *first parameter* of each element set is considered for comparison. If
comparing beyond the the first parameter is required, use `.Map()` to preprocess
the stream, or use methods such as `.Reduce()` or `.ToArray().Min()` instead.

**Example**:

```ahk
Array(1, 2, 3, 4)                        ; 1
Array("banana", "zigzag").Stream().Max() ; "banana"
```

**Parameters**:

| Parameter Name | Type          | Description                         |
| -------------- | ------------- | ----------------------------------- |
| `Comparator`   | `Comparator?` | Function that compares two elements |

**Return Value**:

- **Type**: `Any`

---

<a id="Sum"></a>

### `Sum() => Float`

**Description**:

Returns the total sum of numbers in this stream. Unset and non-numerical values
are ignored. Only the first parameter of each element set is taken as argument.

**Example**:

```ahk
Array("foo", 3, "4", unset).Stream().Sum() ; 7
```

**Return Value**:

- **Type**: `Float`

---

<a id="ToArray"></a>

### `ToArray(n: Integer := 1) => Array`

**Description**:

Returns an array by collecting elements from this stream. The `n` parameter
specifies which parameter to extract from each element set in the stream.

**Example**:

```ahk
Array(1, 2, 3, 4).Stream().Map(x => x * 2).ToArray() ; [1, 2, 3, 4]
```

**Parameters**:

| Parameter Name | Type      | Description                               |
| -------------- | --------- | ----------------------------------------- |
| `n`            | `Integer` | Index of the parameter to push into array |

**Return Value**:

- **Type**: `Array`

---

<a id="Collect"></a>

### `Collect(Supplier: Func, Accumulator: Func, Finisher: Func?) => Array`

**Description**:

Performs a mutable reduction on the elements of this stream, using the given
`Supplier`, `Accumulator`, and optionally a `Finisher` function.

This method allows for highly customizable data collection into various types of
containers or final structures.

`Supplier` - a function or a class that provides a new, empty result container.

`Accumulator` - a function that adds an element to the result container.

`Finisher` - a function that transforms the final result container.

**Example**:

```ahk
; Map {
;     1 ==> "foo",
;     2 ==> "bar"
; }
MapObj := Array("foo", "bar").Stream(2).Collect(Map, Map.Prototype.Set)
```

**Parameters**:

| Parameter Name | Type    | Description                          |
| -------------- | ------- | ------------------------------------ |
| `Supplier`     | `Func`  | Supplies a container (e.g., `Array`) |
| `Accumulator`  | `Func`  | Adds elements to container           |
| `Finisher`     | `Func?` | Transforms container to final value  |

**Return Value**:

- **Type**: `Any`

---

<a id="Reduce"></a>

### `Reduce(Combiner: Combiner, Identity: Any?) => Any`

**Description**:

Performs a reduction on the elements of the stream, using the given
`Combiner` function. This method iteratively combines elements to produce
a single result, optionally starting with an `Identity` value.

`Combiner` - A function that combines two elements into a single result.

- The `Combiner` function is called repeatedly with the current result
  and the next element in the stream.
- The final result is the accumulated value after processing all of the
  elements.

`Identity` - An initial value for the reduction.

- If specified, this value is used as the starting value of the
  reduction.
- If omitted, the first element of the stream is used as the initial
  value, and reduction starts with the second element. An error is
  thrown, if the stream has no elements.

This method only operates on the *first parameter* of each element set
of the stream. To reduce over multiple parameters, preprocess the stream
using `.Map()`.

A particularly flexible way of capturing multiple parameters is by using
`.Map(Array)`:

```ahk
; <[1, "foo"], [2, "bar"], [3, "baz"]>
Array("foo", "bar", "baz").Stream(2).Map(Array)
```

**Example**:

```ahk
Product(a, b) {
    return a * b
}
Array(1, 2, unset, 3, unset, 4).Stream().Reduce(Product) ; 24
```

**Parameters**:

| Parameter Name | Type       | Description                         |
| -------------- | ---------- | ----------------------------------- |
| `Combiner`     | `Combiner` | Function that combines two elements |
| `Identity`     | `Any?`     | Initial starting value              |

**Return Value**:

- **Type**: `Any`

---

<a id="Join"></a>

### `Join(Delimiter: String := "", InitialCap: Integer := 0) => String`

Concatenates the elements of this stream into a single string, separated
by the specified `Delimiter`. The method converts objects to strings
using their `.ToString()` method.

`Delimiter` - Specifies the string used to separate elements in the resulting
string (default `""`).

`InitialCap` - Specifies the initial capacity of the resulting string (default
`0`). This can improve performance when working with large strings by
pre-allocating the necessary memory.

Only the *first parameter* of each element set is used. To customize this
behavior, preprocess this stream with `.Map()`.

**Example**:

```ahk
Array(1, 2, 3, 4).Stream().Join() ; "1234"
```

**Parameters**:

| Parameter Name | Type           | Description             |
| -------------- | -------------- | ----------------------- |
| `Delimiter`    | `String := ""` | Separator string        |
| `InitialCap`   | `Integer := 0` | Initial string capacity |

**Return Value**:

- **Type**: `String`

---

<a id="JoinLine"></a>

### `JoinLine() => String`

**Description**:

Concatenates the elements of this stream into a single string, each element
separated by `\n`

**Example**:

```ahk
; 1
; 2
; 3
Array(1, 2, 3).Stream().JoinLine()
```

**Parameters**:

| Parameter Name | Type           | Description             |
| -------------- | -------------- | ----------------------- |
| `InitialCap`   | `Integer := 0` | Initial string capacity |

**Return Value**:

- **Type**: `String`

---

<a id="Generate"></a>

### `Generate(Supplier: Func) => Stream`

**Description**:

Returns a stream where each element is produced by the given supplier function.
The stream is infinite unless filtered or limited with other methods.

**Example**:

```ahk
; <4, 6, 1, 8, 2, 7>
Stream.Generate(() => Random(0, 9)).Limit(6).ToArray()
```

**Parameters**:

| Parameter Name | Type   | Description                            |
| -------------- | ------ | -------------------------------------- |
| `Supplier`     | `Func` | Function that supplies stream elements |

**Return Value**:

- **Type**: `Stream`

---

<a id="Iterate"></a>

### `Iterate(Seed: Any, Mapper: Func) => Stream`

**Description**:

Creates a stream where each element is the result of applying `Mapper` to
the previous one, starting from `Seed`.

The stream is infinite unless filtered or limited with other methods.

**Example**:

```ahk
; <0, 2, 4, 6, 8, 10>
Stream.Iterate(0, x => (x + 2)).Take(6).ToArray()
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Seed`         | `Any`  | Starting value of the stream      |
| `Mapper`       | `Func` | Function that computes next value |

**Return Value**:

- **Type**: `Stream`

---

## Property Details

<a id="MaxSupportedParams"></a>

### `static MaxSupportedParams => Integer`

**Description**:

Returns the maximum parameter length supported by streams (`4`).

**Property Type**: `get`

**Return Value**:

- **Type**: `Integer`
