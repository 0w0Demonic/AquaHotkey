#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
/**
 * AquaHotkey - VarRef.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/VarRef.ahk
 */
class AquaHotkey_VarRef extends AquaHotkey {
class VarRef {
    /**
     * Returns the pointer of the value behind the reference.
     * This is particularly useful for passing strings to `DllCall()`
     * by reference.
     * 
     * @example
     * Str := "Hello, world!"
     * DllCall("...", "Ptr", &Str)
     * 
     * @returns {Integer}
     */
    Ptr {
        Get {
            if (!IsSetRef(this)) {
                throw UnsetError("unset value")
            }
            if (%this% is String) {
                return StrPtr(%this%)
            }
            if (IsObject(%this%)) {
                if (HasProp(%this%, "Ptr")) {
                    return %this%.Ptr
                }
                return ObjPtr(%this%)
            }
            throw TypeError("invalid type",, Type(%this%))
        }
    }
} ; class VarRef
} ; class AquaHotkey_VarRef extends AquaHotkey