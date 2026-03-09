#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\String\String.ahk"

;@region Extensions

/**
 * Provides simple URL encoding and decoding for strings
 * (`application/x-www-form-urlencoded`).
 * 
 * The following rules apply during conversion:
 * - Alphanumeric characters and symbols `.`, `-`, `*`, `_` remain the same.
 * - The space character is converted into a plus sign `+`.
 * - All other characters are converted into bytes according to UTF-8, and
 *   each byte represented by the hexadecimal format `%HH`.
 * 
 * It's recommended to use only UTF-8 as encoding.
 * 
 * @module  <Net/UrlEncoding>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * ; --> "%C3%BCasdkj%28%7D%C3%9F"
 * "üasdkj(}ß".UrlEncode()
 * 
 * ; --> "üasdkj(}ß"
 * "%C3%BCasdkj%28%7D%C3%9F".UrlDecode()
 */
class AquaHotkey_UrlEncoding extends AquaHotkey {
    class String {
        /**
         * URL-encodes the string.
         * 
         * @param   {String?}  Encoding  character encoding (default: "UTF-8")
         * @returns {String}
         * @note    UTF-8 is recommended as per RFC 3986 specification
         * @example
         * ; --> "%C3%BCasdkj%28%7D%C3%9F"
         * "üasdkj(}ß".UrlEncode()
         */
        UrlEncode(Encoding := "UTF-8") => UrlEncode(this, Encoding)

        /**
         * URL-decodes the string.
         * 
         * @param   {String?}  Encoding  character encoding (default: "UTF-8")
         * @returns {String}
         * @note    UTF-8 is recommended as per RFC 3986 specification
         * @example
         * ; --> "üasdkj(}ß"
         * "%C3%BCasdkj%28%7D%C3%9F".UrlDecode()
         */
        UrlDecode(Encoding := "UTF-8") => UrlDecode(this, Encoding)
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region UrlEncode()

/**
 * URL-encodes a string.
 * 
 * @param   {String}   Str       input string
 * @param   {String?}  Encoding  character encoding (default: "UTF-8")
 * @returns {String}
 * @note    UTF-8 is recommended as per RFC 3986 specification
 * @example
 * ; --> "%C3%BCasdkj%28%7D%C3%9F"
 * "üasdkj(}ß".UrlEncode()
 */
UrlEncode(Str, Encoding := "UTF-8") {
    static NEEDS_ENCODING := "[^\w+.*-]"
    static Hex := ["0", "1", "2", "3", "4", "5", "6", "7",
                   "8", "9", "A", "B", "C", "D", "E", "F"]

    if (InStr(Str, " ")) {
        Str := StrReplace(Str, " ", "+")
    }
    if (!(Str ~= NEEDS_ENCODING)) {
        return Str
    }

    VarSetStrCapacity(&Result, StrLen(Str))
    p := 1
    Buf := Buffer(5, 0)
    NullTerminatorSize := StrPut("", Encoding)

    loop {
        q := RegExMatch(Str, NEEDS_ENCODING, unset, p)
        if (!q) {
            return Result . SubStr(Str, p)
        } else {
            Result .= SubStr(Str, p, q - p)
        }

        Char := SubStr(Str, q, 1)
        BytesWritten := StrPut(Char, Buf, Encoding)
        loop (BytesWritten - NullTerminatorSize) {
            Byte := NumGet(Buf, A_Index - 1, "UChar")
            Result .= "%"
            Result .= Hex[(Byte >>> 4) + 1]
            Result .= Hex[(Byte & 0xF) + 1]
        }
        p := q + 1
    }
    return Result
}

;@endregion
;-------------------------------------------------------------------------------
;@region UrlDecode()

/**
 * URL-decodes a string.
 * 
 * @param   {String}   Str       input string
 * @param   {String?}  Encoding  character encoding (default: "UTF-8")
 * @returns {String}
 * @note    UTF-8 is recommended as per RFC 3986 specification
 * @example
 * ; --> "üasdkj(}ß"
 * "%C3%BCasdkj%28%7D%C3%9F".UrlDecode()
 */
UrlDecode(Str, Encoding := "UTF-8") {
    if (InStr(Str, "+")) {
        Str := StrReplace(Str, "+", " ")
    }
    if (!InStr(Str, "%")) {
        return Str
    }

    VarSetStrCapacity(&Result, StrLen(Str))
    Len := StrLen(Str)
    p := 1
    loop {
        q := InStr(Str, "%", unset, p)
        if (!q) {
            return Result . SubStr(Str, p)
        } else {
            Result .= SubStr(Str, p, q - p)
            p := q
        }

        Buf := Buffer((Len - p + 1) // 3, 0)
        Pos := 0
        while (((p + 2) <= Len) && (SubStr(Str, p, 1) == "%")) {
            Hex := SubStr(Str, p + 1, 2)
            if (!IsXDigit(Hex)) {
                throw ValueError("Invalid hexadecimal",, Hex)
            }
            NumPut("UChar", Integer("0x" . Hex), Buf, Pos++)
            p += 3
        }
        if (SubStr(Str, p, 1) == "%") {
            throw ValueError("Incomplete percent-escape at index " . p,,
                                SubStr(Str, p + 1, 2))
        }
        Result .= StrGet(Buf, Encoding)
    }
}

;@endregion
;-------------------------------------------------------------------------------
