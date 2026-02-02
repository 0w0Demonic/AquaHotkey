#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * This module provides function piping operations like in shell languages
 * such as Bash or PowerShell.
 * 
 * It allows "forwarding" the current value into a function as its first
 * argument, followed by zero or more values `Args*`.
 * 
 * This is done by using the `.o0()` method, which accepts the next function,
 * followed by zero or more `Args*`.
 * 
 * @example
 * DoThis(A) => ...
 * DoThat(A, B, C) => ...
 * 
 * MyVar.o0(DoThis).o0(DoThat, "foo", { bar: "" }).o0(MsgBox)
 * 
 * ; equivalent to:
 * MsgBox(DoThat(DoThat(MyVar), "foo", { bar: "" }))
 * 
 * @module  <Func/Pipes>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Pipes extends AquaHotkey {
    class Any {
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
}
