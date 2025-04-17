class AquaHotkey_Hotkey extends AquaHotkey {
/**
 * AquaHotkey - Hotkey.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Functions/Hotkey.ahk
 */
class Hotkey {
    /**
     * Creates a hotkey which is callable only once.
     * 
     * @param   {String}   Key       hotkey activation key
     * @param   {Func}     Callback  the function to call
     * @param   {String?}  Options   additional options
     */
    static Once(Key, Callback, Options) {
        Handler(KeyPressed) {
            this(Key, "Off")
            Callback(KeyPressed)
        }
        this(Key, Handler, Options?)
    } ; class Hotkey
}} ; class AquaHotkey_Hotkey extends AquaHotkey