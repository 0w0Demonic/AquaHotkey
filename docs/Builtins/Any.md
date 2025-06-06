# Any

## Method Summary

| Method Name                                                    | Return Type  | Description                                                           |
| -------------------------------------------------------------- | ------------ | --------------------------------------------------------------------- |
| [`__Call(FunctionName, Args)`](#__Call)                        | `Any`        | Forwards this variable to function `%FunctionName%`                   |
| [`o0(Callback, Args*)`](#o0)                                   | `Any`        | Forwards this variable to function `Callback`                         |
| [`BindMethod(MethodName, Args*)`](#BindMethod)                 | `BoundFunc`  | Equivalent to `ObjBindMethod()`                                       |
| [`Store(&Output)`](#Store)                                     | `this`       | Stores a clone of the current value in  `Output`                      |
| [`Is(T)`](#Is)                                                 | `Boolean`    | Equivalent to the `is`-keyword                                        |
| [`Stream(ArgLength := 1)`](#Stream)                            | `Enumerator` | Returns a function stream with this variable as source                |
| [`Optional()`](#Optional)                                      | `Optional`   | Returns an `Optional` with the value of this variable                 |
| [`AssertType(T, Msg?)`](#AssertType)                           | `this`       | Asserts that this variable is derived from class `T`                  |
| [`AssertNumber(Msg?)`](#AssertNumber)                          | `Number`     | Asserts that this variable is a number or numeric string              |
| [`AssertInteger(Msg?)`](#AssertInteger)                        | `Integer`    | Asserts that this variable is an integer or a whole number string     |
| [`AssertCallable(n?, Msg?)`](#AssertCallable)                  | `this`       | Asserts that this variable is callable                                |
| [`AssertEquals(Other, Msg?)`](#AssertEquals)                   | `this`       | Asserts that this variable is equal to `Other` (case-insensitive)     |
| [`AssertStrictEquals(Other, Msg?)`](#AssertStrictEquals)       | `this`       | Asserts that this variable is equal to `Other` (case-sensitive)       |
| [`AssertNotEquals(Other, Msg?)`](#AssertNotEquals)             | `this`       | Asserts that this variable is not equal to `Other` (case-insensitive) |
| [`AssertStrictNotEquals(Other, Msg?)`](#AssertStrictNotEquals) | `this`       | Asserts that this variable is not equal to `Other` (case-sensitive)   |

---

## Property Summary

| Property Name     | Property Type | Return Type  | Description                                 |
| ----------------- | ------------- | ------------ | ------------------------------------------- |
| [`Type`](#Type)   | `get`         | `String`     | Equivalent to `Type(this)`                  |
| [`Class`](#Class) | `get`         | `Class`      | Returns the type of this variable as class  |

---

## Method Details

<a id="__Call"></a>

### `__Call(FunctionName: String, Args: Array) => Any`

**Description**:

AquaHotkey's implicit function chaining. When a variable calls
an undefined variable `FunctionName`, it is forwarded to a global function
object `%FunctionName%`, followed by zero or more optional arguments `Args*`.

This new syntax allows for very elegant and streamlined function chains,
avoiding nested functions.

**See**:
[Function chaining](./about-function-chaining.md)

**Example**:

```ahk
Foo(Value, Arg2) {

}

Bar(Value) {

}

Baz(Value) {

}

; Foo(Bar(Baz("Hello, world!")), 42)
"Hello, world!".Baz().Bar().Foo(42)
```

**Parameters**:

| Parameter Name | Type       | Description                       |
| -------------- | ---------- | --------------------------------- |
| `FunctionName` | `String`   | Name of the undefined property    |
| `Args`         | `Array`    | Zero or more additional arguments |

**Return Value**:

- **Type**: `Any`

This method returns the result of the global function `%FunctionName%`.

---

<a id="o0"></a>

### `o0(Callback: Func, Args: Any*) => Any`

**Description**:

AquaHotkey explicit function chaining. This method forwards this variable to
function `Callback`, following by zero or more arguments `Args*`.

**See**:
[Function chaining](./about-function-chaining.md)

**Example**:

```ahk
; MsgBox("Foo", "Title")
"Foo".o0(MsgBox, "Title")
```

This method is a more explicit version of `Any.Prototype.__Call()` and allows
the use of methods and local functions.

```ahk
Outer(Value) {
    static Inner(Arg1, Arg2) {
        Arg1 . ", " . Arg2
    }
    
    return Value.o0(Inner, "bar")
}

Outer("foo") ; "foo, bar"
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Callback`     | `Func` | A function object to call         |
| `Args`         | `Any*` | Zero or more additional arguments |

**Return Value**:

- **Type**: `Any`

This method returns the result of `Callback()`

**Remarks**:

- This method relies the the `Name` property of the `Callback` function to
  identify them as functions, static or non-static methods:

```ahk
Foo(Args*) {

}

class MyClass {
    static Bar(Args*) {

    }

    Baz(Args*) {

    }    
}

MsgBox(Foo.Name)           ; "Foo"
MsgBox(MyClass.Bar.Name)   ; "MyClass.Bar"
MsgBox(MyClass().Baz.Name) ; "MyClass.Prototype.Baz"
```

---

<a id="BindMethod"></a>

### `BindMethod(MethodName: String, Args: Any*) => BoundFunc`

**Description**:

This method is equivalent to `ObjBindMethod()` and binds a method to this
variable.

**Example**:

```ahk
Arr := []
PushToArr := Arr.BindMethod("Push")

PushToArr("foo")
MsgBox(Arr[1]) ; "foo"
```

**Parameters**:

| Parameter Name | Type     | Description                       |
| -------------- | -------- | --------------------------------- |
| `MethodName`   | `String` | Any method name                   |
| `Args`         | `Any*`   | Zero or more additional arguments |

**Return Value**:

- **Type**: `BoundFunc`

This method creates a `BoundFunc` which calls method `MethodName`.

<a id="Store"></a>

### `Store(&Output: VarRef) => this`

**Description**:

Stores a copy of this variable in `&Output`. If the variable is an
object, its implementation of `Clone()` is used to create a copy of
the variable.

**Example**:

```ahk
Arr := Array(2, 3, 4, "foo")
Arr.Store(&Copy)
Arr.Pop()

Arr.Join(", ").MsgBox()  ; "2, 3, 4"
Copy.Join(", ").MsgBox() ; "2, 3, 4, foo"
```

**Parameters**:

| Parameter Name | Type     | Description         |
| -------------- | -------- | ------------------- |
| `Output`       | `VarRef` | The output variable |

**Return Value**:

- **Type**: `this`

<a id="Is"></a>

---

### `Is(T: Class) => Boolean`

**Description**:

Returns `true`, if this variable derives from class `T`. This method
is equivalent to the `is`-keyword.

**Example**:

```ahk
Arr := Array()
Arr.Is(Object) ; true
```

**Parameters**:

| Parameter Name | Type    | Description      |
| -------------- | ------- | ---------------- |
| `T`            | `Class` | Any class object |

---

<a id="Stream"></a>

### `Stream(n: Integer := 1) => Stream`

**Description**:

Returns a functional stream with this variable as source, either by
using its `__Enum()` or `Call()` method.

**See**:

[Using Stream](./../Extensions/Stream.md)

**Example**:

```ahk
Array(23, "foo", "bar").Stream(2) ; for Index, Value in Array ...
```

**Parameters**:

| Parameter Name | Type           | Description                 |
| -------------- | -------------- | --------------------------- |
| `n`            | `Integer := 1` | Argument size of the stream |

**Return Value**:

- **Type**: `Stream`

**Remarks**:

---

<a id="Optional"></a>

### `Optional() => Optional`

**Description**:

Returns an `Optional` that wraps around this variable.

**Example**:

```ahk
Opt := "Hello, world!".Optional()
```

**Return Value**:

- **Type**: `Optional`

---

<a id="AssertType"></a>

### `AssertType(T: Class, Msg: String?) => this`

**Description**:

Asserts that this variable is derived from class `T`. Otherwise, a `TypeError`
is thrown with the specified error message `Msg`.

**Example**:

```ahk
MyVar := "str"
MyVar.AssertType(String)
MyVar.AssertType(Buffer, "this variable is not a buffer!") ; Error!
```

**Parameters**:

| Parameter Name | Type      | Desciption       |
| -------------- | --------- | ---------------- |
| `T`            | `Class`   | Any class object |
| `Msg`          | `String?` | Error message    |

**Return Value**:

- **Type**: `this`

---

<a id="AssertNumber"></a>

### `AssertNumber(Msg: String?) => Number`

**Description**:

Asserts that this variable is a number or a numeric string. Otherwise, a
`TypeError` is thrown with the specified error message `Msg`.

**Example**:

```ahk
Str := "45.2"
Num := 123
Obj := Object()

Str.AssertNumber() ; 45.2 (converted to `Float`)
Num.AssertNumber() ; 123
Obj.AssertNumber() ; Error!
```

**Parameters**:

| Parameter Name | Type      | Description   |
| -------------- | --------- | ------------- |
| `Msg`          | `String?` | Error message |

**Return Value**:

- **Type**: `Number` - this variable as `Integer` or `Float`

---

<a id="AssertInteger"></a>

### `AssertInteger(Msg: String?) => Integer`

**Description**:

Asserts that this variable is an integer or a whole number string. Otherwise, a
`TypeError` is thrown with the specified error message `Msg`.

**Example**:

```ahk
x := 456
y := 12.2
z := "23"

x.AssertInteger() ; 456
y.AssertInteger() ; Error!
z.AssertInteger() ; 23 (converted to `Integer`)
```

**Parameters**:

| Parameter Name | Type      | Description   |
| -------------- | --------- | ------------- |
| `Msg`          | `String?` | Error message |

**Return Value**:

- **Type**: `Integer` - this variable as `Integer`

---

<a id="AssertCallable"></a>

### `AssertCallable(n: Integer?, Msg: String?) => this`

**Description**:

Asserts that this variable is callable with `n` parameters. Otherwise, a
`TypeError` is thrown with the specified error message `Msg`.

**Example**:

```ahk
MsgBox.AssertCallable()

; callable object
; 1-parameter method (`this` is ignored)
Obj := {
    Call: (this, Value) => SubStr(Value, 1, 1)
}

Obj.AssertCallable(1)

"foo".AssertCallable() ; Error!
```

**Parameters**:

| Parameter Name | Type       | Description      |
| -------------- | ---------- | ---------------- |
| `n`            | `Integer?` | Parameter length |
| `Msg`          | `String?`  | Error message    |

**Return Value**:

- **Type**: `this`

**Remarks**:

The assertion relies on the `MaxParams`, `MinParams` and `IsVariadic` properties
of a function to check for parameter length, which are not correctly implemented
by `BoundFunc` objects. Users should define these properties correctly or omit
parameter `n`.

---

<a id="AssertEquals"></a>

### `AssertEquals(Other: Any, Msg: String?) => this`

**Description**:

Asserts that this variable is equal to `Other` (case-insensitive). Otherwise,
a `ValueError` is thrown with the specified error message `Msg`.

**Example**:

```ahk
Num := 42
Num.AssertEquals(42)

Num.AssertEquals("42") ; (42 = "42")
Num.AssertEquals(43)   ; Error!
```

**Parameters**:

| Parameter Name | Type      | Description   |
| -------------- | --------- | ------------- |
| `Other`        | `Any`     | Any value     |
| `Msg`          | `String?` | Error message |

**Return Value**:

- **Type**: `this`

---

<a id="AssertStrictEquals"></a>

### `AssertStrictEquals(Other: Any, Msg: String) => this`

**Description**:

Asserts that this variable is equal to `Other` (case-sensitive). Otherwise, a
`ValueError` is thrown with the specified error message `Msg`.

**Example**:

```ahk
Num := 42
Num.AssertStrictEquals("42")

Str := "foo"
Str.AssertStrictEquals("foo")
Str.AssertStrictEquals("FOO") ; Error!
```

**Parameters**:

| Parameter Name | Type      | Description   |
| -------------- | --------- | ------------- |
| `Other`        | `Any`     | Any value     |
| `Msg`          | `String?` | Error message |

**Return Value**:

- **Type**: `this`

---

<a id="AssertNotEquals"></a>

### `AssertNotEquals(Other: Any, Msg: String?) => this`

**Description**:

Asserts that this variable is not equal to `Other` (case-insentitive).
Otherwise, a `ValueError` is thrown with the specified error message `Msg`.

**Example**:

```ahk
Num := 42

Num.AssertNotEquals(0)
Num.AssertNotEquals(42)   ; Error!
Num.AssertNotEquals("42") ; Error!
```

**Parameters**:

| Parameter Name | Type      | Description   |
| -------------- | --------- | ------------- |
| `Other`        | `Any`     | Any value     |
| `Msg`          | `String?` | Error message |

**Return Value**:

- **Type**: `this`

---

<a id="AssertStrictNotEquals"></a>

### `AssertStrictNotEquals(Other: Any, Msg: String?) => this`

**Description**:

Asserts that this variable is not equal to `Other` (case-sensitive).
Otherwise, a `ValueError` is thrown with the specified error message `Msg`.

**Example**:

```ahk
Str := "foo"
Str.AssertStrictNotEquals("FOO")
Str.AssertStrictNotEquals("foo") ; Error!
```

**Parameters**:

| Parameter Name | Type      | Description   |
| -------------- | --------- | ------------- |
| `Other`        | `Any`     | Any value     |
| `Msg`          | `String?` | Error message |

**Return Value**:

- **Type**: `this`

---

## Property Details

<a id="Type"></a>

### `Type => String`

**Description**: Equivalent to `Type()`.

**Property Type**: `get`

**Example**:

```ahk
"foo".Type ; "String"
123.Type   ; "Integer"
```

**Return Value**:

- **Type**: `String`

---

<a id="Class"></a>

### `Class => Class`

**Description**: Returns the type of this variable as class.

**Property Type**: `get`

**Example**:

```ahk
"foo".Class ; String
```

**Return Value**:

- **Type**: `Class`
