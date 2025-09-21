class AquaHotkey_Object extends AquaHotkey {
/**
 * AquaHotkey - Object.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Object.ahk
 */
class Object {
    /**
     * Creates a `BoundFunc` which calls a method `MethodName` bound to this
     * particular instance, followed by zero or more arguments `Args*`.
     * 
     * @example
     * Arr       := Array()
     * PushToArr := Arr.BindMethod("Push")
     * PushToArr("Hello, world!")
     * 
     * @param   {String}  MethodName  the name of a method
     * @param   {Any*}    Args        zero or more additional arguments
     * @returns {BoundFunc}
     */
    BindMethod(MethodName, Args*) => ObjBindMethod(this, MethodName, Args*)

    /**
     * Defines a new read-only property by the name of `PropertyName` for this
     * object, which returns a constant `Value`.
     * 
     * @example
     * class Foo {
     *     ; property "Bar" becomes immutable
     *     __New(Bar) => this.DefineConstant("Bar", Bar)
     * }
     * 
     * @param   {String}  PropertyName  name of the new property
     * @param   {Any}     Value         value that is returned by this property
     * @returns {Any}
     */
    DefineConstant(PropertyName, Value) {
        return this.DefineProp(PropertyName, { Get: (*) => Value })
    }

    /**
     * Defines a new read-only property by the name of `PropertyName`.
     * 
     * @example
     * TwoTimesValue(this) {
     *     return this.Value * 2
     * }
     * 
     * Obj := { Value: 3 }
     * Obj.DefineGetter("TwoTimesValue", TwoTimesValue)
     * 
     * MsgBox(Obj.TwoTimesValue) ; 6
     * 
     * @param   {String}  PropertyName  name of the property
     * @param   {Func}    Getter        the function to be called
     * @returns {this}
     */
    DefineGetter(PropertyName, Getter) {
        GetMethod(Getter)
        return this.DefineProp(PropertyName, { Get: Getter })
    }

    /**
     * Defines a new property by the name of `PropertyName` with `Getter` and
     * `Setter` methods.
     * 
     * @example
     * Getter(this) {
     *     ++this.Count
     *     return this.Value
     * }
     * 
     * Setter(this, Value) {
     *     ++this.Count
     *     return this.Value := Value
     * }
     * 
     * Obj := ({ Count: 0 }).DefineGetterSetter("Foo", Getter, Setter)
     * 
     * Obj.Foo := 3
     * MsgBox(Obj.Foo)   ; 3
     * MsgBox(Obj.Count) ; 2
     * 
     * @param   {String}  PropertyName  name of the new property
     * @param   {Func}    Getter        getter function
     * @param   {Func}    Setter        setter function
     * @returns {this}
     */
    DefineGetterSetter(PropertyName, Getter, Setter) {
        (GetMethod(Getter) && GetMethod(Setter))
        return this.DefineProp(PropertyName, { Get: Getter, Set: Setter })
    }

    /**
     * Defines a new property by the name of `PropertyName` with the given
     * `Setter` function.
     * 
     * @example
     * Setter(this, Value) {
     *     return this.Value := Value.Assert(IsInteger)
     * }
     * 
     * Obj     := ({ Value: 42 }).DefineSetter("Foo", Setter)
     * Obj.Foo := 2
     * Obj.Foo := "bar" ; Error!
     * 
     * @param   {String}  PropertyName  name of the new property
     * @param   {Func}    Setter        setter function
     * @returns {this}
     */
    DefineSetter(PropertyName, Setter) {
        GetMethod(Setter)
        return this.DefineProp(PropertyName, { Set: Setter })
    }
    
    /**
     * Defines a new method by the name of `PropertyName`.
     * 
     * @example
     * PrintValue(this) => MsgBox(this.Value)
     * 
     * Obj := ({ Value: 42 }).DefineMethod("PrintValue", PrintValue)
     * Obj.PrintValue()
     * 
     * @param   {String}  PropertyName  name of property
     * @param   {Func}    Method        the function to be called
     * @returns {this}
     */
    DefineMethod(PropertyName, Method) {
        GetMethod(Method)
        return this.DefineProp(PropertyName, { Call: Method })
    }

    /**
     * Sets the base of this object.
     * 
     * @example
     * class Foo {
     * 
     * }
     * 
     * Obj := Object().SetBase(Foo.Prototype)
     * MsgBox(Obj is Foo) ; true
     * 
     * @param   {Any}  BaseObj  the new base of this object
     * @returns {this}
     */
    SetBase(BaseObj) {
        ObjSetBase(this, BaseObj)
        return this
    }

    /**
     * Converts this object into a string. `String(Obj)` implicitly calls this
     * method.
     * 
     * The behavior of this method might be changed in future versions.
     * 
     * @example
     * ({ Foo: 45, Bar: 123 }) ; "Object {Bar: 123, Foo: 45}"
     * 
     * @returns {String}
     */
    ToString() {
        static KeyValueMapper(Key, Value?) {
            if (!IsSet(Value)) {
                Value := "unset"
            } else if (Value is String) {
                Value := '"' . Value . '"'
            }
            return Format("{}: {}", Key, Value)
        }

        Loop {
            try {
                Result := ""
                for Key, Value in this {
                    if (A_Index != 1) {
                        Result .= ", "
                    }
                    Result .= KeyValueMapper(Key, Value?)
                }
                break
            }
            try {
                Result := ""
                for Value in this {
                    if (A_Index != 1) {
                        Result .= ", "
                    }
                    Value := Value ?? "unset"
                    Result .= String(Value)
                }
                break
            }
            try {
                Result := ""
                for PropName, Value in this.OwnProps() {
                    if (A_Index != 1) {
                        Result .= ", "
                    }
                    Result .= KeyValueMapper(PropName, Value?)
                }
            }
            return Type(this)
        } until true

        return Type(this) . "{ " . (Result ?? "unset") . " }"
    }
} ; class Object
} ; class AquaHotkey_Object extends AquaHotkey