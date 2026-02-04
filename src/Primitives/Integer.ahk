#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Utils applicable to integers.
 * 
 * @module  <Primitives/Integer>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Integer extends AquaHotkey {
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
}