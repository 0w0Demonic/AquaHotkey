#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Error utility.
 * 
 * @module  <Base/Error>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Error extends AquaHotkey {
class Error {
    ;@region Throwing

    /**
     * Throws an error of the given error type.
     * 
     * @example
     * TargetError.Throw("unable to find window", -1, "ahk_exe notepad.exe")
     * 
     * @param   {String?}     Msg    message of the error object
     * @param   {Primitive?}  What   what threw the exception
     * @param   {Primitive?}  Extra  additional details about the error
     */
    static Throw(Msg?, What?, Extra?) {
        throw this(Msg?, What?, Extra?)
    }

    /**
     * Throws this error.
     * 
     * @throws {Error} this error object
     */
    Throw() {
        throw this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Error Causes

    /**
     * Specifies the cause of this error, appending additional information
     * to its stack.
     * 
     * @param   {Error}  Cause  the cause of this error
     * @returns {this}
     */
    CausedBy(Cause) {
        if (!(Cause is Error)) {
            return this
        }

        this.Stack .= "`r`nCaused by: " . Type(Cause) . ": " . Cause.Message
        if (StrLen(Cause.Extra)) {
            this.Stack .= "`r`nSpecifically: " . Cause.Extra
        }
        this.Stack .= "`r`n" . Cause.Stack
        this.DefineProp("Cause", { Value: Cause })
        return this
    }

    /**
     * Retrieves and sets the cause of this error.
     * 
     * @returns {Error}
     */
    Cause {
        get => false
        set {
            if (!(this is Error)) {
                throw TypeError("Expected an Error",, Type(this))
            }
            if (!(value is Error)) {
                throw TypeError("Expected an Error",, Type(value))
            }
            if (!IsSet(value)) {
                throw UnsetError("Value is unset")
            }
            this.DefineProp("Cause", { Value: value })
        }
    }

    ;@endregion
} ; class Error
} ; class AquaHotkey_Error extends AquaHotkey