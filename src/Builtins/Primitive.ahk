class AquaHotkey_Primitive extends AquaHotkey {
/**
 * AquaHotkey - Primitive.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Primitive.ahk
 */
class Primitive {
    /**
     * Returns itself. This method allows you to call `.Clone()` on every
     * single type (except for e.g. `ComObject`).
     * 
     * @returns {Primitive}
     */
    Clone() => this

    /**
     * Outputs the value as text inside a message box.
     * 
     * @example
     * "Hello, world!".MsgBox("AquaHotkey", MsgBox.Icon.Info)
     * 
     * @param   {String?}     Title    message box title
     * @param   {Primitive?}  Options  additional `MsgBox` options
     * @returns {this}
     */
    MsgBox(Title?, Options?) {
        MsgBox(this, Title?, Options?)
        return this
    }

    /**
     * Outputs the value on a tooltip control.
     * 
     * @example
     * "Hello, world!".ToolTip(50, 50, 1)
     * 
     * @param   {Integer?}  x             x-coordinate
     * @param   {Integer?}  y             y-coordinate
     * @param   {Integer?}  WhichToolTip  which tooltip to operate on
     * @returns {this}
     */
    ToolTip(x?, y?, WhichToolTip?) {
        ToolTip(this, x?, y?, WhichToolTip?)
        return this
    }

    /**
     * Outputs the value using `Send()`.
     * 
     * @example
     * "Four score and seven years ago".Send()
     * 
     * @returns {this}
     */
    Send() {
        Send(this)
        return this
    }

    /**
     * Outputs the value using `SendText()`.
     * 
     * @example
     * "Four score and seven years ago".SendText()
     * 
     * @returns {this}
     */
    SendText() {
        SendText(this)
        return this
    }

    /**
     * Outputs the value using `SendPlay()`.
     * 
     * @example
     * "Four score and seven years ago".SendPlay()
     * 
     * @returns {this}
     */
    SendPlay() {
        SendPlay(this)
        return this
    }

    /**
     * Outputs the value using `SendEvent()`.
     * 
     * @example
     * "Four score and seven years ago".SendEvent()
     * 
     * @returns {this}
     */
    SendEvent() {
        SendEvent(this)
        return this
    }

    /**
     * Converts the value into a float.
     * 
     * @example
     * (1).ToFloat() ; 1.0
     * 
     * @returns {Float}
     */
    ToFloat() => Float(this)

    /**
     * Converts the value to a number.
     * 
     * @example
     * "912".ToNumber() ; 912
     * "8.2".ToNumber() ; 8.2
     * 
     * @returns {Number}
     */
    ToNumber() => Number(this)

    /**
     * Converts the value to an integer.
     * 
     * @example
     * (8.34).ToInteger() ; 8
     * 
     * @returns {Integer}
     */
    ToInteger() => Integer(this)

    /**
     * Converts the value to a string.
     * 
     * @example
     * (12).ToString() ; "12"
     * 
     * @returns {String}
     */
    ToString() => String(this)

    /**
     * Puts the value into the system clipboard.
     * 
     * @example
     * "This is the new clipboard content".ToClipboard()
     * 
     * @returns {this}
     */
    ToClipboard() => (A_Clipboard := this)

    /**
     * Formats the variable by using the given `Pattern`, followed by zero or
     * more additional `Args*`.
     * 
     * @example
     * "world".FormatTo("{2}, {1}!", "Hello") ; "Hello, world!"
     * 
     * @param   {String}  Pattern  format pattern to use
     * @param   {Any*}    Args     zero or more additional arguments
     * @returns {String}
     */
    FormatTo(Pattern, Args*) {
        StringReprs := Array()
        StringReprs.Capacity := Args.Length
        for Value in Args {
            if (IsSet(Value)) {
                StringReprs.Push(String(Value))
            } else {
                StringReprs.Length++
            }
        }
        return Format(Pattern, this, StringReprs*)
    }
} ; class Primitive
} ; class AquaHotkey_Primitive extends AquaHotkey