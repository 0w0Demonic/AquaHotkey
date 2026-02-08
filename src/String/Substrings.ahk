#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Utility for creating substrings.
 * 
 * @module  <String/Substrings>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Substrings extends AquaHotkey {
    class String {
        /**
         * Returns a substring that ends just before a specified occurrence
         * of `Pattern`.
         * 
         * @param   {String}      Pattern     substring to search for
         * @param   {Primitive?}  CaseSense   case-sensitivity
         * @param   {Integer?}    Pos         position to start from
         * @param   {Integer?}    Occurrence  n-th occurrence to find
         * @returns {String?}
         * @example
         * "Hello, world!".Before("world") ; "Hello, "
         * "abcABCabc".Before("ABC", true) ; "abc"
         */
        Before(Pattern, CaseSense := false, Pos := 1, Occurrence := 1) {
            FoundPos := InStr(this, Pattern, CaseSense, Pos, Occurrence)
            if (FoundPos) {
                return SubStr(this, 1, FoundPos - 1)
            }
            return this
        }

        /**
         * Returns a substring that ends just before the first match of a
         * regex `Pattern`.
         * 
         * @param   {String}    Pattern  regular expression to search for
         * @param   {Integer?}  Pos      position to start from
         * @returns {String}
         * @example
         * "Test123Hello".BeforeRegex("\d++") ; "Test"
         */
        BeforeRegex(Pattern, Pos := 1) {
            if (IsObject(Pattern)) {
                throw TypeError("Expected a String",, Type(Pattern))
            }
            if (Pattern == "") {
                throw ValueError("Pattern is empty")
            }
            FoundPos := RegExMatch(this, Pattern,, Pos)
            if (FoundPos) {
                return SubStr(this, 1, FoundPos - 1)
            }
            return this
        }

        /**
         * Returns a substring from the beginning to the end of a specified
         * occurrence of `Pattern`.
         * 
         * @param   {String}      Pattern     substring to search for
         * @param   {Primitive?}  CaseSense   case-sensitivity
         * @param   {Integer?}    Pos         position to start from
         * @param   {Integer?}    Occurrence  n-th occurrence to find
         * @param   {String}
         * @example
         * "Hello, world!".Until(", ") ; "Hello, "
         */
        Until(Pattern, CaseSense := false, Pos := 1, Occurrence := 1) {
            FoundPos := InStr(this, Pattern, CaseSense, Pos, Occurrence)
            if (FoundPos) {
                return SubStr(this, 1, FoundPos - 1 + StrLen(Pattern))
            }
            return this
        }

        /**
         * Returns a substring that ends on the end of the first match of a
         * regex `Pattern`.
         * 
         * @param   {String}    Pattern  regular expression to search for
         * @param   {Integer?}  Pos      position to start from
         * @returns {String}
         * @example
         * "Test123Hello".UntilRegex("\d++") ; "Test123"
         */
        UntilRegex(Pattern, Pos := 1) {
            if (IsObject(Pattern)) {
                throw TypeError("Expected a String",, Type(Pattern))
            }
            if (Pattern == "") {
                throw ValueError("Pattern is empty")
            }
            FoundPos := RegExMatch(this, Pattern, &MatchObject, Pos)
            if (FoundPos) {
                return SubStr(this, 1, FoundPos - 1 + MatchObject.Len[0])
            }
            return this
        }

        /**
         * Returns a substring that starts at a specified occurrence
         * of `Pattern`.
         * 
         * @param   {String}      Pattern     substring to search for
         * @param   {Primitive?}  CaseSense   case-sensitivity
         * @param   {Integer?}    Pos         position to start from
         * @param   {Integer?}    Occurrence  n-th occurrence to find
         * @param   {String}
         * @example
         * "Hello, world!".From(",") ; ", world!"
         */
        From(Pattern, CaseSense := false, Pos := 1, Occurrence := 1) {
            FoundPos := InStr(this, Pattern, CaseSense, Pos, Occurrence)
            if (FoundPos) {
                return SubStr(this, FoundPos)
            }
            return this
        }

        /**
         * Returns a substring that starts at the first match of a regex
         * `Pattern`.
         * 
         * @param   {String}    Pattern  regular expression to search for
         * @param   {Integer?}  Pos      position to start from
         * @returns {String}
         * @example
         * "Test123Hello".FromRegex("\d++") ; "123Hello"
         */
        FromRegex(Pattern, Pos := 1) {
            if (IsObject(Pattern)) {
                throw TypeError("Expected a String",, Type(Pattern))
            }
            if (Pattern == "") {
                throw ValueError("Pattern is empty")
            }
            FoundPos := RegExMatch(this, Pattern,, Pos)
            if (FoundPos) {
                return SubStr(this, FoundPos)
            }
            return this
        }

        /**
         * Returns a substring that starts after a specified occurrence of
         * `Pattern`.
         * 
         * @param   {String}      Pattern     substring to search for
         * @param   {Primitive?}  CaseSense   case-sensitivity
         * @param   {Integer?}    Pos         position to start from
         * @param   {Integer?}    Occurrence  n-th occurrence to find
         * @param   {String}
         * @example
         * "Hello, world!".After(",") ; " world!"
         */
        After(Pattern, CaseSense := false, Pos := 1, Occurrence := 1) {
            FoundPos := InStr(this, Pattern, CaseSense, Pos, Occurrence)
            if (FoundPos) {
                return SubStr(this, FoundPos + StrLen(Pattern))
            }
            return this
        }

        /**
         * Returns a substring that starts after the first match of a regex
         * `Pattern`.
         * 
         * @param   {String}    Pattern  regular expression to search for
         * @param   {Integer?}  Pos      position to start from
         * @returns {String}
         * @example
         * "Test123Hello".AfterRegex("\d++") ; "Hello"
         */
        AfterRegex(Pattern, Pos := 1) {
            if (IsObject(Pattern)) {
                throw TypeError("Expected a String",, Type(Pattern))
            }
            if (Pattern == "") {
                throw ValueError("Pattern is empty")
            }
            FoundPos := RegExMatch(this, Pattern, &MatchObject, Pos)
            if (FoundPos) {
                return SubStr(this, FoundPos + MatchObject.Len[0])
            }
            return this
        }
    }
}