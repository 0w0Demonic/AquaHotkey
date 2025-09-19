class AquaHotkey_VarRef extends AquaHotkey {
/**
 * AquaHotkey - VarRef.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/VarRef.ahk
 */
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
            if (IsSetRef(this)) {
                if (%this% is String) {
                    return StrPtr(%this%)
                }
                if (%this% is Object) {
                    if (HasProp(%this%, "Ptr")) {
                        return %this%.Ptr
                    }
                    return ObjPtr(%this%)
                }
                Msg   := "invalid type: " . Type(%this%)
                throw TypeError(Msg,, this.ToString())
            }
            Msg   := "unset value"
            throw UnsetError(Msg,, this.ToString())
        }
    }

    /**
     * Returns a string representation of the reference.
     * 
     * @example
     * Bar := &(Foo := 2)
     * Bar.ToString() ; "&Foo"
     * 
     * @returns {String}
     */
    ToString() {
        pName := NumGet(ObjPtr(this) + 8 + 6 * A_PtrSize, "Ptr")
        return "&" . StrGet(pName, "UTF-16") 
    }
} ; class VarRef
} ; class AquaHotkey_VarRef extends AquaHotkey