#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\DuckTypes.ahk"

/**
 * @duck
 * 
 * A {@link AquaHotkey_DuckType duck type} that represents `unset`.
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
     * Determines whether the given type is equivalent to, or a subtype of
     * `Nothing`. This method returns `true` if `T == Nothing`, otherwise
     * `false`.
     * 
     * @param   {Any?}  T  any value
     * @returns {Boolean}
     * @example
     * ; `.CanCastFrom()` type relations
     * Nothing.CanCastFrom(Any) ; false
     * Any.CanCastFrom(Nothing) ; false
     * Nothing.IsInstance(Any)  ; false
     * Any.IsInstance(Nothing)  ; false
     * 
     * ; edge case: can cast to itself
     * Nothing.CanCastFrom(Nothing) ; true
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

