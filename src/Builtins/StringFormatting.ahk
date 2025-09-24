/**
 * AquaHotkey - StringFormatting.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/StringFormatting.ahk
 */
class AquaHotkey_StringFormatting extends AquaHotkey {
class String {
    /**
     * Inserts `Str` into the string at index `Position`.
     * 
     * @example
     * "Hello world!".Insert(",", 6) ; "Hello, world!"
     * "banaa".Insert("n", -1)       ; "banana"
     * 
     * @param   {String}    Str       string to insert
     * @param   {Integer?}  Position  index to insert string into
     * @param   {String}
     */
    Insert(Str, Position := 1) {
        if (IsObject(Str)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        if (!IsInteger(Position)) {
            throw TypeError("Expected an Integer",, Type(Position))
        }
        tLen     := StrLen(this)
        if (Abs(Position) > tLen) {
            Msg     := "index out of bounds"
            Pattern := "index {} (length of this string: {})"
            Extra   := Format(Pattern, Position, tLen)
            throw ValueError(Msg,, Extra)
        }
        if (Position <= 0) {
            Position += tLen + 1
        }
        return SubStr(this, 1, Position - 1)
             . Str
             . SubStr(this, Position)
    }

    /**
     * Overwrites `Str` into the string at index `Position`.
     * 
     * @example
     * "banaaa".Overwrite("n", 5)  ; "banana"
     * "appll".Overwrite("e", -1)  ; "apple"
     * 
     * @param   {String}    Str       string to overwrite with
     * @param   {Integer?}  Position  index to place the new string
     * @returns {String}
     */
    Overwrite(Str, Position := 1) {
        if (IsObject(Str)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        if (!IsInteger(Position)) {
            throw TypeError("Expected an Integer",, Type(Position))
        }
        tLen     := StrLen(this)
        if (Abs(Position) > tLen) {
            Pattern := "index {} (length of this string: {})"
            Extra   := Format(Pattern, Position, tLen)
            throw ValueError("index out of bounds",, Extra)
        }
        if (Position <= 0) {
            Position += tLen + 1
        }
        return SubStr(this, 1, Position - 1)
             . Str
             . SubStr(this, Position + StrLen(Str))
    }

    /**
     * Removes a section from the string at index `Position`, `Length`
     * characters long.
     * 
     * @example
     * "aapple".Delete(2)       ; "apple"
     * "banabana".Delete(-4, 2) ; "banana"
     * 
     * @param   {Integer}   Position  section start
     * @param   {Integer?}  Length    section length
     * @returns {String}
     */
    Delete(Position, Length := 1) {
        if (!IsInteger(Position) || !IsInteger(Length)) {
            throw TypeError("Expected an Integer",,
                            Type(Position) . " " . Type(Length))
        }
        if (!Position || !Length) {
            return this
        }
        tLen := StrLen(this)
        if (Abs(Position) > tLen) {
            Pattern := "index {} (string length {})"
            Extra   := Format(Pattern, Position, Length)
            throw ValueError("index out of bounds",, Extra)
        }
        if (Position <= 0) {
            Position += tLen + 1
        }
        if (Length < 0) {
            if ((Length += tLen - Position + 1) <= 0) {
                return this
            }
        }
        return SubStr(this, 1, Position - 1)
             . SubStr(this, Position + Length)
    }

    /**
     * Pads this string on the left using `PaddingStr` a total of `n` times.
     * 
     * @example
     * "foo".LPad(" ", 5) ; "     foo"
     * 
     * @param   {String?}   PaddingStr  padding string
     * @param   {Integer?}  n           amount of padding
     * @returns {String}
     */ 
    LPad(PaddingStr := " ", n := 1) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        if (n) {
            if (IsObject(PaddingStr)) {
                throw TypeError("Expected a String",, Type(PaddingStr))
            }
            return (PaddingStr.Repeat(n) . this)
        }
        return this
    }

    /**
     * Pads this string on the right using `PaddingStr` a total of `n` times.
     * 
     * @example
     * "foo".RPad(" ", 5) ; "foo     "
     * 
     * @param   {String?}   PaddingStr  padding string
     * @param   {Integer?}  n           amount of padding
     * @returns {String}
     */
    RPad(PaddingStr := " ", n := 1) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        if (n) {
            if (IsObject(PaddingStr)) {
                throw TypeError("Expected a String",, Type(PaddingStr))
            }
            return (this . PaddingStr.Repeat(n))
        }
        return this
    }

    /**
     * Strips all whitespace from this string and then formats words into lines
     * with a maximum length of `n` characters.
     * 
     * @example
     * ; (use a really small line length for demonstration purposes)
     * ; "hello,`nworld!"
     * "hello, world!".WordWrap(3)
     * 
     * @param   {Integer?}  n  maximum line length
     * @returns {String}
     */ 
    WordWrap(n := 80) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n <= 0) {
            throw ValueError("n <= 0",, n)
        }
        Pos := 0
        VarSetStrCapacity(&Out, StrLen(this))
        Loop Parse this, "`n`s`t", "`r`n`s`t" {
            Len := StrLen(A_LoopField)
            if (Pos + Len > n) {
                Out .= "`r`n"
                Pos := 0
            } else if ((A_Index - 1) && Len && Pos) {
                Out .= " "
                Pos++
            }
            Out .= A_LoopField
            Pos += Len
        }
        return Out
    }

    /**
     * Trims characters `OmitChars` from the beginning and end of the string.
     * 
     * @example
     * " foo ".Trim() ; "foo"
     * 
     * @param   {String?}  OmitChars  characters to trim
     * @returns {String}
     */
    Trim(OmitChars?) => Trim(this, OmitChars?)

    /**
     * Trims characters `OmitChars` from the beginning of the string.
     * 
     * @example
     * " foo ".LTrim() ; "foo "
     * 
     * @param   {String?}  OmitChars  characters to trim
     * @returns {String}
     */
    LTrim(OmitChars?) => LTrim(this, OmitChars?)

    /**
     * Trims characters `OmitChars` from the end of the string.
     * 
     * @example
     * " foo ".RTrim() ; " foo"
     * 
     * @param   {String?}  OmitChars  characters to trim
     * @returns {String}
     */
    RTrim(OmitChars?) => RTrim(this, OmitChars?)

    /**
     * Converts the string to lowercase.
     * 
     * @example
     * "FOO".ToLower() ; "foo"
     * 
     * @returns {String}
     */
    ToLower()  => StrLower(this)

    /**
     * Converts this string to uppercase.
     * 
     * @example
     * "foo".ToUpper() ; "FOO"
     * 
     * @returns {String}
     */
    ToUpper()  => StrUpper(this)

    /**
     * Converts this string to title case.
     * 
     * @example
     * "foo".ToTitle() ; "Foo"
     * 
     * @returns {String}
     */
    ToTitle()  => StrTitle(this)
} ; class String
} ; class AquaHotkey_StringFormatting extends AquaHotkey