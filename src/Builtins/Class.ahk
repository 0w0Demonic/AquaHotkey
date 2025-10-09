#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
/**
 * AquaHotkey - Class.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Class.ahk
 */
class AquaHotkey_Class extends AquaHotkey {
class Class {
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
} ; class Class
} ; class AquaHotkey_Class extends AquaHotkey