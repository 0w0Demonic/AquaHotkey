#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Utility applicable to primitive types and numbers.
 * 
 * @module  <Primitives/Primitive>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Primitives extends AquaHotkey {
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

    class Integer {
        /**
         * Returns the hexadecimal representation of the string.
         * 
         * @returns {String}
         * @example
         * (255).Hex() ; "FF"
         */
        Hex() => Format("{:x}", this)

        /**
         * Returns the binary representation of the string.
         * 
         * @returns {String}
         * @example
         * (32).Bin() ; "100000"
         */
        Bin() {
            Buf := Buffer(64)
            x := this
            i := 63
            loop {
                NumPut("UChar", 0x30 + (x & 1), Buf.Ptr + i--)
                x >>>= 1
            } until (!x)
            return StrGet(Buf.Ptr + i + 1, "UTF-8", 64 - i)
        }

        /**
         * Returns the signum of this integer.
         * 
         * @returns {Integer}
         * @example
         * (12).Signum()   ; 1
         * (0).Signum()    ; 0
         * (-863).Signum() ; -1
         */
        Signum() => (this >> 63) | (-this >>> 63)
    }

    class Number {
        /**
         * Constants pi and e.
         */
        static PI => 3.14159265358979
        static E  => 2.71828182845905
        
        /**
         * Built-in math functions.
         */
        Abs()     => Abs(this)
        ASin()    => ASin(this)
        ACos()    => ACos(this)
        ATan()    => ATan(this)
        Ceil()    => Ceil(this)
        Chr()     => Chr(this)
        Cos()     => Cos(this)
        Exp()     => Exp(this)
        Floor()   => Floor(this)
        Ln()      => Ln(this)
        Mod(N)    => Mod(this, N)
        Round(N?) => Round(this, N?)
        Sin()     => Sin(this)
        Sqrt()    => Sqrt(this)
        Tan()     => Tan(this)

        /**
         * Returns the logarithm base `BaseN` of this number.
         * 
         * @param   {Number}  BaseN  logarithm base
         * @returns {Float}
         * @example
         * (32).Log(2) ; 5.0
         */
        Log(BaseN := 10) => (Log(this) / Log(BaseN))
    }

}