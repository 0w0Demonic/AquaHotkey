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
        static __New() {
            static Define := {}.DefineProp
            Proto := this.Prototype

            for Name, Fn in ObjOwnProps({
                IsDigit:  IsDigit,
                IsXDigit: IsXDigit,
                IsAlpha:  IsAlpha,
                IsUpper:  IsUpper,
                IsLower:  IsLower,
                IsAlnum:  IsAlnum,
                IsSpace:  IsSpace,
                IsTime:   IsTime,
                RegExMatch: RegExMatch,
            }) {
                Define(Proto, Name, { Call: Fn })
            }
        }

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
         * Returns a {@link Stream} (or `Enumerator`, if absent) of regex
         * matches of a given `Pattern`. Matches do not overlap with each other.
         * 
         * @param   {String}    Pattern  regular expression
         * @param   {Integer?}  Pos      position to start searching from
         * @returns {Stream|Enumerator}
         * @example <caption>Using a simple `for`-loop</caption>
         * ; 1st iteration: "12"
         * ; 2nd iteration: "34"
         * for MatchObj in "12345".MatchAll("\d{2}+") {
         *     MsgBox(MatchObj[0])
         * }
         * @example <caption>Using `Stream`</caption>
         * "12345".MatchAll("\d").Map(M => M[0]).ForEach(MsgBox)
         */
        MatchAll(Pattern, Pos := 1) {
            static T := IsSet(AquaHotkey_Stream)
                    ? Stream.Prototype
                    : Enumerator.Prototype

            if (!(Pattern is Primitive)) {
                throw TypeError("Expected a String",, Type(Pattern))
            }
            if (!IsInteger(Pos)) {
                throw TypeError("Expected an Integer",, Type(Pos))
            }
            ObjSetBase(MatchAll, T)
            return MatchAll

            MatchAll(&Out) {
                if (RegExMatch(this, Pattern, &Out, Pos)) {
                    Pos := Out.Pos[0] + (Out.Len[0] || 1)
                    return true
                }
                return false
            }
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
         * Returns a {@link Stream} (or `Enumerator`, if absent) of all
         * occurrences of a regex match of a given `Pattern`.
         * 
         * Matches do not overlap with each other.
         * 
         * @param   {String}    Pattern  regular expression
         * @param   {Integer?}  Pos      position to start searching from
         * @returns {Stream|Enumerator}
         * @example
         * "12345".CaptureAll("\d{2}+") ; <"12", "34">
         */
        CaptureAll(Pattern, Pos := 1) {
            static T := IsSet(AquaHotkey_Stream)
                    ? Stream.Prototype
                    : Enumerator.Prototype

            if (!(Pattern is Primitive)) {
                throw TypeError("Expected a String",, Type(Pattern))
            }
            if (!IsInteger(Pos)) {
                throw TypeError("Expected an Integer",, Type(Pos))
            }
            ObjSetBase(CaptureAll, T)
            return CaptureAll

            CaptureAll(&Out) {
                if (RegExMatch(this, Pattern, &Match, Pos)) {
                    Out := Match[0]
                    Pos := Match.Pos[0] + (Match.Len[0] || 1)
                    return true
                }
                return false
            }
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
        ;-----------------------------------------------------------------------
        ;@region Start/End

        /**
         * Determines whether this string starts with `Str`.
         * 
         * @param   {String}    Str        string to be searched
         * @param   {Boolean?}  CaseSense  case sensitivity
         * @returns {Boolean}
         */
        StartsWith(Str, CaseSense := false) => (CaseSense)
                ? SubStr(this, 1, StrLen(Str)) == Str
                : SubStr(this, 1, StrLen(Str)) = Str

        /**
         * Determines whether this string ends with `Str`.
         * 
         * @param   {String}    Str        string to be searched
         * @param   {Boolean?}  CaseSense  case-sensitivity
         * @returns {Boolean}
         */
        EndsWith(Str, CaseSense := false) => (CaseSense)
                ? SubStr(this, -StrLen(Str)) == Str
                : SubStr(this, -StrLen(Str)) = Str

        ;@endregion
    }
}