#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
/**
 * AquaHotkey - Any.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Any.ahk
 */
class AquaHotkey_Any extends AquaHotkey {
class Any {
    ;@region Type Info
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
            static Deref1(this)    => %this%
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
    ;@endregion
} ; class Any
} ; class AquaHotkey_Any extends AquaHotkey