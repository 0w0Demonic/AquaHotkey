#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * VarRef utility.
 * 
 * @module  <Base/VarRef>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_VarRef extends AquaHotkey {
class VarRef {
    /**
     * Returns the pointer of the value behind the reference.
     * This is particularly useful for passing strings to `DllCall()`
     * by reference.
     * 
     * @returns {Integer}
     * @example
     * Str := "Hello, world!"
     * DllCall("...", "Ptr", &Str)
     */
    Ptr {
        Get {
            if (!IsSetRef(this)) {
                throw UnsetError("unset value")
            }
            if (!IsObject(%this%)) {
                return StrPtr(%this%)
            }
            if (HasProp(%this%, "Ptr")) {
                return %this%.Ptr
            }
            return ObjPtr(%this%)
        }
    }
} ; class VarRef
} ; class AquaHotkey_VarRef extends AquaHotkey