class AquaHotkey_ComValueRef extends AquaHotkey {
/**
 * AquaHotkey - ComValueRef.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/classes/ComValueRef.ahk
 */
class ComValueRef {
    Get() {
        return this[]
    }

    Set(Value) {
        this[] := Value
        return this
    }
} ; class ComValueRef
} ; class AquaHotkey_ComValueRef extends AquaHotkey