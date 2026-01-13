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
     * Returns `true`, if this string is empty.
     * 
     * @returns {Boolean}
     * @example
     * "Hello, world!".IsEmpty ; false
     * "".IsEmpty              ; true
     */
    IsEmpty => (this == "")

    /**
     * Determines whether the string matches the given regex `Pattern`.
     * 
     * @param   {String}    Pattern      regular expression
     * @param   {VarRef?}   MatchObj     output match object
     * @param   {Integer?}  StartingPos  position to start searching from
     * @returns {Integer} 
     * @example
     * "Test123Hello".RegExMatch("\d++") ; 5
     */
    RegExMatch(Pattern, &MatchObj?, StartingPos := 1) {
        return RegExMatch(this, Pattern, &MatchObj, StartingPos)
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
     * @param   {String}    Pattern      regular expression
     * @param   {Integer?}  StartingPos  position to start searching from
     * @returns {RegExMatchInfo}
     * @example
     * MatchObj := "Test123Hello".Match("\d++")
     */
    Match(Pattern, StartingPos := 1) {
        if (RegExMatch(this, Pattern, &MatchObj, StartingPos)) {
            return MatchObj
        }
        return false
    }

    /**
     * Returns all match objects for occurrence of a regex `Pattern` in
     * the string. Match objects do not overlap with each other.
     * 
     * @param   {String}    Pattern      regular expression
     * @param   {Integer?}  StartingPos  position to start searching from
     * @returns {Array}
     * @example
     * ; 1st iteration: "12"
     * ; 2nd iteration: "34"
     * for MatchObj in "12345".MatchAll("\d{2}+") {
     *     MsgBox(MatchObj[0])
     * }
     */
    MatchAll(Pattern, StartingPos := 1) {
        Result := Array()
        while (FoundPos := RegExMatch(this, Pattern, &MatchObj, StartingPos)) {
            Result.Push(MatchObj)
            StartingPos := FoundPos + (MatchObj.Len[0] || 1)
        }
        return Result
    }

    /**
     * Returns the overall match of the first occurrence of a regular
     * expression `Pattern`.
     * 
     * @param   {String}    Pattern      regular expression
     * @param   {Integer?}  StartingPos  position to start searching from
     * @returns {String}
     * @example
     * "Test123Hello".Capture("\d++") ; "123"
     */
    Capture(Pattern, StartingPos := 1) {
        if (RegExMatch(this, Pattern, &MatchObj, StartingPos)) {
            return MatchObj[0]
        }
        throw ValueError("no match found",, Pattern)
    }

    /**
     * Returns an array of all occurrences of regular expression `Pattern`.
     * Matches do not overlap with each other.
     * 
     * @param   {String}    Pattern      regular expression
     * @param   {Integer?}  StartingPos  position to start searching from
     * @returns {String}
     * @example
     * "12345".CaptureAll("\d{2}+") ; ["12", "34"]
     */
    CaptureAll(Pattern, StartingPos := 1) {
        Result := Array()
        while (FoundPos := RegExMatch(this, Pattern, &MatchObj, StartingPos)) {
            Result.Push(MatchObj[0])
            StartingPos := FoundPos + (MatchObj.Len[0] || 1)
        }
        return Result
    }

    /**
     * Searches for the occurrence of `Pattern` in the string.
     * 
     * @param   {String}      Pattern      string to search for
     * @param   {Primitive?}  CaseSense    case-sensitivity
     * @param   {Integer?}    StartingPos  position to start searching from
     * @param   {Integer?}    Occurrence   n-th occurrence to search for
     * @returns {Integer}
     * @example
     * "foo bar".Contains("b") ; 5
     */
    Contains(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        return InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
    }

    /**
     * Searches in `Str` for the occurrence of this string.
     * 
     * @param   {String}      Str          string to search in
     * @param   {Primitive?}  CaseSense    case-sensitivity
     * @param   {Integer?}    StartingPos  position to start searching from
     * @param   {Integer?}    Occurrence   n-th occurrence to search for
     * @returns {Integer}
     * @example
     * "b".ContainedIn("foo bar") ; 5
     */
    ContainedIn(Str, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        return InStr(Str, this, CaseSense, StartingPos, Occurrence)
    }
} ; class String
} ; AquaHotkey_StringMatching extends AquaHotkey