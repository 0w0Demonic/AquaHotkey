# Func

## Method Summary

| Method Name                                                    | Return Type | Description                                                                                         |
| -------------------------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------- |
| [`__(Args*)`](#__)                                             | `BoundFunc` | Convenience method for function binding                                                             |
| [`AndThen(Other, NextArgs*)`](#AndThen)                        | `Func`      | Composes a function that first calls this function and then `Other`                                 |
| [`Compose(Other, NextArgs*)`](#Compose)                        | `Func`      | Composes a function that first calls `Other` and then this function                                 |
| [`And(Other)`](#And)                                           | `Predicate` | Returns a logical AND of this predicate and `Other`                                                 |
| [`AndNot(Other)`](#AndNot)                                     | `Predicate` | Returns a logical AND NOT of this predicate and `Other`                                             |
| [`Or(Other)`](#Or)                                             | `Predicate` | Returns a logical OR of this predicate and `Other`                                                  |
| [`OrNot(Other)`](#OrNot)                                       | `Predicate` | Returns a logical OR NOT of this predicate and `Other`                                              |
| [`Negate()`](#Negate)                                          | `Predicate` | Returns a negation of this predicate                                                                |
| [`static Tee(First, Second, Combiner?)`](#Tee)                 | `Func`      | Returns a function that calls `First` and `Second`, optionally merging both results with `Combiner` |
| [`Memoized(CaseSenseOrHasher := true, CaseSense?)`](#Memoized) | `Func`      | Returns a memoized version of this function                                                         |

---

## Property Summary

| Property Name               | Property Type | Return Type | Description                                                     |
| --------------------------- | ------------- | ----------- | --------------------------------------------------------------- |
| [`IsMemoized`](#IsMemoized) | `get`         | `Boolean`   | Returns `true`, if this function is memoized                    |

---

## Method Details

<a id="__"></a>

### `__(Args: Any*) => BoundFunc`

**Description**:

Provides a shorthand for function binding, with behavior that adapts depending
on the type of the function it is applied to. This method simplifies common
binding patterns for functions in global/local scope, static methods and
non-static methods.

For regular functions and static methods, this method starts binding arguments
from the *second* parameter, leaving the first parameter untouched.

```ahk
ContainsLetterF := InStr.__("F") ; InStr.Bind(unset, "H")
ContainsLetterF("Foo")           ; InStr("Foo", "F")

class MyClass {
    static MyMethod(Args*) {
        ; ...
    }
}
Method := MyClass.MyMethod.__(Arg1, Arg2)
Method("foo") ; MyClass.MyMethod("foo", Arg1, Arg2)
```

For non-static methods, this method binds arguments from the *first* parameter,
leaving out the `this`-parameter referring to the object instance.

```ahk
class MyClass {
    MyMethod(Args*) {
        ; ...
    }
}
Method   := MyClass.Method.__(Arg1, Arg2)
Instance := MyClass() ; create a new object
Method(Instance)      ; Instance.Method(Arg1, Arg2)
```

**Example**:

```ahk
ContainsLetterH := InStr.__("H") ; InStr.Bind(unset, "H")
ContainsLetterH("Hello, world!") ; true
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Args`         | `Any*` | Zero or more additional arguments |

**Return Value**:

- **Type**: `BoundFunc`

**Remarks**:

This method relies on the `Name` property to determine whether this function is
a regular function, static method or non-static method (its name is being
searched for strings `.` and `.Prototype.`).
When dynamically creating new methods, they must be named according to the
standard convention of AutoHotkey functions.

```ahk
MyStaticMethod.DefineConstant("Name", "MyClass.MyMethod")
MyNonStaticMethod.DefineConstant("Name", "MyClass.Prototype.MyMethod")
```

---

<a id="AndThen"></a>

### `AndThen(After, NextArgs*) => Func`

**Description**:

Returns a composed function that first applies this function with the given
input, and then forwards the result to `After`, followed by zero or more
additional arguments `NextArgs*`.

**Example**:

```ahk
TimesTwo(x) {
    return x * 2
}
PlusFive(x) {
    return x + 5
}
TimesTwoPlusFive := TimesTwo.AndThen(PlusFive)
TimesTwoPlusFive(3) ; 11
```

**Parameters**:

| Parameter Name | Type   | Description                          |
| -------------- | ------ | ------------------------------------ |
| `After`        | `Func` | Function to call after this function |
| `NextArgs`     | `Any*` | Zero or more additional arguments    |

**Return Value**:

- **Type**: `Func`

---

<a id="Compose"></a>

### `Compose(Before, NextArgs*) => Func`

**Description**:

Returns a composed function that first applies `Before` with the given input,
and then forwards the result to this function as first parameter, followed by
zero or more additional arguments `NextArgs*`.

**Example**:

```ahk
TimesTwo(x) {
    return x * 2
}
PlusFive(x) {
    return x + 5
}
PlusFiveTimesTwo := TimesTwo.Compose(PlusFive)
PlusFiveTimesTwo(3) ; 16
```

**Parameters**:

| Parameter Name | Type   | Description                            |
| -------------- | ------ | -------------------------------------- |
| `Before`       | `Func` | Function to apply before this function |
| `NextArgs`     | `Any*` | Zero or more additional arguments      |

**Return Value**:

- **Type**: `Func`

---

<a id="And"></a>

### `And(Other: Func) => Predicate`

**Description**:

Returns a predicate function that represents a logical AND of this function
and `Other`. The resulting predicate short-circuits, if the first expression
evaluates to `false`.

**Example**:

```ahk
GreaterThan5(x) {
    return (x > 5)
}
LessThan100(x) {
    return (x < 100)
}
Condition := GreaterThan5.And(LessThan100)
Condition(23) ; true
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Other`        | `Func` | Function that evaluates a condition |

**Return Value**:

- **Type**: `Predicate`

---

<a id="AndNot"></a>

### `AndNot(Other: Func) => Predicate`

**Description**:

Returns a predicate function that represents a logical AND NOT of this function
and `Other`. The resulting predicate short-circuits, if the first expression
evaluates to `false`.

**Example**:

```ahk
GreaterThan5(x) {
    return (x > 5)
}
GreaterThan100(x) {
    return (x > 100)
}
Condition := GreaterThan5.AndNot(GreaterThan100)
Condition(56) ; true
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Other`        | `Func` | Function that evaluates a condition |

**Return Value**:

- **Type**: `Predicate`

---

<a id="Or"></a>

### `Or(Other: Func) => Predicate`

**Description**:

Returns a predicate function that represents a logical OR of this function
and `Other`. The resulting predicate short-circuits, if the first expression
evaluates to `true`.

**Example**:

```ahk
GreaterThan5(x) {
    return (x > 5)
}
EqualsOne(x) {
    return (x < 100)
}

Condition := GreaterThan5.Or(EqualsOne)
Condition(1) ; true
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Other`        | `Func` | Function that evaluates a condition |

**Return Value**:

- **Type**: `Predicate`

---

<a id="OrNot"></a>

### `OrNot(Other: Func) => Predicate`

**Description**:

Returns a predicate function that represents a logical OR NOT of this function
and `Other`. The resulting predicate short-circuits, if the first expression
evaluates to `true`.

**Example**:

```ahk
GreaterThan5(x) {
    return (x > 5)
}
GreaterThan0(x) {
    return (x > 0)
}

Condition := GreaterThan5.OrNot(GreaterThan0)
Condition(-3) ; true
```

**Parameters**:

| Parameter Name | Type   | Description                         |
| -------------- | ------ | ----------------------------------- |
| `Other`        | `Func` | Function that evaluates a condition |

**Return Value**:

- **Type**: `Predicate`

---

<a id="Negate"></a>

### `Negate() => Predicate`

**Description**:

Returns a predicate that represents a negation of this predicate.

**Example**:

```ahk
IsAdult(Person) {
    return (Person.Age >= 18)
}
IsNotAdult := IsAdult.Negate()

IsNotAdult({ Age: 17 }) ; true
```

**Return Value**:

- **Type**: `Predicate`

---

<a id="Tee"></a>

### `static Tee(First: Func, Second: Func, Combiner: Combiner?) => Func`

**Description**:

Returns a composed function which applies its input to two functions `First`
and `Second`, optionally merging both results using a function `Combiner`.

**Example**:

```ahk
Sum(Values*) {
    ; ...
}

Average(Values*) {
    ; ...
}

FormatResult(Sum, Average) {
    return Format("Sum: {}, Average: {}", Sum, Average)
}

SumAndAverage := Func.Tee(Sum, Average, FormatResult)
SumAndAverage(1, 2, 3, 4) ; "Sum: 10, Average: 2.5"
```

**Parameters**:

| Parameter Name | Type    | Description                        |
| -------------- | ------- | ---------------------------------- |
| `First`        | `Func`  | The first function to call         |
| `Second`       | `Func`  | The second function to call        |
| `Combiner`     | `Func?` | Function that combines two results |

**Return Value**:

- **Type**: `Func`

---

<a id="Memoized"></a>

### `Memoized(CaseSenseOrHasher: Primitive/Func := true, CaseSense: Primitive?) => Func`

**Description**:

Returns a memoized version of this function, caching previously computed results
in a `Map` object instead of calculating a result on every call.

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
Fibonacci(x) {
    if (x > 1) {
        ; Important:
        ;   Recursive calls must also call the memoized version of this
        ;   function, otherwise only the result for input `80` is cached!
        return Fibonacci(x - 2) + Fibonacci(x - 1)
    }
    return 1
}
FibonacciMemo := Fibonacci.Memoized()
FibonacciMemo(80) ; 23416728348467685
```

**Parameters**:

| Parameter Name         | Type                     | Description                            |
| ---------------------- | ------------------------ | -------------------------------------- |
| `CaseSenseOrHasher`    | `Primitive/Func := true` | Case-sensitivity or object hasher      |
| `CaseSense`            | `Primitive?`             | Case-sensitivity                       |

**Return Value**:

- **Type**: `Func`

---

<a id="ToString"></a>

### `ToString() => String`

**Description**:

Returns a string representation of this function object.

**Example**:

```ahk
MsgBox.ToString() ; "Func MsgBox"
```

**Return Value**:

- **Type**: `String`

---

## Property Details

<a id="IsMemoized"></a>

### `IsMemoized => Boolean`

**Description**:

Returns `true`, if this function is memoized.

**Property Type**: `get`

**Return Value**:

- **Type**: `Boolean`
