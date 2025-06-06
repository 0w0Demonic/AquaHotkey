# Class

## Method Summary

| Method Name                                      | Return Type | Description                                               |
| ------------------------------------------------ | ----------- | --------------------------------------------------------- |
| [`__Call(MethodName, Args)`](#__Call)            | (none)      | Override of `Any.Prototype.__Call()` that throws an error |
| [`static ForName(ClassName) => Class`](#ForName) | `Class`     | Returns a class named `ClassName`                         |
| [`ToString() => String`](#ToString)              | `String`    | Returns this class expressed as a string                  |

## Method Details

<a id="__Call"></a>

### `__Call(MethodName: String, Parameters: Any*) => (none)`

**Description**:

This method is an override of AquaHotkey's
[function chaining method](./about-function-chaining.md) which prevents
this feature when working with class objects and throws a `MethodError`.

**Example**:

```ahk
Foo(Value) {
    MsgBox(Type(Value))
}

String.Foo(Value) ; Error!
```

**Parameters**:

| Parameter Name | Type     | Description                       |
| -------------- | -------- | --------------------------------- |
| `MethodName`   | `String` | The name of the undefined method  |
| `Args`         | `Array`  | Zero or more additional arguments |

**Return Value**:

- **Type**: (none)

---

<a id ="ForName"></a>

### `ForName(ClassName: String) => Class`

**Description**:

Returns the class with the name of `ClassName`.

**Example**:

```ahk
class Foo {
    class Bar {
        static Baz() {
            MsgBox("Hello, world!")
        }
    }
}

FooBarClass := Class.ForName("Foo.Bar")
```

**Parameters**:

| Parameter Name | Type     | Description                       |
| -------------- | -------- | --------------------------------- |
| `ClassName`    | `String` | Name of a class                   |
| `Args`         | `Array`  | Zero or more additional arguments |

**Return Value**:

- **Type**: (none)

---

<a id="ToString"></a>

### `ToString() => String`

**Description**:

Returns this class expressed as a string.

**Example**:

```ahk
Gui.ToString() ; "Class Gui"
```

**Return Value**:

- **Type**: `String`
