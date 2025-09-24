/**
 * AquaHotkey - Number.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Number.ahk
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
    __Call(FunctionName, Args) {
        ; dereferences a variable in global namespace
        static Deref1(this) {
            return %this%
        }
        ; edge case whenever `FunctionName == "this"`
        static Deref2(VarName) {
            return %VarName%
        }

        ; a map that keeps track of function objects
        static Cache := (M := Map(), M.CaseSense := false, M)

        ; lookup in cache
        if (Function := Cache.Get(FunctionName, false)) {
            return Function(this, Args*)
        }

        ; try to do name-dereference
        try
        {
            if (FunctionName != "this") {
                Function := Deref1(FunctionName)
            } else {
                Function := Deref2(FunctionName)
            }
        }
        catch {
            throw UnsetError("(__Call) variable not found: " . FunctionName,,
                             FunctionName)
        }

        ; assert that this variable has a `Call` method
        if (!HasMethod(Function)) {
            throw TypeError("(__Call) variable not callable: " . FunctionName,,
                            Type(Function))
        }

        ; make the function object delete the cache entry as soon as it
        ; loses its last reference
        try __DeletePrevious := Function.__Delete
        ; define a `.__Delete()` method that removes the cache entry
        Function.DefineProp("__Delete", { Call: __Delete })
        __Delete(Instance) {
            try __DeletePrevious(Instance)
            try Cache.Delete(FunctionName)
        }
        ; add entry in cache
        Cache[FunctionName] := Function

        ; finally, call the function and return its result
        return Function(this, Args*)
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