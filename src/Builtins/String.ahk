#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
/**
 * AquaHotkey - String.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/String.ahk
 */
class AquaHotkey_String extends AquaHotkey {
class String {
    /**
     * Enumerates all character in the stream.
     * 
     * @example
     * for Character in "Hello, world!" {
     *     MsgBox(Character)
     * }
     * 
     * for Index, Character in "Hello, world!" {
     *     MsgBox(Index . ": " . Character)
     * }
     * 
     * @param   {Integer}  n  parameter length of the for-loop
     * @returns {Enumerator}
     */
    __Enum(n) {
        Position := 0
        Length   := StrLen(this)
        if (n == 1) {
            return Enumer1
        }
        return Enumer2
        
        ; for Character in ...
        Enumer1(&Out) {
            if (Position < Length) {
                Out := StrGet(StrPtr(this) + 2 * Position++, 1)
                return true
            }
            return false
        }
        
        ; for Index, Character in ...
        Enumer2(&OutIndex, &Out?) {
            if (Position < Length) {
                Out      := StrGet(StrPtr(this) + 2 * Position++, 1)
                OutIndex := Position
                return true
            }
            return false
        }
    }

    /**
     * Splits the string into an array of separate lines.
     * 
     * @example
     * "
     * (
     * Hello,
     * world!
     * )".Lines() ; ["Hello,", "world!"]
     * 
     * @returns  {Array}
     */
    Lines() => StrSplit(this, "`n", "`r")

    /**
     * Returns this string prepended by `Before`.
     * 
     * @example
     * "world!".Prepend("Hello, ") ; "Hello, world!"
     * 
     * @param   {String}  Before  string to prepend
     * @returns {String}
     */ 
    Prepend(Before) => (Before . this)

    /**
     * Returns this string appended with `After`.
     * 
     * @example
     * "Hello, ".Append("world!") ; "Hello, world!"
     * 
     * @param   {String}  After  string to append
     * @returns {String}
     */
    Append(After) => (this . After)
    
    /**
     * Returns a new string surrounded by `Before` and `After`.
     * 
     * @example
     * "foo".Surround("(", ")") ; "(foo)"
     * "foo".Surround("_")      ; "_foo_"
     * 
     * @param   {String}   Before  string to prepend
     * @param   {String?}  After   string to append
     * @returns {String}
     */
    Surround(Before, After := Before) => (Before . this . After)

    /**
     * Returns this string repeated `n` times.
     * 
     * @example
     * "foo".Repeat(3) ; "foofoofoo"
     * 
     * @param   {Integer}  n  amount of times to repeat the string
     * @returns {String}
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
     * @example
     * "foo".Reversed() ; "oof"
     * 
     * @returns {String}
     */
    Reversed() {
        DllCall("msvcrt.dll\_wcsrev", "Str", Str := this, "CDecl Str")
        return Str
    }
    
    /**
     * Formats by using the string as format pattern.
     * 
     * If an object is passed, it is converted to a string by using its
     * `ToString() method`.
     * 
     * @example
     * "a: {}, b: {}".Formatted(2, 42) ; "a: 2, b: 42"
     * 
     * @param   {Any*}  Args  zero or more additional arguments
     * @returns {String}
     */ 
    Formatted(Args*) {
        Input := Array()
        for Value in Args {
            Input.Push(String(Input))
        }
        return Format(this, Input*)
    }

    /**
     * Replaces occurrences of `Pattern` in the string.
     * 
     * @example
     * "abz".Replace("z", "c") ; "abc"
     * 
     * @param   {String}      Pattern    string to replace
     * @param   {String?}     Rep        replacement string
     * @param   {Primitive?}  CaseSense  case-sensitivity
     * @param   {VarRef?}     Out        output of replacements that occurred
     * @param   {Integer?}    Limit      replacement limit
     * @returns {String}
     */
    Replace(Pattern, Rep := "", CaseSense := false, &Out?, Limit := -1) {
        return StrReplace(this, Pattern, Rep, CaseSense, &Out, Limit)
    }

    /**
     * Separates the string into an array of substrings using `Delimiter`.
     * 
     * @example
     * "a,b,c".Split(",") ; ["a", "b", "c"]
     * 
     * @param   {String?/Array?}  Delimiters  boundaries between substrings
     * @param   {String?}         OmitChars   list of characters to trim
     * @param   {Integer}         MaxParts    maximum number of substrings
     * @returns {Array}
     */
    Split(Delimiters := "", OmitChars?, MaxParts?) {
        return StrSplit(this, Delimiters?, OmitChars?, MaxParts?)
    }

    /**
     * Returns a substring at index `Start` and length `Length` in characters.
     * 
     * @example
     * "123abc789".Sub(4, 3) ; "abc"
     * 
     * @param   {Integer}   Start   starting index
     * @param   {Integer?}  Length  length in characters
     * @returns {String}
     */
    Sub(Start, Length?) => SubStr(this, Start, Length?)

    /**
     * Returns a substring at index `Start` and length `Length` in characters.
     * Unlike `SubStr()`, `Length` defaults to 1 when omitted.
     * 
     * @example
     * ("foo bar")[5] ; "b"
     * 
     * @param   {Integer}   Start   starting index
     * @param   {Integer?}  Length  length in characters
     * @returns {String}
     */
    __Item[Start, Length := 1] {
        Get {
            if (Abs(Start) > StrLen(this)) {
                throw ValueError("index out of bounds",, Start)
            }
            return SubStr(this, Start, Length)
        }
    }

    /**
     * Returns the length of the string in characters.
     * 
     * @example
     * "Hello".Length   ; 5
     * 
     * @returns {Integer}
     */
    Length => StrLen(this)

    /**
     * Returns the length of this string in bytes with the specified `Encoding`.
     * 
     * @example
     * "Hello, world!".Size ; UTF-16: (13 + 1) * 2 = 28 bytes
     * "foo".Size["UTF-8"]  ; 4
     * 
     * @param   {String?/Integer?}  Encoding  target string encoding
     * @returns {Integer}
     */
    Size[Encoding?] {
        Get {
            if (!IsSet(Encoding)) {
                return StrPut(this)
            }
            if (IsObject(Encoding)) {
                throw TypeError("Expected a String or Integer",, Type(Encoding))
            }
            return StrPut(this, Encoding)
        }
    }

    /**
     * Lexicographically compares this string with `Other`.
     * 
     * @example
     * "a".Compare("b") ; -1
     * 
     * @param   {String}      Other      string to be compared
     * @param   {Primitive?}  CaseSense  case-sensitivity of the comparison
     * @returns {Integer}
     */
    Compare(Other, CaseSense := false) => StrCompare(this, Other, CaseSense)
} ; class String
} ; class AquaHotkey_String extends AquaHotkey