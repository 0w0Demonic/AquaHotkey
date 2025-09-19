class AquaHotkey_InputHook extends AquaHotkey {
/**
 * AquaHotkey - InputHook.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/InputHook.ahk
 */
class InputHook {
    /**
     * Returns the key name associated with virtual key code `VK` and
     * scan code `SC`.
     * 
     * @param   {Integer}  VK  virtual key code
     * @param   {Integer}  SC  scan code
     * @returns {String}
     */
    static GetKeyName(VK, SC) {
        return GetKeyName(Format("vk{:x}sc{:x}", VK, SC))
    }
} ; class InputHook
} ; class AquaHotkey_InputHook extends AquaHotkey