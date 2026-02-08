#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * String matching.
 * 
 * @module  <String/StringMatching>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_StringMatching extends AquaHotkey {
    class String {
        ;@region Is Functions

        /**
         * Is-functions (see AHK docs).
         * @returns {Boolean}
         */
        IsDigit  => IsDigit(this)
        IsXDigit => IsXDigit(this)
        IsAlpha  => IsAlpha(this)
        IsUpper  => IsUpper(this)
        IsLower  => IsLower(this)
        IsAlnum  => IsAlnum(this)
        IsSpace  => IsSpace(this)
        IsTime   => IsTime(this)

        /**
         * Determines whether the string is empty.
         * 
         * @returns {Boolean}
         * @example
         * "Hello, world!".IsEmpty ; false
         * "".IsEmpty              ; true
         */
        IsEmpty => (this == "")

        /**
         * Determines whether the string is *not* empty.
         * 
         * @returns {Boolean}
         */
        IsNotEmpty => (this != "")

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Regex

        /**
         * Determines whether the string matches the given regex `Pattern`.
         * 
         * @param   {String}    Pattern   regular expression
         * @param   {VarRef?}   MatchObj  output match object
         * @param   {Integer?}  Pos       position to start searching from
         * @returns {Integer} 
         * @example
         * "Test123Hello".RegExMatch("\d++") ; 5
         */
        RegExMatch(Pattern, &MatchObj?, Pos := 1) {
            return RegExMatch(this, Pattern, &MatchObj, Pos)
        }

        /**
         * Replaces occurrences of a regex expression in the string.
         * 
         * @param   {String}    Pattern  regular expression
         * @param   {String?}   Replace  replacement string
         * @param   {VarRef?}   Count    output count
         * @param   {Integer?}  Limit    maximum number of replacements
         * @param   {Integer?}  Start    position to start searching from
         * @returns {String}
         * @example
         * "Test123Hello".RegExReplace("\d++", "") ; "TestHello"
         */
        RegExReplace(Pattern, Replace?, &Count?, Limit?, Start?) {
            return RegExReplace(this, Pattern, Replace?, &Count, Limit?, Start?)
        }

        /**
         * Returns the match object for the first occurrence of a regular
         * expression `Pattern`.
         * 
         * @param   {String}    Pattern  regular expression
         * @param   {Integer?}  Pos      position to start searching from
         * @returns {RegExMatchInfo}
         * @example
         * MatchObj := "Test123Hello".Match("\d++")
         */
        Match(Pattern, Pos := 1) {
            if (RegExMatch(this, Pattern, &MatchObj, Pos)) {
                return MatchObj
            }
            return false
        }

        /**
         * Returns all match objects for occurrence of a regex `Pattern` in
         * the string. Match objects do not overlap with each other.
         * 
         * @param   {String}    Pattern  regular expression
         * @param   {Integer?}  Pos      position to start searching from
         * @returns {Array}
         * @example
         * ; 1st iteration: "12"
         * ; 2nd iteration: "34"
         * for MatchObj in "12345".MatchAll("\d{2}+") {
         *     MsgBox(MatchObj[0])
         * }
         */
        MatchAll(Pattern, Pos := 1) {
            Result := Array()
            while (FoundPos := RegExMatch(this, Pattern, &MatchObj, Pos)) {
                Result.Push(MatchObj)
                Pos := FoundPos + (MatchObj.Len[0] || 1)
            }
            return Result
        }

        /**
         * Returns the overall match of the first occurrence of a regular
         * expression `Pattern`.
         * 
         * @param   {String}    Pattern  regular expression
         * @param   {Integer?}  Pos      position to start searching from
         * @returns {String}
         * @example
         * "Test123Hello".Capture("\d++") ; "123"
         */
        Capture(Pattern, Pos := 1) {
            if (RegExMatch(this, Pattern, &MatchObj, Pos)) {
                return MatchObj[0]
            }
            throw ValueError("no match found",, Pattern)
        }

        /**
         * Returns an array of all occurrences of regular expression `Pattern`.
         * Matches do not overlap with each other.
         * 
         * @param   {String}    Pattern  regular expression
         * @param   {Integer?}  Pos      position to start searching from
         * @returns {Array}
         * @example
         * "12345".CaptureAll("\d{2}+") ; ["12", "34"]
         */
        CaptureAll(Pattern, Pos := 1) {
            Result := Array()
            while (FoundPos := RegExMatch(this, Pattern, &MatchObj, Pos)) {
                Result.Push(MatchObj[0])
                Pos := FoundPos + (MatchObj.Len[0] || 1)
            }
            return Result
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region InStr()

        /**
         * Searches for the occurrence of `Pattern` in the string.
         * 
         * @param   {String}      Pattern     string to search for
         * @param   {Primitive?}  CaseSense   case-sensitivity
         * @param   {Integer?}    Pos         position to start searching from
         * @param   {Integer?}    Occurrence  n-th occurrence to search for
         * @returns {Integer}
         * @example
         * "foo bar".Contains("b") ; 5
         */
        Contains(Pattern, CaseSense := false, Pos := 1, Occurrence := 1) {
            return !!InStr(this, Pattern, CaseSense, Pos, Occurrence)
        }

        /**
         * Searches in `Str` for the occurrence of this string.
         * 
         * @param   {String}      Str         string to search in
         * @param   {Primitive?}  CaseSense   case-sensitivity
         * @param   {Integer?}    Pos         position to start searching from
         * @param   {Integer?}    Occurrence  n-th occurrence to search for
         * @returns {Integer}
         * @example
         * "b".ContainedIn("foo bar") ; 5
         */
        ContainedIn(Str, CaseSense := false, Pos := 1, Occurrence := 1) {
            return !!InStr(Str, this, CaseSense, Pos, Occurrence)
        }

        ;@endregion
    }
}