#Include "%A_LineFile%/../../Core/AquaHotkey.ahk"

;@region Properties
/**
 * A map view of an object's own properties (as strings) mapped to their
 * property descriptors.
 * 
 * - Note: Adding a property to the underlying object does NOT update the map.
 * 
 * @module  <Collections/Properties>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * class Constants extends Any {
 *     static Pi  => 3.1415926
 *     static Phi => 1.618
 *     static E   => 2.71828
 * }
 * 
 * MsgBox("inspecting properties...")
 * for Name in Constants.ReadOnlyProps {
 *     MsgBox("readonly: " . Name)
 * }
 */
class Properties extends Map
{
    ; property names are case-insensitive.
    CaseSense => false

    ;@region Construction

    /**
     * Creates a new `Properties` view of the given object, filtered after
     * the given condition.
     * 
     * ```ahk
     * Condition(Name: String, PropDesc: Property) => Boolean
     * ```
     * 
     * @param   {Object}  Obj        any object
     * @param   {Func?}   Condition  the given condition
     * @returns {Properties}
     * @example
     * Properties.Find(Obj, (Name, Prop) => Prop.Is(Getter))
     */
    static Find(Obj, Condition) {
        static Define  := {}.DefineProp

        GetMethod(Condition)
        if (!IsObject(Obj)) {
            throw TypeError("Expected an Object",, Type(Obj))
        }

        Result := Map()

        Define(this, "Obj", { Get: (_) => Obj })
        for Name in ObjOwnProps(Obj) {
            PropDesc := Property(Obj, Name)
            if (Condition(Name, PropDesc)) {
                Result.Set(Name, PropDesc)
            }
        }

        ObjSetBase(Result, this.Prototype)
        return Result
    }

    /**
     * Creates a new properties view of the given object.
     * 
     * @constructor
     * @param   {Object}  Obj  any object
     */
    __New(Obj, Names*) {
        static Define := {}.DefineProp

        if (!IsObject(Obj)) {
            throw TypeError("Expected an Object",, Type(Obj))
        }

        Define(this, "Obj", { Get: (_) => Obj })
        for Name in ((Names.Length) ? Names.__Enum(1) : ObjOwnProps(Obj)) {
            super.Set(Name, Property(Obj, Name))
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region .Set()

    /**
     * Sets a value in this map.
     * 
     * This causes a new property to be added to the object, or an existing
     * property to be modified.
     * 
     * @param   {String}  Name      name of the property
     * @param   {Object}  PropDesc  property descriptor
     */
    Set(Name, PropDesc) {
        static Define := {}.DefineProp

        if (IsObject(Name)) {
            throw TypeError("Expected a String",, Type(Name))
        }
        if (!IsObject(PropDesc)) {
            throw TypeError("Expected an Object",, Type(PropDesc))
        }
        if (!(PropDesc is Property)) {
            ObjSetBase(PropDesc, Property.Prototype)
        }
        super.Set(Name, PropDesc)
        Define(this.Obj, Name, PropDesc)
    }

    /**
     * Sets a value in this map (see {@link Properties#Set .Set()}).
     * 
     * @param   {String}  Name      name of the property
     * @param   {Object}  PropDesc  property descriptor
     */
    __Item[Name] {
        set => this.Set(Name, value)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region .Transform()

    /**
     * Transforms all properties in this map by applying the given mapper
     * function.
     * 
     * @param   {Func}  Mapper  function creating a new property descriptor
     * @param   {Any*}  Args    zero or more arguments for the mapper
     * @example
     * Obj.Properties["Set", "__Item"].Transform((PropDesc) {
     *     ; Create a new, transformed property descriptor, e.g. with
     *     ; additional type checks.
     *     ...
     *     return NewPropDesc
     * })
     */
    Transform(Mapper, Args*) {
        GetMethod(Mapper)
        for Name, Value in this {
            this.Set(Name, Mapper(Value, Args*))
        }
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Property

/**
 * Wrapper class over property descriptors.
 */
class Property {
    ;@region Construction

    /**
     * Creates a new property object from the given object and property name.
     * 
     * @param   {Object}  Obj   any object
     * @param   {String}  Name  name of the property
     * @returns {Property}
     */
    static Call(Obj, Name) {
        static GetProp := {}.GetOwnPropDesc

        if (!IsObject(Obj)) {
            throw TypeError("Expected an Object",, Type(Obj))
        }
        if (IsObject(Name)) {
            throw TypeError("Expected a String",, Type(Name))
        }
        if (!ObjHasOwnProp(Obj, Name)) {
            throw PropertyError("property not found")
        }
        return this.Cast(GetProp(Obj, Name))
    }

    /**
     * Casts an existing property descriptor (object literal) into a property
     * object.
     * 
     * @param   {Object}  PropDesc  the property descriptor
     * @returns {Property}
     */
    static Cast(PropDesc) {
        ObjSetBase(PropDesc, this.Prototype)
        return PropDesc
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region .IsX() methods

    /**
     * Determines whether this property is a field (defines `Value`).
     * @returns {Boolean}
     */
    IsField => ObjHasOwnProp(this, "Value")

    /**
     * Determines whether this property is a getter (defines `.Get()`).
     * @returns {Boolean}
     */
    IsGetter => ObjHasOwnProp(this, "Get")

    /**
     * Determines whether this property is a method (defines `.Call()`).
     * @returns {Boolean}
     */
    IsMethod => ObjHasOwnProp(this, "Call")

    /**
     * Determines whether this property is a setter (defines `.Set()`).
     * @returns {Boolean}
     */
    IsSetter => ObjHasOwnProp(this, "Set")

    /**
     * Determines whether this property is a typed property (defines `Type`)
     * @returns {Boolean}
     */
    IsTyped => ObjHasOwnProp(this, "Type")

    /**
     * Determines whether this property is a read-only property (defines
     * `.Get()` and NOT `.Set()`).
     * @returns {Boolean}
     */
    IsReadOnlyProp => ObjHasOwnProp(this, "Get") && !ObjHasOwnProp(this, "Set")

    /**
     * Determines whether this property is a value property (field or getter).
     * @returns {Boolean}
     */
    IsValueProp => this.IsField || this.IsReadOnlyProp

    /**
     * Determines whether this property is dynamic (getter and setter).
     * @returns {Boolean}
     */
    IsDynamicProp => this.IsGetter && this.IsSetter

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

class AquaHotkey_Properties extends AquaHotkey {
    class Object {
        /**
         * Returns a property view of this object.
         * 
         * If specified, ``
         * 
         * @param   {String*}  Names  
         * @returns {Properties}
         * @example
         * Obj := { foo: "bar", baz: "qux", ... }
         * 
         * P := Obj.Properties["foo", "baz"]
         * 
         * MsgBox(P.Count) ; 2
         * MsgBox(P.Has("foo")) ; true
         * 
         * P["Foo"] ; { Value: "bar" }   (property descriptor object)
         * P["Foo"] := { Value: "new value" }
         * 
         * MsgBox(Obj.Foo) ; "new value"
         */
        Properties[Names*] => Properties(this, Names*)

        /**
         * Returns a view of all methods owned by this object.
         * 
         * @returns {Properties}
         */
        Methods => Properties.Find(this, (_, Prop) => Prop.IsMethod)

        /**
         * Returns a view of all fields owned by this object.
         * 
         * @returns {Properties}
         */
        Fields => Properties.Find(this, (_, Prop) => Prop.IsField)

        /**
         * Returns a view of all dynamic properties (`get`/`set`) of this
         * object.
         * 
         * @returns {Properties}
         */
        DynamicProps => Properties.Find(this, (_, Prop) => Prop.IsDynamicProp)

        /**
         * Returns a view of all typed properties (a.k.a. "struct members")
         * in v2.1.
         * 
         * @returns {Properties}
         */
        TypedProps => Properties.Find(this, (_, Prop) => Prop.IsTyped)

        /**
         * Returns a view of all value properties of this object.
         * 
         * A value property is one that either describes `Value` or `Get`.
         * 
         * @returns {Properties}
         */
        ValueProps => Properties.Find(this, (_, Prop) => Prop.IsValueProp)

        /**
         * Returns a view of all value properties of th
         */
        ReadOnlyProps => Properties.Find(this, (_, Prop) => Prop.IsReadOnlyProp)

        /**
         * Returns a properties view of this object, filtered by the given
         * predicate function.
         * 
         * ```ahk
         * Condition(Name: String, PropDesc: Property) => Boolean
         * ```
         * 
         * @param   {Func}  Condition  the given condition
         * @returns {Properties}
         */
        FindProps(Condition) => Properties.Find(this, Condition)
    }
}
;@endregion