class AquaHotkey_Error extends AquaHotkey {
/**
 * AquaHotkey - Error.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Classes/Error.ahk
 */
class Error {
    /**
     * Throws an error of this class.
     * @example
     * 
     * TargetError.Throw("unable to find window", -1, "ahk_exe notepad.exe")
     * 
     * @param   {String?}     Msg    message of the error object
     * @param   {Primitive?}  What   what threw the exception
     * @param   {Primitive?}  Extra  additional details about the error
     */
    static Throw(Msg?, What?, Extra?) {
        throw this(Msg?, What?, Extra?)
    }
} ; class Error
} ; class AquaHotkey_Error extends AquaHotkey