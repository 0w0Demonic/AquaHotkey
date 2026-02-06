#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Object utilities.
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
            this.DefineProp(PropName, Mapper(PropDesc))
            return PropDesc
        }

        /**
         * Defines one or more properties.
         * 
         * `Props` is required to be a plain object.
         * 
         * @param   {Object}  Props  object containing property descriptors
         * @returns {this}
         * @example
         * this.DefineProps({
         *     Capacity: { Get: (_) => 16 },
         *     SayHello: { Call: (_) => MsgBox("Hello, world!")},
         *     ...
         * })
         */
        DefineProps(Props) {
            if (ObjGetBase(Props) != Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(Props))
            }
            for PropName in ObjOwnProps(Props) {
                this.DefineProp(PropName, Props.GetOwnPropDesc(PropName))
            }
            return this
        }

        /**
         * Defines a new read-only property by the name of `PropertyName`
         * for this object, which returns a constant `Value`.
         * 
         * @param   {String}  PropertyName  name of the new property
         * @param   {Any}     Value         value returned by this property
         * @returns {this}
         * @example
         * class Foo {
         *     ; property "Bar" becomes immutable
         *     __New(Bar) => this.DefineConstant("Bar", Bar)
         * }
         */
        DefineConstant(PropertyName, Value) {
            return this.DefineProp(PropertyName, { Get: (_) => Value })
        }

        /**
         * Defines a new read-only property by the name of `PropertyName`.
         * 
         * @param   {String}  PropertyName  name of the property
         * @param   {Func}    Getter        the function to be called
         * @returns {this}
         * @example
         * Obj := { Value: 3 }
         * Obj.DefineGetter("TwoTimesValue", (this) => (this.Value * 2))
         * MsgBox(Obj.TwoTimesValue) ; 6
         * 
         */
        DefineGetter(PropertyName, Getter) {
            GetMethod(Getter)
            return this.DefineProp(PropertyName, { Get: Getter })
        }

        /**
         * Defines a new property by the name of `PropertyName` with `Getter`
         * and `Setter` methods.
         * 
         * @param   {String}  PropertyName  name of the new property
         * @param   {Func}    Getter        getter function
         * @param   {Func}    Setter        setter function
         * @returns {this}
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
         */
        DefineGetterSetter(PropertyName, Getter, Setter) {
            (GetMethod(Getter) && GetMethod(Setter))
            return this.DefineProp(PropertyName, { Get: Getter, Set: Setter })
        }

        /**
         * Defines a new property by the name of `PropertyName` with the given
         * `Setter` function.
         * 
         * @param   {String}  PropertyName  name of the new property
         * @param   {Func}    Setter        setter function
         * @returns {this}
         * @example
         * Setter(this, Value) {
         *     return this.Value := Value.Assert(IsInteger)
         * }
         * 
         * Obj     := ({ Value: 42 }).DefineSetter("Foo", Setter)
         * Obj.Foo := 2
         * Obj.Foo := "bar" ; Error!
         */
        DefineSetter(PropertyName, Setter) {
            GetMethod(Setter)
            return this.DefineProp(PropertyName, { Set: Setter })
        }
        
        /**
         * Defines a new method by the name of `PropertyName`.
         * 
         * @param   {String}  PropertyName  name of property
         * @param   {Func}    Method        the function to be called
         * @returns {this}
         * @example
         * PrintValue(this) => MsgBox(this.Value)
         * 
         * Obj := ({ Value: 42 }).DefineMethod("PrintValue", PrintValue)
         * Obj.PrintValue()
         */
        DefineMethod(PropertyName, Method) {
            GetMethod(Method)
            return this.DefineProp(PropertyName, { Call: Method })
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

/**
 * Creates a property descriptor that resembles a field whose value is
 * type-checked ({@link AquaHotkey_DuckTypes `.Is()`}).
 * 
 * @param   {Any}  T  type pattern
 * @returns {Object}
 * @example
 * Obj := Object()
 * Obj.DefineProp("Value", CheckedField(Integer))
 * 
 * Obj.Value := 42 ; Ok.
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
