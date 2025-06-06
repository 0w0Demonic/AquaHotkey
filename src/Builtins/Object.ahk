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
     * Defines a new read-only property by the name of `PropertyName` for this
     * object, which returns a constant `Value`.
     * @example
     * 
     * class Foo {
     *     static Bar {
     *         Get {
     *             ; do something here...
     *             Sleep(2000)
     *             ; next time, return `Result` instantly
     *             this.DefineConstant("Bar", 42)
     *         }
     *     }
     * }
     * 
     * MsgBox(Foo.Bar) ; (2 seconds later...) 42
     * MsgBox(Foo.Bar) ; 42
     * 
     * @param   {String}  PropertyName  name of the new property
     * @param   {Any}     Value         value that is returned by this property
     * @return  {Any}
     */
    DefineConstant(PropertyName, Value) {
        this.DefineProp(PropertyName, { Get: (Instance) => Value })
        return Value
    }

    /**
     * Defines a new read-only property by the name of `PropertyName`.
     * 
     * The `Getter` function determines the value of the property when accessed.
     * @example
     * 
     * TwoTimesValue(this) {
     *     return this.Value * 2
     * }
     * 
     * Obj := { Value: 3 }
     * Obj.DefineGetter("TwoTimesValue", TwoTimesValue)
     * 
     * MsgBox(Obj.TwoTimesValue) ; 6
     * 
     * @param   {String}  PropertyName  name of property
     * @param   {Func}    Getter        property getter function
     * @return  {this}
     */
    DefineGetter(PropertyName, Getter) {
        if (!HasMethod(Getter)) {
            throw TypeError("Expected a Function",, Type(Getter))
        }
        return this.DefineProp(PropertyName, {
            Get: Getter
        })
    }

    /**
     * Defines a new property by the name of `PropertyName`.
     * 
     * The `Getter` function determines the value of the property when accessed
     * whereas `Setter` is executed whenever the property is being assigned a
     * value.
     * @example
     * 
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
     * Obj.Foo := 3      ; calls `Setter` (Count: 1)
     * MsgBox(Obj.Foo)   ; calls `Getter` (Count: 2)
     * MsgBox(Obj.Count) ; 2
     * 
     * @param   {String}  PropertyName  name of the new property
     * @param   {Func}    Getter        property getter function
     * @param   {Func}    Setter        property setter function
     * @return  {this}
     */
    DefineGetterSetter(PropertyName, Getter, Setter) {
        if (!HasMethod(Getter)) {
            throw TypeError("Expected a Function object",, Type(Getter))
        }
        if (!HasMethod(Setter)) {
            throw TypeError("Expected a Function object",, Type(Setter))
        }
        return this.DefineProp(PropertyName, {
            Get: Getter,
            Set: Setter
        })
    }

    /**
     * Defines a new property by the name of `PropertyName`.
     * 
     * The `Setter` function is executed whenever the property is being assigned
     * a value.
     * @example
     * 
     * Setter(this, Value) {
     *     return this.Value := Value.AssertInteger("only integers allowed")
     * }
     * 
     * Obj     := ({ Value: 42 }).DefineSetter("Foo", Setter)
     * Obj.Foo := 2
     * Obj.Foo := "bar" ; Error!
     * 
     * @param   {String}  PropertyName  name of the new property
     * @param   {Func}    Setter        property setter function
     * @return  {this}
     */
    DefineSetter(PropertyName, Setter) {
        if (!HasMethod(Setter)) {
            throw TypeError("Expected a Function object",, Type(Setter))
        }
        return this.DefineProp(PropertyName, {
            Set: Setter
        })
    }
    
    /**
     * Defines a new method by the name of `PropertyName`.
     * 
     * `Method` is the function invoked whenever this property is called like a
     * method.
     * @example
     *  
     * PrintValue(this) {
     *     MsgBox(this.Value)
     * }
     * 
     * Obj := ({ Value: 42 }).DefineMethod("PrintValue", PrintValue)
     * Obj.PrintValue()
     * 
     * @param   {String}  PropertyName  name of property
     * @param   {Func}    Method        method to be called
     * @return  {this}
     */
    DefineMethod(PropertyName, Method) {
        if (!HasMethod(Method)) {
            throw TypeError("Expected a Function object",, Type(Method))
        }
        return this.DefineProp(PropertyName, {
            Call: Method
        })
    }

    /**
     * Sets the base of this object.
     * @example
     * 
     * class Foo {
     * 
     * }
     * 
     * Obj := Object().SetBase(Foo.Prototype)
     * MsgBox(Obj is Foo) ; true
     * 
     * @param   {Any}  BaseObj  the new base of this object
     * @return  {this}
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
     * @example
     * 
     * ({ Foo: 45, Bar: 123 }) ; "Object {Bar: 123, Foo: 45}"
     * 
     * @return  {String}
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