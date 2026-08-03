#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

;@region Extensions

/**
 * Object utilities, mostly for the creation of new properties.
 * 
 * For the sake of convenience, properties are defined in `Any`. This is
 * because e.g. `Number.Prototype` is an object (`IsObject(Number.Prototype)`),
 * yet it doesn't own object properties.
 * 
 * @module  <Base/Object>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Object extends AquaHotkey {
    class Any {
        static __New() {
            Proto := this.Prototype
            DefineMethod(Proto, "BindMethod",  ObjBindMethod)
            DefineMethod(Proto, "OwnProps",    ObjOwnProps)
            DefineMethod(Proto, "DefineProps", DefineProps)
            DefineMethod(Proto, "GetPropDesc", GetPropDesc)
            DefineMethod(Proto, "OwnerOfProp", OwnerOfProp)

            for Name in ["DefineProp", "DeleteProp",
                         "GetOwnPropDesc", "HasOwnProp"]
            {
                DefineProp(Proto, Name, GetOwnPropDesc(Object.Prototype, Name))
            }
        }

        ;@region General

        /**
         * Creates a `BoundFunc` which calls a method `MethodName` bound to this
         * particular instance, followed by zero or more arguments `Args*`.
         * 
         * @inlined
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
            PropDesc := GetOwnPropDesc(this, PropName)
            DefineProp(this, PropName, Mapper(PropDesc, Args*))
            return PropDesc
        }

        /**
         * Defines zero or more properties.
         * 
         * `Props` is required to be a plain object.
         * 
         * @inlined
         * @param   {Object}  Props  object containing property descriptors
         * @returns {this}
         * @example
         * this.DefineProps({
         *     Capacity: Constant(16),
         *     SayHello: Method((_) => MsgBox("Hello, world!"))
         *     ...
         * })
         */
        DefineProps(Props) => DefineProps(this, Props)

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region .GetOwnPropDesc()

        /**
         * Returns the property descriptor of the object like
         * `.GetOwnPropDesc()`, but regardless where it is inherited. Returns
         * `false`, if unable to find property.
         * 
         * @inlined
         * @param   {String}  PropName  name of the property
         * @returns {Object|false}
         * @see {@link AquaHotkey_DuckTypes}
         * @example
         * ; --> { Call: AquaHotkey_DuckTypes.Any.Prototype.Is }
         * (42).GetPropDesc("Is")
         */
        GetPropDesc(PropName) => GetPropDesc(this, PropName)

        /**
         * Returns the object that owns property `PropName`.
         * 
         * @inlined
         * @param   {String}  PropName  name of the property
         * @returns {Object|false}
         * @example
         * Arr := [1, 2]
         * Arr.OwnerOfProp("Length")     ; ==> Array.Prototype
         * Arr.OwnerOfProp("DefineProp") ; ==> Object.Prototype
         */
        OwnerOfProp(PropName) => OwnerOfProp(this, PropName)

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Delegates

        /**
         * Defines a new property with the given name and property descriptor.
         * 
         * @inlined
         * @param   {String}  Name  name of the property
         * @param   {Object}  Desc  property descriptor
         * @returns {this}
         */
        DefineProp(Name, Desc) => ({}.DefineProp)(this, Name, Desc)

        /**
         * Deletes a property by name.
         * 
         * @inlined
         * @param   {String}  Name  name of the property
         * @returns {Object}
         */
        DeleteProp(Name) => ({}.DeleteProp)(this, Name)

        /**
         * Returns a descriptor for a given property, compatible with
         * {@link Object#DefineProp}.
         * 
         * @inlined
         * @param   {String}  Name  name of the property
         * @returns {Object}
         */
        GetOwnPropDesc(Name) => ({}.GetOwnPropDesc)(this, Name)

        /**
         * Determines whether this object owns a property with the specified
         * name.
         * 
         * @inlined
         * @param   {String}  Name  name of the property
         * @returns {Boolean}
         */
        HasOwnProp(Name) => ({}.HasOwnProp)(this, Name)

        /**
         * Enumerates the object's own properties.
         * 
         * @inlined
         * @returns {Enumerator}
         */
        OwnProps() => ObjOwnProps(this)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region WithBase()

    class Object {
        /**
         * Creates a new object with the specified base object.
         * 
         * This method can only be called directly by the `Object` class, and
         * no subclasses.
         * 
         * @param   {Object}  BaseObj  the base object
         * @returns {Object}
         * @example
         * BaseObj     := Object()
         * DerivingObj := Object.WithBase(BaseObj)
         */
        static WithBase(BaseObj) {
            if (this != Object) {
                throw TypeError('This method can only be called by Object',,
                            this.Prototype.__Class)
            }
            return { base: BaseObj }
        }
    }

    ;@endregion
}

;@endregion
