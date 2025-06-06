# Object

## Method Summary

| Method Name                                                               | Return Type | Description                                              |
| ------------------------------------------------------------------------- | ----------- | -------------------------------------------------------- |
| [`DefineConstant(PropertyName, Value) => Any`](#DefineConstant)           | `Any`       | Defines a read-only property with a fixed value          |
| [`DefineGetter(PropertyName, Getter) => this`](#DefineGetter)             | `this`      | Defines a property with a custom getter function         |
| [`DefineGetterSetter(PropertyName, Getter, Setter)`](#DefineGetterSetter) | `this`      | Defines a property with both getter and setter functions |
| [`DefineSetter(PropertyName, Setter) => this`](#DefineSetter)             | `this`      | Defines a property with a custom setter function         |
| [`DefineMethod(PropertyName, Method) => this`](#DefineMethod)             | `this`      | Defines a method callable via the property name          |
| [`SetBase(BaseObj)`](#SetBase)                                            | `this`      | Sets the base of this object                             |
| [`ToString() => String`](#ToString)                                       | `String`    | Returns a string representation of this object           |

---

## Method Details

<a id="DefineConstant"></a>

### `DefineConstant(PropertyName: String, Value: Any) => Any`

**Description**:

Defines a new read-only property by the name of `PropertyName`, which returns a constant `Value`.

This method is useful for lazily initializing properties.

**Example**:

```ahk
class Foo {
    ; this property is lazily initialized
    static Bar {
        Get {
            ; do something here...
            Sleep(2000)
            ; next time, return `Result` instantly
            this.DefineConstant("Bar", 42)
        }
    }
}

MsgBox(Foo.Bar) ; (2 seconds later...) 42
MsgBox(Foo.Bar) ; 42
```

**Parameters**:

| Parameter Name | Type     | Description                             |
| -------------- | -------- | --------------------------------------- |
| `PropertyName` | `String` | Name of the new property                |
| `Value`        | `Any`    | Value that is returned by this property |

**Return Value**:

- **Type**: `Any`
- To be able to lazily initialize properties, this method returns `Value`.

---

<a id="DefineGetter"></a>

### `DefineGetter(PropertyName: String, Getter: Func) => this`

**Description**:

Defines a new read-only property by the name of `PropertyName`.

The `Getter` function determines the value of the property when accessed.

**Example**:

```ahk
TwoTimesValue(this) {
    return this.Value * 2
}

Obj := { Value: 3 }
Obj.DefineGetter("TwoTimesValue", TwoTimesValue)

MsgBox(Obj.TwoTimesValue) ; 6
```

**Parameters**:

| Parameter Name | Type     | Description              |
| -------------- | -------- | ------------------------ |
| `PropertyName` | `String` | Name of the new property |
| `Getter`       | `Func`   | Property getter function |

**Return Value**:

- **Type**: `this`

---

<a id="DefineGetterSetter"></a>

### `DefineGetterSetter(PropertyName: String, Getter: Func, Setter: Func) => this`

**Description**:

Defines a new property by the name of `PropertyName`.

The `Getter` function determines the value of the property when accessed whereas `Setter` is executed whenever the property is being assigned a value.

**Example**:

```ahk
Getter(this) {
    ++this.Count
    return this.Value
}

Setter(this, Value) {
    ++this.Count
    return this.Value := Value
}

Obj := ({ Count: 0 }).DefineGetterSetter("Foo", Getter, Setter)

Obj.Foo := 3      ; calls `Setter` (Count: 1)
MsgBox(Obj.Foo)   ; calls `Getter` (Count: 2)
MsgBox(Obj.Count) ; 2
```

**Parameters**:

| Parameter Name | Type     | Description              |
| -------------- | -------- | ------------------------ |
| `PropertyName` | `String` | Name of the new property |
| `Getter`       | `Func`   | Property getter function |
| `Setter`       | `Func`   | Property setter function |

**Return Value**:

- **Type**: `this`

---

<a id="DefineSetter"></a>

### `DefineSetter(PropertyName: String, Setter: Func) => this`

**Description**:

Defines a new property by the name of `PropertyName`.

The `Setter` function is executed whenever the property is being assigned a value.

**Example**:

```ahk
Setter(this, Value) {
    return this.Value := Value.AssertInteger("only integers allowed")
}

Obj     := ({ Value: 42 }).DefineSetter("Foo", Setter)
Obj.Foo := 2
Obj.Bar := "bar" ; Error!
```

**Parameters**:

| Parameter Name | Type     | Description              |
| -------------- | -------- | ------------------------ |
| `PropertyName` | `String` | Name of the new property |
| `Setter`       | `Func`   | Property setter function |

**Return Value**:

- **Type**: `this`

---

<a id="DefineMethod"></a>

### `DefineMethod(PropertyName: String, Method: Func) => this`

**Description**:

Defines a new method by the name of `PropertyName`.

`Method` is the function invoked when this property is called like a method.

**Example**:

```ahk
PrintValue(this) {
    MsgBox(this.Value)
}

Obj := ({ Value: 42 }).DefineMethod("PrintValue", PrintValue)
Obj.PrintValue()
```

**Parameters**:

| Parameter Name | Type     | Description                                             |
| -------------- | -------- | ------------------------------------------------------- |
| `PropertyName` | `String` | Name of the new property                                |
| `Method`       | `Func`   | The function to be invoked when this property is called |

**Return Value**:

- **Type**: `this`

---

<a id="SetBase"></a>

### `SetBase(BaseObj: Any) => this`

**Description**:

Sets the base of this object.

**Example**:

```ahk
class Foo {

}

Obj := Object().SetBase(Foo.Prototype)
MsgBox(Obj is Foo) ; true
```

**Parameters**:

| Parameter Name | Type  | Description                 |
| -------------- | ----- | --------------------------- |
| `BaseObj`      | `Any` | The new base of this object |

**Return Value**:

- **Type**: `this`

---

<a id="ToString"></a>

### `ToString() => String`

**Description**:

Returns a string representation of this object.

To create a string, this method tries to use the following approaches in order:

#### 1. Using a 2-parameter for-loop

- **Syntax**:
  - `(Type) { Key1: Value1, Key2: Value2, ..., KeyN: ValueN }`
- **Example**:
  - `Map { "foo": "bar" }`

#### 2. Using a 1-parameter for-loop

- **Syntax**:
  - `(Type) { Value1, Value2, Value3, ..., ValueN }`
- **Example**:
  - `Array { 1, 2, 3, 4, "5", unset }`

#### 3. Using the objects own properties `.OwnProps()`

- **Syntax**:
  - `(Type) { PropName1: PropValue1, ... }`
- **Example**:
  - `Object { Foo: "bar", ... }`

#### 4. Only the type is returned

- **Syntax**:
  - `(Type)`
- **Example**:
  - `Gui`

**Example**:

```ahk
Object().ToString()         ; 'Object'

({ foo: "bar" }).ToString() ; 'Object { foo: "bar" }'
```

**Remarks**:

`String(Obj)` implicitly calls this method on the given object `Obj`.

Using `String` as a mapper function is highly recommended because different
object types implement `ToString()` differently. For instance:

- Arrays: `'[1, 2, 3, "4", unset]'`
- Buffers: `"Buffer { Ptr: 000000000024D080, Size: 128 }"`

```ahk
Arr := Array(BufferObj, FileObj, MapObj, unset, "foo")

Arr.Map(Object.Prototype.ToString) ; wrong!

Arr.Map(String)                    ; use one of these three functions instead
Arr.Map(Value => String(Value))    ;
Arr.Map(Value => Value.ToString()) ;
```

**Return Value**:

- **Type**: `String`
