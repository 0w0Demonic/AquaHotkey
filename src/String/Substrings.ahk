#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
/**
 * AquaHotkey - Substrings.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Substrings.ahk
 */
class AquaHotkey_Substrings extends AquaHotkey {
class String {
    /**
     * Returns a substring that ends just before a specified occurrence
     * of `Pattern`.
     * 
     * @example
     * "Hello, world!".Before("world") ; "Hello, "
     * "abcABCabc".Before("ABC", true) ; "abc"
     * 
     * @param   {String}      Pattern       substring to search for
     * @param   {Primitive?}  CaseSense     case-sensitivity
     * @param   {Integer?}    StartingPos   position to start from
     * @param   {Integer?}    Occurrence    n-th occurrence to find
     * @returns {String?}
     */
    Before(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        FoundPos := InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
        if (FoundPos) {
            return SubStr(this, 1, FoundPos - 1)
        }
        return this
    }

    /**
     * Returns a substring that ends just before the first match of a
     * regex `Pattern`.
     * 
     * @example
     * "Test123Hello".BeforeRegex("\d++") ; "Test"
     * 
     * @param   {String}    Pattern       regular expression to search for
     * @param   {Integer?}  StartingPos   position to start from
     * @returns {String}
     */
    BeforeRegex(Pattern, StartingPos := 1) {
        if (IsObject(Pattern)) {
            throw TypeError("Expected a String",, Type(Pattern))
        }
        if (Pattern == "") {
            throw ValueError("Pattern is empty")
        }
        FoundPos := RegExMatch(this, Pattern,, StartingPos)
        if (FoundPos) {
            return SubStr(this, 1, FoundPos - 1)
        }
        return this
    }

    /**
     * Returns a substring from the beginning to the end of a specified
     * occurrence of `Pattern`.
     * 
     * @example
     * "Hello, world!".Until(", ") ; "Hello, "
     * 
     * @param   {String}      Pattern      substring to search for
     * @param   {Primitive?}  CaseSense    case-sensitivity
     * @param   {Integer?}    StartingPos  position to start from
     * @param   {Integer?}    Occurrence   n-th occurrence to find
     * @param   {String}
     */
    Until(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        FoundPos := InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
        if (FoundPos) {
            return SubStr(this, 1, FoundPos - 1 + StrLen(Pattern))
        }
        return this
    }

    /**
     * Returns a substring that ends on the end of the first match of a
     * regex `Pattern`.
     * 
     * @example
     * "Test123Hello".UntilRegex("\d++") ; "Test123"
     * 
     * @param   {String}    Pattern      regular expression to search for
     * @param   {Integer?}  StartingPos  position to start from
     * @returns {String}
     */
    UntilRegex(Pattern, StartingPos := 1) {
        if (IsObject(Pattern)) {
            throw TypeError("Expected a String",, Type(Pattern))
        }
        if (Pattern == "") {
            throw ValueError("Pattern is empty")
        }
        FoundPos := RegExMatch(this, Pattern, &MatchObject, StartingPos)
        if (FoundPos) {
            return SubStr(this, 1, FoundPos - 1 + MatchObject.Len[0])
        }
        return this
    }

    /**
     * Returns a substring that starts at a specified occurrence of `Pattern`.
     * 
     * @example
     * "Hello, world!".From(",") ; ", world!"
     * 
     * @param   {String}      Pattern      substring to search for
     * @param   {Primitive?}  CaseSense    case-sensitivity
     * @param   {Integer?}    StartingPos  position to start from
     * @param   {Integer?}    Occurrence   n-th occurrence to find
     * @param   {String}
     */
    From(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        FoundPos := InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
        if (FoundPos) {
            return SubStr(this, FoundPos)
        }
        return this
    }

    /**
     * Returns a substring that starts at the first match of a regex `Pattern`.
     * 
     * @example
     * "Test123Hello".FromRegex("\d++") ; "123Hello"
     * 
     * @param   {String}    Pattern      regular expression to search for
     * @param   {Integer?}  StartingPos  position to start from
     * @returns {String}
     */
    FromRegex(Pattern, StartingPos := 1) {
        if (IsObject(Pattern)) {
            throw TypeError("Expected a String",, Type(Pattern))
        }
        if (Pattern == "") {
            throw ValueError("Pattern is empty")
        }
        FoundPos := RegExMatch(this, Pattern,, StartingPos)
        if (FoundPos) {
            return SubStr(this, FoundPos)
        }
        return this
    }

    /**
     * Returns a substring that starts after a specified occurrence of
     * `Pattern`.
     * 
     * @example
     * "Hello, world!".After(",") ; " world!"
     * 
     * @param   {String}      Pattern      substring to search for
     * @param   {Primitive?}  CaseSense    case-sensitivity
     * @param   {Integer?}    StartingPos  position to start from
     * @param   {Integer?}    Occurrence   n-th occurrence to find
     * @param   {String}
     */
    After(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        FoundPos := InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
        if (FoundPos) {
            return SubStr(this, FoundPos + StrLen(Pattern))
        }
        return this
    }

    /**
     * Returns a substring that starts after the first match of a regex
     * `Pattern`.
     * 
     * @example
     * "Test123Hello".AfterRegex("\d++") ; "Hello"
     * 
     * @param   {String}    Pattern      regular expression to search for
     * @param   {Integer?}  StartingPos  position to start from
     * @returns {String}
     */
    AfterRegex(Pattern, StartingPos := 1) {
        if (IsObject(Pattern)) {
            throw TypeError("Expected a String",, Type(Pattern))
        }
        if (Pattern == "") {
            throw ValueError("Pattern is empty")
        }
        FoundPos := RegExMatch(this, Pattern, &MatchObject, StartingPos)
        if (FoundPos) {
            return SubStr(this, FoundPos + MatchObject.Len[0])
        }
        return this
    }
} ; class String
} ; class AquaHotkey_Substrings extends AquaHotkey