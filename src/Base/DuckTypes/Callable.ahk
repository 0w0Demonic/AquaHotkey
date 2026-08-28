#Include "%A_LineFile%\..\..\..\Base\DuckTypes.ahk"

/**
 * @duck
 * 
 * A {@link AquaHotkey_DuckTypes duck type} that represents any callable
 * value for which `HasMethod()` returns `true`. This potentially includes
 * values that are no objects (`!IsObject()`).
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
     * Determines whether the input value is equivalent to, or a subtype of
     * callable. This is the case, if the input value is a class whose
     * prototype is callable. For example, the class `Func` defines
     * `Func.Prototype.Call`, which makes every instance of `Func` callable,
     * therefore `Callable.CanCastFrom(Func)`.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * Callable.CanCastFrom(Func) ; ==> true
     * class Iterator {
     *     Call() { ... } ; <-- defines `Prototype.Call`
     * }
     * Callable.CanCastFrom(Iterator) ; ==> true
     */
    static CanCastFrom(T?) => IsSet(T) && (T is Class) && HasMethod(T.Prototype)
}
