#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Utility applicable to all primitve types.
 * 
 * @module  <Primitives/Primitive>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Primitive extends AquaHotkey {
    class Primitive {
        /**
         * Outputs the value as text inside a message box.
         * 
         * @param   {String?}     Title    message box title
         * @param   {Primitive?}  Options  additional `MsgBox` options
         * @returns {this}
         * @example
         * "Hello, world!".MsgBox("AquaHotkey", MsgBox.Icon.Info)
         */
        MsgBox(Title?, Options?) {
            MsgBox(this, Title?, Options?)
            return this
        }

        /**
         * Outputs the value on a tooltip control.
         * 
         * @param   {Integer?}  x             x-coordinate
         * @param   {Integer?}  y             y-coordinate
         * @param   {Integer?}  WhichToolTip  which tooltip to operate on
         * @returns {this}
         * @example
         * "Hello, world!".ToolTip(50, 50, 1)
         */
        ToolTip(x?, y?, WhichToolTip?) {
            ToolTip(this, x?, y?, WhichToolTip?)
            return this
        }

        /**
         * Outputs the value using `Send()`.
         * 
         * @returns {this}
         * @example
         * "Four score and seven years ago".Send()
         */
        Send() {
            Send(this)
            return this
        }

        /**
         * Outputs the value using `SendText()`.
         * 
         * @returns {this}
         * @example
         * "Four score and seven years ago".SendText()
         */
        SendText() {
            SendText(this)
            return this
        }

        /**
         * Outputs the value using `SendPlay()`.
         * 
         * @returns {this}
         * @example
         * "Four score and seven years ago".SendPlay()
         */
        SendPlay() {
            SendPlay(this)
            return this
        }

        /**
         * Outputs the value using `SendEvent()`.
         * 
         * @returns {this}
         * @example
         * "Four score and seven years ago".SendEvent()
         */
        SendEvent() {
            SendEvent(this)
            return this
        }

        /**
         * Converts the value into a float.
         * 
         * @returns {Float}
         * @example
         * (1).ToFloat() ; 1.0
         */
        ToFloat() => Float(this)

        /**
         * Converts the value to a number.
         * 
         * @returns {Number}
         * @example
         * "912".ToNumber() ; 912
         * "8.2".ToNumber() ; 8.2
         */
        ToNumber() => Number(this)

        /**
         * Converts the value to an integer.
         * 
         * @returns {Integer}
         * @example
         * (8.34).ToInteger() ; 8
         */
        ToInteger() => Integer(this)

        /**
         * Puts the value into the system clipboard.
         * 
         * @returns {this}
         * @example
         * "This is the new clipboard content".ToClipboard()
         */
        ToClipboard() => (A_Clipboard := this)
    }
}