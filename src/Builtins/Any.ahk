class AquaHotkey_Any extends AquaHotkey {
/**
 * AquaHotkey - Any.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Any.ahk
 */
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

    /**
     * Returns the type of this variable in the same way as built-in `Type()`.
     * 
     * @example
     * "Hello, world!".Type ; "String"
     * 
     * @returns {String}
     */
    Type => Type(this)

    /**
     * Returns the type of this variable as a class.
     * 
     * @example
     * "Hello, world!".Class ; String
     * 
     * @returns {Class}
     */
    Class {
        Get {
            ; Types: ClassName => Class
            static Deref1(this) => %this%
            static Deref2(VarName) => %VarName%
            static Types := (
                M := Map(),
                M.CaseSense := false,
                M.Default := false,
                M)

            if (IsObject(this) && ObjHasOwnProp(this, "__Class")) {
                ; prototype objects
                ClassName := this.__Class
            } else {
                ; everything else
                ClassName := Type(this)
            }

            if (ClassObj := Types.Get(ClassName, false)) {
                return ClassObj
            }
            Loop Parse ClassName, "." {
                if (ClassObj) {
                    ClassObj := ClassObj.%A_LoopField%
                } else if (ClassName != "this") {
                    ClassObj := Deref1(A_LoopField)
                } else {
                    ClassObj := Deref2(A_LoopField)
                }
                if (!(ClassObj is Class)) {
                    throw TypeError("Expected a Class",, Type(ClassObj))
                }
            }
            Types.Set(ClassName, ClassObj)
            return ClassObj
        }
    }
} ; class Any
} ; class AquaHotkey_Any extends AquaHotkey