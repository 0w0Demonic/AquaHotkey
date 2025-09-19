class AquaHotkey_Class extends AquaHotkey {
/**
 * AquaHotkey - Class.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Class.ahk
 */
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

    /**
     * Returns a class by the given name.
     * 
     * @example
     * (Class.ForName("Gui.ActiveX") == Gui.ActiveX) ; true
     * 
     * @param   {String}  ClassName  name of a class
     * @returns {Class}
     */
    static ForName(ClassName) {
        static Deref1(this)    => %this%
        static Deref2(VarName) => %VarName%
        static Cache := (M := Map(), M.CaseSense := false, M)

        if (IsObject(ClassName)) {
            throw TypeError("Expected a String, but received an Object",,
                            Type(ClassName))
        }
        if (ClassObj := Cache.Get(ClassName, false)) {
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
                throw TypeError("Expected a Class object",, Type(ClassObj))
            }
        }
        return (Cache[ClassName] := ClassObj)
    }

    /**
     * Returns the string representation of the class.
     * 
     * @example
     * Gui.ToString() ; "Class Gui"
     * 
     * @returns {String}
     */
    ToString() => "Class " . this.Prototype.__Class
} ; class Class
} ; class AquaHotkey_Class extends AquaHotkey