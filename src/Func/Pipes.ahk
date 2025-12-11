#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * This module provides function piping operations like in shell languages
 * such as Bash or PowerShell.
 * 
 * It allows "forwarding" the current value into a function as its first
 * argument, followed by zero or more values `Args*`.
 * 
 * This can be done "implicitly", i.e. calling an unknown property from a
 * value with the same name as a global function, or "explicitly",
 * via the `Any#o0()` method, passing the next function followed by zero
 * or more `Args*`.
 * 
 * Using `.o0()` is marginally faster and more flexible because it directly
 * accepts the next function instead of searching the global namespace.
 * 
 * @example
 * ; implicit
 * MyVar.DoThis().DoThat("foo", { bar: "" }).MsgBox()
 * 
 * ; explicit
 * MyVar.o0(DoThis).o0(DoThat, "foo", { bar: "" }).o0(MsgBox)
 * 
 * @module  <Func/Pipes>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Pipes extends AquaHotkey {
;@region Any
class Any {
    /**
     * Whenever an undefined method is called, forwards the variable to a
     * global function as its first parameter.
     * 
     * @example 
     * MyVariable.DoThis().DoThat("foo", "bar").MsgBox()
     * 
     * @param   {String}  Name  name of the global function
     * @param   {Any*}    Args  additional arguments
     * @returns {Any}
     */
    __Call(Name, Args) {
        ; try to do name-dereference
        try {
            Fn := (AquaHotkey.Deref)(Name)
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
     * 
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