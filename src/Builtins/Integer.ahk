class AquaHotkey_Integer extends AquaHotkey {
/**
 * AquaHotkey - Integer.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Integer.ahk
 */
class Integer {
    /**
     * Returns the hexadecimal representation of the string.
     * 
     * @example
     * (255).ToHexString() ; "FF"
     * 
     * @return  {String}
     */
    ToHexString() => Format("{:x}", this)

    /**
     * Returns the binary representation of the string.
     * 
     * @example
     * (32).ToBinaryString() ; "100000"
     * 
     * @return  {String}
     */
    ToBinaryString() {
        Buf := Buffer(64)
        x := this
        i := 63
        Loop {
            NumPut("UChar", 0x30 + (x & 1), Buf.Ptr + i--)
            x >>>= 1
        } Until (!x)
        return StrGet(Buf.Ptr + i + 1, "UTF-8", 64 - i)
    }

    /**
     * Returns the signum of this integer.
     * 
     * @example
     * (12).Signum()   ; 1
     * (0).Signum()    ; 0
     * (-863).Signum() ; -1
     * 
     * @return  {Integer}
     */
    Signum() => (this >> 63) | (-this >>> 63)
} ; class Integer
} ; class AquaHotkey_Integer extends AquaHotkey