#Include "%A_LineFile%\..\..\..\Core\Utils.ahk"
#Include "%A_LineFile%\..\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\..\Base\Hash.ahk"
#Include "%A_LineFile%\..\..\..\Base\DuckTypes.ahk"

;@region Record

/**
 * @duck
 * 
 * A `Record<K, V>` describes plain objects with certain contraints to their
 * properties. For an object to be considered instance of the record, each
 * value property must follow the contraint of the record. More specifically:
 * the property name must be instance of the key type, and the property value
 * must be instance of the value type of the record.
 *
 * This behavior is comparable to `Partial<Record<K, V>>` in TypeScript.
 * A `Record` does not assert that certain properties are present in the
 * object. For this, use a regular object as type pattern.
 * 
 * @module  <Base/DuckTypes/Record>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link AquaHotkey_DuckTypes duck types}
 * @see {@link AquaHotkey_DuckTypes.Object#IsInstance()}
 * 
 * ---
 * 
 * @template  K  key type
 * @template  V  value type
 * @property  {Class<K>}  KeyType    key type
 * @property  {Class<V>}  ValueType  value type
 * @example
 * T := Record( Type.Enum("Admin", "User", "Guest"), String )
 * 
 * Obj := {
 *     Admin: "just do what you want lol",
 *     User: "okay, you're allowed in",
 *   ; Guest: "fine. but don't touch anything"
 * }
 * 
 * MsgBox(  Obj.Is(T)  ) ; true
 * 
 * @example <caption>Using a Regular Object as Type Pattern</caption>
 * T := { Admin: String, User: String, Guest: String }
 * 
 * MsgBox(  Obj.Is(T)  ) ; false (does not have `Guest` property)
 */
class Record extends Class
{
    ; (see `<Base/DuckTypes/Nullable>`)
    static Prototype.Prototype := this.Prototype

    ;@region Construction

    /**
     * Creates a new record type with the given key and value type.
     * 
     * @constructor
     * @param   {Any}  KeyType    key type
     * @param   {Any}  ValueType  value type
     * @returns {Class}
     * @example
     * CatName := Type.Enum("Miffy", "Boris", "Mordred")
     * CatInfo := { Age: Number, Breed: String }
     * 
     * Cats := {
     *    Miffy:   { Age: 10, Breed: "Persian"           },
     *    Boris:   { Age: 5,  Breed: "Maine Coon"        },
     *    Mordred: { Age: 16, Breed: "British Shorthair" }
     * }
     * 
     * MsgBox(Cats.Is( Record(CatName, CatInfo) )) ; true
     */
    static Call(KeyType, ValueType) => DefineProps({ base: this.Prototype }, {
        KeyType:   { Get: (_) => KeyType   },
        ValueType: { Get: (_) => ValueType }
    })

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Fields

    /**
     * The key type of the record.
     *
     * @public
     * @abstract
     * @readonly
     * @type {Any}
     */
    KeyType {
        get {
            throw PropertyError("KeyType not defined")
        }
    }

    /**
     * The value type of the record.
     *
     * @public
     * @abstract
     * @readonly
     * @type {Any}
     */
    ValueType {
        get {
            throw PropertyError("ValueType not defined")
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Determines whether this record class is equal to the `Other` value.
     * 
     * This is true, whenever `this == Other`, or:
     * - `Other is Record`
     * - both `KeyType` and `ValueType` are equal via `.Eq()`
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        return IsSet(Other) && ((this == Other) ||
               (Other is Record)
            && (this.KeyType).Eq(Other.KeyType)
            && (this.ValueType).Eq(Other.ValueType))
    }

    /**
     * Returns a hash code for this record class based on its key and
     * value type.
     * 
     * @returns {Integer}
     */
    HashCode() => Any.Hash(this.KeyType, this.ValueType)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Info

    /**
     * Determines whether the given value is considered an instance of the
     * record class.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @see {@link AquaHotkey_DuckTypes `.IsInstance()`}
     */
    IsInstance(Val?) {
        if (!IsSet(Val)) {
            return false
        }

        if (!IsPlainObject(Val)) {
            return false
        }

        K := this.KeyType
        V := this.ValueType

        for PropName in ObjOwnProps(Val) {
            if (!K.IsInstance(PropName)) {
                return false
            }
            PropDesc := GetOwnPropDesc(Val, PropName)
            if (!ObjHasOwnProp(PropDesc, "Value")) {
                return false
            }
            if (!V.IsInstance(PropDesc.Value)) {
                return false
            }
        }
        return true
    }

    /**
     * Determines whether the given value is equal to this record class,
     * or its subclass.
     * 
     * This is true whenever `Other` is a record class, and both the key and
     * value type of this record can be cast from the other class
     * respectively.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     * @example
     * Record(String, String).CanCastFrom( Record(Group, String) )
     * ; --> `String.CanCastFrom(Group)`
     * ; --> `HasBase(Group, String)`
     * ; --> true
     * 
     * ; Our duck type: special type of string.
     * ; important: `extends String` to make `String.CanCastFrom(Group)` work
     * class Group extends String {
     *     static IsInstance(Val?) {
     *         return String.IsInstance(Val?)
     *             && (Val ~= "i)^(?:guest|user|admin)$")
     *     }
     * }
     */
    CanCastFrom(Other?) {
        return IsSet(Other)
            && (Other is Record)
            && (this.KeyType).CanCastFrom(Other.KeyType)
            && (this.ValueType).CanCastFrom(Other.ValueType)
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

; TODO implement JSON deser. Note that JSON is case-sensitive.

/**
 * {@link AquaHotkey_Serializer binary serialization support} for
 * {@link Record}.
 */
class AquaHotkey_Record_Serialization extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Serializer) && super.__New()

    class Record {
        /**
         * Serializes this record into binary.
         * 
         * @param   {OutputStream}  Output  output stream
         * @param   {Map}           Refs    map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Serialize(Output, Refs) {
            (Object.Prototype.Serialize)(this, Output, Refs)
            Output.WriteObject(this.KeyType, Refs)
            Output.WriteObject(this.ValueType, Refs)
        }

        /**
         * Reconstructs this record from binary.
         * 
         * @param   {InputStream}  Input  input stream
         * @param   {Map}          Refs   map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Deserialize(Input, Refs) {
            Input.ReadObject(&KeyType, Refs)
            Input.ReadObject(&ValueType, Refs)
            DefineProps(this, {
                TypeType:   { Get: (_) => KeyType   },
                ValueType:  { Get: (_) => ValueType } })
        }
    }
}

