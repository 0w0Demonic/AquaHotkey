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
     * Returns a hexadecimal representation of this string.
     * @example
     * 
     * (255).ToHexString() ; "FF"
     * 
     * @return  {String}
     */
    ToHexString() => Format("{:x}", this)

    /**
     * Returns a binary representation of this string.
     * @example
     * 
     * (32).ToBinaryString() ; "100000"
     * 
     * @return  {String}
     */
    ToBinaryString() {
        i := this
        Result := ""
        while (i) {
            Result .= i & i
            i >>>= 1
        }
        return Result.Reversed()
    }

    /**
     * Returns the signum of this integer.
     * @example
     * 
     * (12).Signum()   ; 1
     * (0).Signum()    ; 0
     * (-863).Signum() ; -1
     * 
     * @return  {Integer}
     */
    Signum() => (this >> 63) | (-this >>> 63)
} ; class Integer
} ; class AquaHotkey_Integer extends AquaHotkey