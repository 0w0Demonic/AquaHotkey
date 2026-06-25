#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO add a lotta stuff for objects in general, and then put that into a
;      `Object` folder?
; TODO static constructors like `Object.WithBase()`?
; TODO find a way to differentiate between `Method()` (create prop desc) and
;      `Method()` (create object mapper)

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
            ; save indirection
            static Define := {}.DefineProp
            static GetProp := {}.GetOwnPropDesc
            Proto := this.Prototype

            Define(Proto, "BindMethod", { Call: ObjBindMethod })
            Define(Proto, "OwnProps",   { Call: ObjOwnProps   })

            Copy(Name) {
                Define(Proto, Name, GetProp(Object.Prototype, Name))
            }

            Copy("DefineProp")
            Copy("DeleteProp")
            Copy("GetOwnPropDesc")
            Copy("HasOwnProp")
        }

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

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Delegates

        /**
         * Defines a new property with the given name and property descriptor.
         * 
         * @param   {String}  Name  name of the property
         * @param   {Object}  Desc  property descriptor
         * @returns {this}
         */
        DefineProp(Name, Desc) => ({}.DefineProp)(this, Name, Desc)

        /**
         * Deletes a property by name.
         * 
         * @param   {String}  Name  name of the property
         * @returns {Object}
         */
        DeleteProp(Name) => ({}.DeleteProp)(this, Name)

        /**
         * Returns a descriptor for a given property, compatible with
         * {@link Object#DefineProp}.
         * 
         * @param   {String}  Name  name of the property
         * @returns {Object}
         */
        GetOwnPropDesc(Name) => ({}.GetOwnPropDesc)(this, Name)

        /**
         * Determines whether this object owns a property with the specified
         * name.
         * 
         * @param   {String}  Name  name of the property
         * @returns {Boolean}
         */
        HasOwnProp(Name) => ({}.HasOwnProp)(this, Name)

        /**
         * Enumerates the object's own properties.
         * 
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
            if (!IsObject(BaseObj)) {
                throw TypeError("Expected an Object",, Type(BaseObj))
            }

            Obj := Object()
            ObjSetBase(Obj, BaseObj)
            return Obj
        }
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region ObjFromDesc()

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
ObjFromDesc(Desc) {
    Obj := Object()
    Obj.DefineProp(Desc)
    return Obj
}

;@endregion
