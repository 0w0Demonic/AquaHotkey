#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\..\Base\DuckTypes.ahk"

/**
 * @duck
 * 
 * A {@link AquaHotkey_DuckType duck type} that represents the absence of a
 * value (the value `unset`, or the absence of an array item or property).
 * 
 * @module  <Base/DuckTypes/Nothing>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Nothing extends Any {
    ; paranoia: don't let anyone mess around with this class
    static __New() {
        if (this != Nothing) {
            throw ValueError("This class must not be extended")
        }
    }

    /**
     * Determines whether the value is considered instance of `Nothing`. This
     * is only true, if `Val == unset`.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * ; `.IsInstance()` duck type checks
     * Nothing.IsInstance(unset) ; true
     * Nothing.IsInstance(42)    ; false
     */
    static IsInstance(Val?) => !IsSet(Val)

    /**
     * Determines whether the input type is equivalent to, or a subtype of
     * `Nothing`. This is the case, only if `!IsSet(T)` or `T == Nothing`.
     * 
     * Because `Nothing` must not be subclassed, subclasses are not considered
     * subtypes of `Nothing`.
     * 
     * @param   {Any?}  T  any value
     * @returns {Boolean}
     * @example
     * Nothing.CanCastFrom(Nothing) ; ==> true
     * Nothing.CanCastFrom(unset)   ; ==> true
     * Nothing.CanCastFrom(Any)     ; ==> false
     */
    static CanCastFrom(T?) => (!IsSet(T)) || (T == Nothing)
}

/**
 * {@link Json.Null} to {@link Nothing} conversion.
 */
class AquaHotkey_Nothing_Json extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Json) && super.__New()
    
    class Nothing {
        /**
         * Converts {@link Json.Null} into `unset`.
         * 
         * @param   {VarRef<Any>}  Val  any value
         * @see {@link AquaHotkey_Json}
         */
        static CastFromJson(&Val) {
            IsSet(Json)
            if (Val != Json.Null) {
                throw TypeError("Expected Json.Null",, Type(Val))
            }
            Val := unset
        }
    }
}
