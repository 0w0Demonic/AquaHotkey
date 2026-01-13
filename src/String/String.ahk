#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * String utility.
 * 
 * @module  <String/String>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * 
 * TODO
 */
class AquaHotkey_String extends AquaHotkey {
class String {
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
        if (n == 1) {
            return Enumer1
        }
        return Enumer2
        
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
    ; TODO figure out how to make this lazy-eval

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
    
    /**
     * Formats by using the string as format pattern.
     * 
     * If an object is passed, it is converted to a string by using its
     * `ToString() method`.
     * 
     * @param   {Any*}  Args  zero or more additional arguments
     * @returns {String}
     * @example
     * "a: {}, b: {}".Formatted(2, 42) ; "a: 2, b: 42"
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
     * @param   {String}      Pattern    string to replace
     * @param   {String?}     Rep        replacement string
     * @param   {Primitive?}  CaseSense  case-sensitivity
     * @param   {VarRef?}     Out        output of replacements that occurred
     * @param   {Integer?}    Limit      replacement limit
     * @returns {String}
     * @example
     * "abz".Replace("z", "c") ; "abc"
     */
    Replace(Pattern, Rep := "", CaseSense := false, &Out?, Limit := -1) {
        return StrReplace(this, Pattern, Rep, CaseSense, &Out, Limit)
    }

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
     * Returns a substring at index `Start` and length `Length` in characters.
     * 
     * @param   {Integer}   Start   starting index
     * @param   {Integer?}  Length  length in characters
     * @returns {String}
     * @example
     * "123abc789".Sub(4, 3) ; "abc"
     */
    Sub(Start, Length?) => SubStr(this, Start, Length?)

    /**
     * Returns a substring at index `Start` and length `Length` in characters.
     * Unlike `SubStr()`, `Length` defaults to 1 when omitted.
     * 
     * @param   {Integer}   Start   starting index
     * @param   {Integer?}  Length  length in characters
     * @returns {String}
     * @example
     * ("foo bar")[5] ; "b"
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
     * @returns {Integer}
     * @example
     * "Hello".Length   ; 5
     */
    Length => StrLen(this)

    /**
     * Returns the length of this string in bytes with the specified `Encoding`.
     * 
     * @param   {String?/Integer?}  Encoding  target string encoding
     * @returns {Integer}
     * @example
     * "Hello, world!".Size ; UTF-16: (13 + 1) * 2 = 28 bytes
     * "foo".Size["UTF-8"]  ; 4
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
} ; class String
} ; class AquaHotkey_String extends AquaHotkey