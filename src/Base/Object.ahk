#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Object utilities, mostly for the creation of new properties.
 * 
 * @module  <Base/Object>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Object extends AquaHotkey {
    class Object {
        ;@region General
        /**
         * Creates a `BoundFunc` which calls a method `MethodName` bound to this
         * particular instance, followed by zero or more arguments `Args*`.
         * 
         * @param   {String}  MethodName  the name of a method
         * @param   {Any*}    Args        zero or more additional arguments
         * @returns {BoundFunc}
         * @example
         * Arr       := Array()
         * PushToArr := Arr.BindMethod("Push")
         * PushToArr("Hello, world!")
         */
        BindMethod(MethodName, Args*) => ObjBindMethod(this, MethodName, Args*)

        /**
         * Sets the base of this object.
         * 
         * @param   {Any}  BaseObj  the new base of this object
         * @returns {this}
         * @example
         * class Foo {
         * 
         * }
         * 
         * Obj := Object().SetBase(Foo.Prototype)
         * MsgBox(Obj is Foo) ; true
         */
        SetBase(BaseObj) {
            ObjSetBase(this, BaseObj)
            return this
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region DefineProp

        /**
         * "Transforms" a property by applying the given mapper function to
         * the property descriptor. This method returns the previously defined
         * property descriptor.
         * 
         * ```ahk
         * Mapper(PropDesc: Object, Args: Any*) => Object
         * ```
         * 
         * @param   {String}  PropName  name of the property
         * @param   {Func}    Mapper    the mapper function
         * @returns {Object}
         * @example
         * WithLogging(PropDesc, Message) {
         *     return { Call: WithLogging }
         * 
         *     WithLogging(Args*) {
         *         OutputDebug(Message)
         *         return (PropDesc.Call)(Args*)
         *     }
         * }
         * 
         * Target := Array.Prototype
         * PropName := "Pop"
         * Previous := Target.TransformProp(PropName, WithLogging, "Pop!!!")
         * 
         * Array(1).Pop() ; (calls our new property)
         */
        TransformProp(PropName, Mapper, Args*) {
            GetMethod(Mapper)
            PropDesc := this.GetOwnPropDesc(PropName)
            this.DefineProp(PropName, Mapper(PropDesc, Args*))
            return PropDesc
        }

        /**
         * Defines zero or more properties.
         * 
         * `Props` is required to be a plain object.
         * 
         * @param   {Object}  Props  object containing property descriptors
         * @returns {this}
         * @example
         * this.DefineProps({
         *     Capacity: Constant(16),
         *     SayHello: Method((_) => MsgBox("Hello, world!"))
         *     ...
         * })
         */
        DefineProps(Props) {
            static GetProp := {}.GetOwnPropDesc

            if (ObjGetBase(Props) != Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(Props))
            }
            for PropName in ObjOwnProps(Props) {
                PropDesc := GetProp(Props, PropName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    continue
                }
                this.DefineProp(PropName, PropDesc.Value)
            }
            return this
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region .GetOwnPropDesc()

        /**
         * Returns the property descriptor of the object like
         * `.GetOwnPropDesc()`, but regardless where it is inherited.
         * 
         * @param   {String}  PropName  name of the property
         * @returns {Object}
         * @see {@link AquaHotkey_DuckTypes}
         * @example
         * ; --> { Call: AquaHotkey_DuckTypes.Any.Prototype.Is }
         * (42).GetPropDesc("Is")
         */
        GetPropDesc(PropName) {
            if (!HasProp(this, PropName)) {
                return ""
            }
            Obj := this
            while (!ObjHasOwnProp(Obj, PropName)) {
                Obj := ObjGetBase(Obj)
            }
            return ({}.GetOwnPropDesc)(Obj, PropName)
        }
    }
}

;@region Prop Descs

/**
 * Creates an object described only by the property descriptors in `Desc`.
 * 
 * @param   {Object}  Desc  a set of properties
 * @returns {Object}
 * @example
 * Obj := ObjFromDesc({ Value: Constant(42) })
 * 
 * MsgBox(Obj.Value)             ; 42
 * Obj.Value := "something else" ; Error! This property is read-only.
 */
ObjFromDesc(Desc) => {}.DefineProps(Desc)

/**
 * Creates a property descriptor that resembles a field whose value is
 * type-checked ({@link AquaHotkey_DuckTypes `.Is()`}).
 * 
 * @param   {Any}   T             type pattern
 * @param   {Any?}  InitialValue  initial value
 * @returns {Object}
 * @example
 * Obj := Object()
 * Obj.DefineProp("Value", CheckedField(Integer, 42))
 * MsgBox(Obj.Value) ; 42
 * Obj.Value := Buffer(16, 0) ; Error!
 */
CheckedField(T, InitialValue?) {
    Value := (InitialValue?)
    return { Get: (this) => Value, Set: Setter }

    Setter(this, NewValue?) {
        if (!T.IsInstance(NewValue?)) {
            throw TypeError("type mismatch", -2)
        }
        Value := (NewValue?)
    }
}

/**
 * Defines a new property that resembles a regular field.
 * 
 * @param   {Any}  Value  value of the field
 * @returns {Object}
 */
Field(Value) => { Value: Value }

/**
 * Defines a new method by the name of `PropertyName`.
 * 
 * @param   {Func}  Method  the function to be called
 * @returns {Object}
 * @example
 * Obj := { Value: 42 }
 * Obj.Define("Increment", Method((this) => ++this.Value))
 * Obj.Increment() ; 43
 */
Method(Fn) {
    GetMethod(Fn)
    return { Call: Fn }
}

/**
 * Defines a new read-only property by the name of `PropertyName`.
 * 
 * @param   {Func}  Fn  the function to be called
 * @returns {Object}
 * @example
 * Obj := { Value: 3 }
 * Obj.DefineProp("TwoTimesValue", Getter((this) => (2 * this.Value)))
 * MsgBox(Obj.TwoTimesValue) ; 6
 */
Getter(Fn) {
    GetMethod(Fn)
    return { Get: Fn }
}

/**
 * Defines a new property by the name of `PropertyName` with the given
 * `Setter` function.
 * 
 * @param   {Func}  Fn  setter function
 * @returns {Object}
 * @example
 * Setter(this, Value) {
 *     return this.Value := Value.Assert(IsInteger)
 * }
 * 
 * Obj     := ({ Value: 42 }).DefineSetter("Foo", Setter)
 * Obj.Foo := 2
 * Obj.Foo := "bar" ; Error!
 */
Setter(Fn) {
    GetMethod(Fn)
    return { Set: Fn }
}

/**
 * Defines a new property by the name of `PropertyName` with `Getter`
 * and `Setter` methods.
 * 
 * @param   {Func}  Get  getter function
 * @param   {Func}  Set  setter function
 * @returns {Object}
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
 * Obj := { Count: 0 }
 * Obj.DefineProp("Foo", GetterSetter(Getter, Setter))
 * 
 * Obj.Foo := 3
 * MsgBox(Obj.Foo)   ; 3
 * MsgBox(Obj.Count) ; 2
 */
GetterSetter(Get, Set) {
    GetMethod(Get)
    GetMethod(Set)
    return { Get: Get, Set: Set }
}

/**
 * Defines a new read-only property which returns a constant `Value`.
 * 
 * @param   {Any}  Value  value returned by this property
 * @returns {Object}
 * @example
 * class Foo {
 *     ; property "Bar" becomes immutable
 *     __New(Bar) => this.DefineProp("Bar", Constant(Bar))
 * }
 */
Constant(Value) => { Get: (_) => Value }

/**
 * Defines a new read-only property which returns the value referenced by the
 * given VarRef. This is especially useful with the introduction to `PropRef`
 * in v2.1-alpha.10.
 * 
 * @param   {VarRef}  Value  reference to the value
 * @returns {Object}
 * @example <caption>Using VarRef</caption>
 * Obj := Object()
 * Value := 42
 * Obj.DefineProp("Value", ConstantRef(&Value))
 * MsgBox(Obj.Value) ; 42
 * 
 * @example <caption>Using PropRef</caption>
 * OtherObj := { Value: 42 }
 * Obj := Object()
 * Obj.DefineProp("Value", ConstantRef(&OtherObj.Value))
 * 
 * MsgBox(Obj.Value) ; 42
 */
ConstantRef(&Value) => { Get: (_) => Value }

/**
 * Defines a new property that resembles a struct field in AHK alpha.
 * 
 * @param   {Any}  T  the type of struct field
 * @returns {Object}
 * @example
 * Obj.DefineProp("Value", StructField("u32"))
 */
StructField(T) => { Type: T }

;@endregion
