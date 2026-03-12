#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * String utility.
 * 
 * @module  <String/String>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * for Character in "Hello, world!" {
 *     ...
 * }
 * 
 * @example
 * "apple banana pear".Split(" ").ForEach(MsgBox)
 */
class AquaHotkey_String extends AquaHotkey {
    class String {
        ;@region Enumeration

        /**
         * Enumerates all characters in the string.
         * 
         * @param   {Integer}  n  parameter length of the for-loop
         * @returns {Enumerator}
         * @example
         * for Character in "Hello, world!" {
         *     MsgBox(Character)
         * }
         * 
         * for Index, Character in "Hello, world!" {
         *     MsgBox(Index . ": " . Character)
         * }
         */
        __Enum(n) {
            Pos := 0
            Len := StrLen(this)
            return (n > 1) ? Enumer2 : Enumer1
            
            ; for Character in ...
            Enumer1(&Out) {
                if (Pos < Len) {
                    Out := StrGet(StrPtr(this) + 2 * Pos++, 1)
                    return true
                }
                return false
            }
            
            ; for Index, Character in ...
            Enumer2(&OutIdx, &Out?) {
                if (Pos < Len) {
                    Out    := StrGet(StrPtr(this) + 2 * Pos++, 1)
                    OutIdx := Pos
                    return true
                }
                return false
            }
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Splitting

        /**
         * Separates the string into an array of substrings using `Delimiter`.
         * 
         * @param   {String?/Array?}  Delimiters  boundaries between substrings
         * @param   {String?}         OmitChars   list of characters to trim
         * @param   {Integer}         MaxParts    maximum number of substrings
         * @returns {Array}
         * @example
         * "a,b,c".Split(",") ; ["a", "b", "c"]
         */
        Split(Delimiters := "", OmitChars?, MaxParts?) {
            return StrSplit(this, Delimiters?, OmitChars?, MaxParts?)
        }

        /**
         * Splits the string into an array of separate lines.
         * 
         * @returns  {Array}
         * @example
         * "
         * (
         * Hello,
         * world!
         * )".Lines() ; ["Hello,", "world!"]
         */
        Lines() => StrSplit(this, "`n", "`r")

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Concatenation

        /**
         * Returns this string prepended by `Before`.
         * 
         * @param   {String}  Before  string to prepend
         * @returns {String}
         * @example
         * "world!".Prepend("Hello, ") ; "Hello, world!"
         */ 
        Prepend(Before) => (Before . this)

        /**
         * Returns this string appended with `After`.
         * 
         * @param   {String}  After  string to append
         * @returns {String}
         * @example
         * "Hello, ".Append("world!") ; "Hello, world!"
         */
        Append(After) => (this . After)
        
        /**
         * Returns a new string surrounded by `Before` and `After`.
         * 
         * @param   {String}   Before  string to prepend
         * @param   {String?}  After   string to append
         * @returns {String}
         * @example
         * "foo".Surround("(", ")") ; "(foo)"
         * "foo".Surround("_")      ; "_foo_"
         */
        Surround(Before, After := Before) => (Before . this . After)

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Misc.

        /**
         * Returns this string repeated `n` times.
         * 
         * @param   {Integer}  n  amount of times to repeat the string
         * @returns {String}
         * @example
         * "foo".Repeat(3) ; "foofoofoo"
         */
        Repeat(n) {
            if (!IsInteger(n)) {
                throw TypeError("Expected an Integer",, Type(n))
            }
            if (n < 0) {
                throw ValueError("n < 0",, n)
            }
            n_Amount_Of_Spaces := Format("{: " . n . "}", " ")
            return StrReplace(n_Amount_Of_Spaces, A_Space, this)
        }

        /**
         * Returns this string with all characters in reverse order.
         * 
         * @returns {String}
         * @example
         * "foo".Reversed() ; "oof"
         */
        Reversed() {
            DllCall("msvcrt.dll\_wcsrev", "Str", Str := this, "CDecl Str")
            return Str
        }
        
        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Properties

        /**
         * Returns the length of the string in characters.
         * 
         * @returns {Integer}
         * @example
         * "Hello".Length   ; 5
         */
        Length => StrLen(this)

        /**
         * Returns the length of this string in bytes with the specified
         * `Encoding`. See `<Collections/ByteArray>` for converting strings into
         * arrays of bytes.
         * 
         * @param   {Primitive?}  Encoding               string encoding
         * @param   {Boolean}     IncludeNullTerminator  include null terminator
         * @returns {Integer}
         * @see {@link ByteArray.OfString()}
         * @example
         * "Hello, world!".SizeInBytes ; UTF-16: (13 + 1) * 2 = 28 bytes
         * "foo".SizeInBytes["UTF-8"]  ; 4
         */
        SizeInBytes[Encoding := "UTF-16", IncludeNullTerminator := true] {
          get {
            Size := StrPut(this, Encoding)
            if (!IncludeNullTerminator) {
                Size -= StrPut("", Encoding)
            }
            return Size
          }
        }

        ;@endregion
    }
}