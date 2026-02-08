/**
 * @duck
 * 
 * A duck type wrapper which allows matching both `unset` and values of
 * an inner type. While {@link Optional} is used for wrapping values, the
 * nullable class is meant to be used for creating *type predicates*.
 * 
 * @module  <Base/DuckTypes/Nullable>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @template T the inner type
 * @example
 * MaybeStr := Nullable(String)
 * 
 * MaybeStr.IsInstance(unset) ; true
 * MaybeStr.IsInstance("Str") ; true
 * MaybeStr.IsInstance(342.1) ; false
 */
class Nullable extends Class
; note: `extends Class` - for now - because this is the specification for what
;       a "type wrapper" is for generic arrays.
{
    /**
     * Creates a new nullable type with the given inner type.
     * 
     * @constructor
     * @param   {T}  InnerType  inner type of the nullable
     * @returns {Nullable<T>}
     */
    static Call(InnerType?) {
        if (InnerType is Nullable) {
            T := InnerType.T
        } else {
            T := InnerType
        }
        Obj := Object()
        Obj.DefineProp("T", { Get: (_) => T })
        ObjSetBase(Obj, this.Prototype)
        return Obj
    }

    /**
     * Determines whether this nullable is equal to the other nullable.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    Eq(Val?) {
        if (!IsSet(Val)) {
            return false
        }
        if (this == Val) {
            return true
        }
        return (Val is Nullable) && (this.T).Eq(Val.T)
    }

    /**
     * Returns a hash code for this nullable type.
     * 
     * @returns {Integer}
     */
    HashCode() => Any.Hash(this.T)

    /**
     * Determines whether the value is considered instance of this nullable
     * type.
     * 
     * @param   {Any}  Val  any value
     * @returns {Boolean}
     * @example
     * Nullable(String).IsInstance(unset) ; true
     * Nullable(Number).IsInstance("foo") ; false
     */
    IsInstance(Val?) => (!IsSet(Val)) || this.T.IsInstance(Val)

    /**
     * Determines whether the value is compatible with this nullable type.
     * 
     * @param   {Any}  Val  any value
     * @returns {Boolean}
     */
    CanCastFrom(Val) {
        if (Val is Nullable) {
            return (this.T).CanCastFrom(Val.T)
        }
        return (this.T).CanCastFrom(Val)
    }

    /**
     * Returns a string representation of this nullable type.
     * 
     * @returns {String}
     */
    ToString() => "Nullable<" . String(this.T) . ">"
}