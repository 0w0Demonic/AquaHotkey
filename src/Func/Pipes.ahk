#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
/**
 * AquaHotkey - Pipes.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Pipes.ahk
 */
class AquaHotkey_Pipes extends AquaHotkey {
;@region Any
class Any {
    /**
     * Whenever an undefined method is called, forwards the variable to a
     * global function as its first parameter.
     * 
     * @example 
     * MyVariable.DoThis().DoThat(Arg3, Arg3).MsgBox()
     * 
     * @param   {String}  FunctionName  name of the global function
     * @param   {Any*}    Args          additional arguments
     * @returns {Any}
     */
    __Call(Name, Args) {
        static Deref1(this) => %this%
        static Deref2(VarName) => %VarName%

        ; try to do name-dereference
        try {
            Fn := ((Name != "this") ? Deref1 : Deref2)(Name)
        }
        catch {
            throw UnsetError("(__Call) not found",, Name)
        }
        if (HasMethod(Fn)) {
            return Fn(this, Args*)
        }
        throw TypeError("(__Call) expected a function: " . Name,, Type(Fn))
    }

    /**
     * Explicitly forwards this variable to a function `f` as its first
     * parameter, followed by zero or more additional arguments `Args*`.
     * 
     * Make use of `BoundFunc`s when piping to methods.
     * 
     * @example
     * MyVariable.o0(DoSomething, Arg2, Arg3)
     *           .o0(Foo.BindMethod("Bar"))
     * 
     * DoSomething(x, y, z) => ...
     * class Foo {
     *     static Bar(x) => ...
     * }
     * 
     * @param   {Func}  f     a function to forward to
     * @param   {Any*}  Args  zero or more additional arguments
     * @returns {Any}
     */
    o0(f, Args*) => f(this, Args*)
}
;@endregion

;@region Class
class Class {
    /**
     * Override of `Any.Prototype.__Call()` that throws an error.
     * @override `Any.Prototype.__Call()`
     * 
     * @example
     * Foo(Value) {
     *     MsgBox(Type(Value))
     * }
     * String.Foo() ; Error!
     * 
     * @param   {String}  MethodName  the name of the undefined method
     * @param   {Array}   Args        zero or more additional arguments
     */
    __Call(MethodName, *) {
        throw MethodError("undefined static method: " . MethodName,, Type(this))
    }
} ; class Class
;@endregion
} ; class AquaHotkey_Pipes extends AquaHotkey