#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * This feature allows easy type-casting between different `Func` types.
 * 
 * @module  <Func/Cast>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * Predicate.Cast(IsNumber) ; gains access to Predicate methods
 */
class AquaHotkey_FuncCasting extends AquaHotkey {
    class Func {
        /**
         * Returns an instance of this class from the specified `Func` or `Call`
         * method of an object.
         * 
         * @param   {Object}  Fn  function or callable object
         * @returns {Func}
         * @example
         * Pred := Predicate(IsNumber)
         * MsgBox(Pred is Predicate)     ; true
         * MsgBox(IsNumber is Predicate) ; false
         */
        static Call(Fn) {
            GetMethod(Fn)
            return this.Cast(ObjBindMethod(this))
        }

        /**
         * Casts the given `Func` into an instance of this class.
         * 
         * @param   {Func}  Fn  a function object
         * @returns {Fun}
         * @example
         * Predicate.Cast(IsNumber)
         */
        static Cast(Fn) {
            if (!(Fn is Func)) {
                throw TypeError("Expected a Func",, Type(Fn))
            }
            ObjSetBase(Fn, this.Prototype)
            return Fn
        }
    }
}