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
         * @param   {String?}     Msg    message of the error object
         * @param   {Primitive?}  What   what threw the exception
         * @param   {Primitive?}  Extra  additional details about the error
         * @example
         * TargetError.Throw("unable to find window", -1, "ahk_exe notepad.exe")
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
        ;-----------------------------------------------------------------------
        ;@region Error Causes

        /**
         * Specifies the cause of this error, appending additional information
         * to its stack.
         * 
         * @param   {Error}  Cause  the cause of this error
         * @returns {this}
         * @example
         * throw OuterErr.CausedBy( MiddleErr.CausedBy( InnerErr ) )
         */
        CausedBy(Cause) {
            if (!(Cause is Error)) {
                return this
            }

            this.Stack .= "`r`nCaused by: " . Type(Cause) . ": " . Cause.Message
            if (Cause.Extra != "") {
                this.Stack .= "`r`nSpecifically: " . Cause.Extra
            }
            this.Stack .= "`r`n" . Cause.Stack
            this.DefineProp("Cause", { Get: (_) => Cause })
            return this
        }

        /**
         * Specifies that this error causes another given error `Err`,
         * appending additional information to its stack.
         * 
         * @param   {Error}  Err  error caused by this error
         * @returns {Error}
         * @example
         * throw InnerErr.Causing(MiddleErr).Causing(OuterErr)
         */
        Causing(Err) {
            if (!(Err is Error)) {
                return this
            }
            return Err.CausedBy(this)
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
                    throw ValueError("cannot call method from prototype")
                }
                if (!(value is Error)) {
                    throw TypeError("expected an Error",, Type(value))
                }
                if (!IsSet(value)) {
                    ({}.DeleteProp)(this, "Cause")
                } else {
                    ({}.DefineProp)(this, "Cause", { Get: (_) => value })
                }
            }
        }

        ;@endregion
    }
}