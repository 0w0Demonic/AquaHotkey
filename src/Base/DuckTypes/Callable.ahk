#Include "%A_LineFile%\..\..\DuckTypes.ahk"

/**
 * @duck
 * 
 * A {@link AquaHotkey_DuckTypes duck type} that represents any callable
 * object `HasMethod()`. By convention (and any amount of self-respect),
 * primitive values can *never* be considered callable.
 * 
 * @module  <Base/DuckTypes/Callable>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Callable extends Object {
    /**
     * Determines whether the value is a callable object, excluding `.__Call()`.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * "example".Is(Callable)                        ; false
     * Callable.IsInstance(MsgBox)                   ; true
     * ({ Call: (this) => this.Value }).Is(Callable) ; true
     */
    static IsInstance(Val?) => IsSet(Val) && IsObject(Val) && HasMethod(Val)

    /**
     * Determines whether the given value is equal to this class,
     * or its subclass.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * ; --> true
     * Callable.CanCastFrom(Func)
     */
    static CanCastFrom(T?) {
        return IsSet(T) && (super.CanCastFrom(T) || Func.CanCastFrom(T))
    }
}
