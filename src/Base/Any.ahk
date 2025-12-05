#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Adds universal properties for type information such as the type and class
 * of a value.
 * 
 * @module  <Base/Any>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Any extends AquaHotkey {
    class Any {
        ;@region Type Info
        /**
         * Returns the type of this variable in the same way as
         * built-in `Type()`.
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
         * "".Class.Type         ; "Class"
         * 
         * @returns {Class}
         */
        Class {
            Get {
                ; Types: ClassName => Class
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
                    ClassObj := (ClassObj) ? ClassObj.%A_LoopField%
                                           : (AquaHotkey.Deref)(A_LoopField)
                    
                    if (!(ClassObj is Class)) {
                        throw TypeError("Expected a Class",, Type(ClassObj))
                    }
                }
                Types.Set(ClassName, ClassObj)
                return ClassObj
            }
        }
        ;@endregion
    }
}