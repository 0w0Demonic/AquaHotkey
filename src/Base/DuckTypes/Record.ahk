/**
 * @duck
 * 
 * A `Record<K, V>` is a {@link AquaHotkey_DuckTypes duck type} with
 * properties of type `K` and values `V`.
 * 
 * @module  <Base/DuckTypes/Record>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link AquaHotkey_DuckTypes duck types}
 * 
 * ---
 * 
 * @template  K  key type
 * @template  V  value type
 * @property  {Class<K>}  KeyType    key type
 * @property  {Class<V>}  ValueType  value type
 * @example
 * Permissions := Type.Enum("Admin", "User", "Guest")
 * PermissionsMap := Record(Permissions, String)
 * 
 * Obj := {
 *     Admin: "just do what you want lol",
 *     User: "okay, you're allowed in",
 *     Guest: "fine. but don't touch anything"
 * }
 * MsgBox(Obj.Is(PermissionsMap))
 */
class Record extends Class {
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
    __New(KeyType, ValueType) {
        ; note: no validation, because any value implements `IsInstance()`,
        ;       which is a valid type pattern.
        this.DefineProp("KeyType",   { Get: (_) => KeyType   })
        this.DefineProp("ValueType", { Get: (_) => ValueType })
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

        ; only supposed to work on plain objects, for now.
        if (ObjGetBase(Val) != Object.Prototype) {
            return false
        }

        K := this.KeyType
        V := this.ValueType

        for PropName in ObjOwnProps(Val) {
            if (!K.IsInstance(PropName)) {
                return false
            }
            PropDesc := Val.GetOwnPropDesc(PropName)
            if (!ObjHasOwnProp(PropDesc, "Value")) {
                ; forbid any type of black magic with prop descs... for now.
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
     * @param   {Any}  Other  any value
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
    CanCastFrom(Other) {
        ; (this == Other) || HasBase(Other, this)
        if (super.CanCastFrom(Other)) {
            return true
        }
        return (Other is Record)
            && (this.KeyType).CanCastFrom(Other.KeyType)
            && (this.ValueType).CanCastFrom(Other.ValueType)
    }
}
