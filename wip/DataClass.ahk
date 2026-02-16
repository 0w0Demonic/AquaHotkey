#Requires AutoHotkey v2.0
#Include <AquaHotkeyX>

/**
 * Creates a new {@link DataObject} class based on the given schema.
 * 
 * A schema is defined as a plain object that maps property names to a
 * {@link AquaHotkey_DuckTypes duck type}.
 * 
 * @param   {Object}  Schema  plain object that represents structure
 * @returns {Class<? extends DataObject>}
 * @see {@link DataObject.OfType()}
 * @example
 * T_User := DataClass({ name: String, age: Integer })
 * User := T_User({ name: "Sasha", age: 32 })
 */
DataClass(Schema) => AquaHotkey.CreateClass(DataObject, unset, Schema)

/**
 * A data object class that can be used to create data objects with a specific
 * schema. They can be created by calling {@link DataClass} with a schema
 * object, a plain object that maps property names to a
 * {@link AquaHotkey_DuckTypes duck type}.
 * 
 * @module  <Base/DataObject>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * Point := DataClass({ x: Integer, y: Integer })
 * 
 * P := Point({ x: 1, y: 2 })
 * MsgBox(P.x) ; 1
 */
class DataObject {
    /**
     * Constructs a new data object class.
     * 
     * @param   {Object}  Schema  schema imposed by the data object class
     * @returns {Class<? extends DataObject>}
     * @see {@link DataClass()}
     * @example
     * User := DataObject.OfType({ name: String, age: Integer })
     */
    static OfType(Schema) => AquaHotkey.CreateClass(DataObject, unset, Schema)

    /**
     * Constructs a new data object class.
     * 
     * This constructor should not be used directly. Instead, use
     * {@link DataClass()} or {@link DataObject.OfType()}.
     * 
     * @private
     * @constructor
     * @param   {Object}  Schema  schema imposed by the data object class
     */
    static __New(Schema?) {
        if (this == DataObject) {
            return
        }
        if (!IsSet(Schema)) {
            throw UnsetError("Expected a plain Object")
        }
        if (ObjGetBase(Schema) != Object.Prototype) {
            throw TypeError("Expected a plain Object",, Type(Schema))
        }

        Obj := Object()
        for PropertyName in ObjOwnProps(Schema) {
            PropDesc := Schema.GetOwnPropDesc(PropertyName)
            if (!ObjHasOwnProp(PropDesc, "Value")) {
                continue
            }
            Obj.DefineProp(PropertyName, { Value: PropDesc.Value })
        }

        (this.Prototype).DeleteProp("__Class")
        (this.Prototype).DefineProp("Schema", { Get: (_) => Obj })
    }

    /**
     * Initializes the fields of the data object before calling
     * {@link DataObject#__New `.__New()`}.
     */
    __Init() {
        for PropertyName, Type in ObjOwnProps(this.Schema) {
            this.DefineProp(PropertyName, CheckedField(Type))
        }
    }

    /**
     * Constructs a new data object. Use a plain object to initialize the
     * object with one or more properties.
     * 
     * @constructor
     * @param   {Object?}  Obj  object containing properties to be assigned
     * @example
     * T := DataClass({ Value: Integer })
     * 
     * Obj := T({ Value: 42 })
     */
    __New(Obj := {}) {
        if (ObjGetBase(Obj) != Object.Prototype) {
            throw TypeError("Expected a plain Object",, Type(Obj))
        }
        for PropertyName in ObjOwnProps(Obj) {
            PropDesc := Obj.GetOwnPropDesc(PropertyName)
            if (!ObjHasOwnProp(PropDesc, "Value")) {
                continue
            }

            ; ehhhh... idk about this.
            this.%PropertyName% := PropDesc.Value
        }
    }

    /**
     * Returns a string representation of this data object class.
     * 
     * @returns {String}
     */
    static ToString() => "DataObject<" . String(this.Schema) . ">"

    /**
     * Returns a string representation of this data object.
     * 
     * @returns {String}
     */
    ToString() {
        Obj := Object()
        for PropertyName in ObjOwnProps(this.Schema) {
            if (!ObjHasOwnProp(this, PropertyName)) {
                continue
            }
            Obj.DefineProp(PropertyName, { Value: this.%PropertyName% })
        }
        return String(Obj)
    }

    /**
     * Returns the schema imposed by this data object class.
     * 
     * @returns {Object}
     */
    static Schema => (this.Prototype).Schema

    /**
     * Determines whether the input value is an instance of this data object
     * class.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * T := DataClass({ Value: Integer })
     * 
     * Obj := T({ Value: 42 })
     * Obj.Is(T) ; true
     */
    static IsInstance(Val?) {
        if (!IsSet(Val)) {
            return false
        }
        if (Val is DataObject) {
            return (this.Prototype.Schema).CanCastFrom(Val.Schema)
        }
        return (this.Prototype.Schema).IsInstance(Val)
    }

    /**
     * Determines whether the given value is considered the same type as, or a
     * subtype of this data object class. This requires that the input is
     * another data object class with compatible schema (via
     * {@link AquaHotkey_DuckTypes `.CanCastFrom()`}).
     * 
     * @param   {Any}  T  type pattern
     * @returns {Boolean}
     * @example
     * DataClass({ Value: Any }).CanCastFrom(DataClass({ Value: String }))
     */
    static CanCastFrom(T) {
        return HasBase(T, DataObject)
            && (this.Prototype.Schema).CanCastFrom(T.Prototype.Schema)
    }

    /**
     * Determines whether this data object class is equal to the `Other`
     * value. This requires that the input is another data object class with
     * equal schema.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    static Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        return HasBase(Other, DataObject)
            && (this.Prototype.Schema).Eq(Other.Prototype.Schema)
    }

    /**
     * Determines whether this data object is equal to the `Other` value.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is DataObject)) {
            return false
        }
        for Name in ObjOwnProps(this.Schema) {
            if (ObjHasOwnProp(this, Name)) {
                if (!ObjHasOwnProp(Other, Name)) {
                    return false
                }
                if (!(this.%Name%).Eq(Other.%Name%)) {
                    return false
                }
            } else if (ObjHasOwnProp(Other, Name)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns a hash from the data object class.
     * 
     * @returns {Integer}
     */
    static HashCode() => (this.Prototype.Schema).HashCode()

    /**
     * Returns a hash from the data object.
     * 
     * @returns {Integer}
     */
    HashCode() {
        static Offset := AquaHotkey_Hash.Offset
        static Prime  := AquaHotkey_Hash.Prime

        Result := Offset
        for PropertyName in ObjOwnProps(this.Schema) {
            Result ^= ObjHasOwnProp(this, PropertyName)
                   && this.%PropertyName%.HashCode()
            Result *= Prime
        }
        return Result
    }
}
