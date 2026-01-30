/**
 * A duck type wrapper which allows matching both `unset` and values of
 * an inner type. While {@link Optional} is used for wrapping values, the
 * nullable class is meant to be used for creating *type predicates*.
 * 
 * @module  <Base/DuckTypes/Nullable>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * MaybeStr := Nullable(String)
 * 
 * MaybeStr.IsInstance(unset) ; true
 * MaybeStr.IsInstance("Str") ; true
 * MaybeStr.IsInstance(342.1) ; false
 */
class Nullable {
    /**
     * Creates a new nullable type with the given inner type.
     * 
     * @constructor
     * @param   {Any}  InnerType  inner type of the nullable
     */
    __New(InnerType) {
        if (InnerType is Nullable) {
            T := InnerType.T
        } else {
            T := InnerType
        }
        this.DefineProp("T", { Get: (_) => T })
    }

    /**
     * Determines whether this nullable is equal to the other nullable.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    Eq(Val?) => IsSet(Val) && (Val is Nullable) && (this.T).Eq(Val.T)

    /**
     * Returns a hash code for this nullable type.
     * 
     * @returns {Integer}
     */
    HashCode() => Any.Hash(this.T, 2987233938928)

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
    CanCastFrom(Val) => (this.T).CanCastFrom((Val is Nullable) ? Val.T : Val)

    /**
     * Returns a string representation of this nullable type.
     * 
     * @returns {String}
     */
    ToString() => "Nullable<" . String(this.T) . ">"
}
