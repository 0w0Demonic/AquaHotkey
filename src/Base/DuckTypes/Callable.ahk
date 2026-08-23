#Include "%A_LineFile%\..\..\..\Base\DuckTypes.ahk"

/**
 * @duck
 * 
 * A {@link AquaHotkey_DuckTypes duck type} that represents any callable
 * object `HasMethod()`. This potentially includes values that are no objects.
 * 
 * @module  <Base/DuckTypes/Callable>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Callable extends Any {
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
    static IsInstance(Val?) => IsSet(Val) && HasMethod(Val)

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
    static CanCastFrom(T?) => IsSet(T) && (T is Class) && HasMethod(T.Prototype)
}
