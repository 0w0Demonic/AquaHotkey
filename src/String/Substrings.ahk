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
        ;@region General

        /**
         * Returns a substring at index `Start` and length `Length` in
         * characters.
         * 
         * @param   {Integer}   Start   starting index
         * @param   {Integer?}  Length  length in characters
         * @returns {String}
         * @example
         * "123abc789".Sub(4, 3) ; "abc"
         */
        Sub(Start, Length?) => SubStr(this, Start, Length?)

        /**
         * Returns a substring at index `Start` and length `Length` in
         * characters. Unlike `SubStr()`, `Length` defaults to 1 when
         * omitted.
         * 
         * @param   {Integer}   Start   starting index
         * @param   {Integer?}  Length  length in characters
         * @returns {String}
         * @example
         * ("foo bar")[5] ; "b"
         */
        __Item[Start, Length := 1] => SubStr(this, Start, Length)

        /**
         * Returns the character at the given index.
         * 
         * @param   {Integer}  Index  character index
         * @returns {String}
         */
        CharAt(Index) => SubStr(this, Index, 1)

        /**
         * Returns the code point of the character at the given index.
         * 
         * @param   {Integer}  Index  character index
         * @returns {String}
         */
        OrdAt(Index) => Ord(SubStr(this, Index, 1))

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Index Cut

        /**
         * Returns a substring that ends just before the given index.
         * 
         * @param   {Integer}  Index  character index
         * @returns {String}
         */
        BeforeIndex(Index) => SubStr(this, 1, Index - 1)

        /**
         * Returns a substring that ends on the given index.
         * 
         * @param   {Integer}  Index  character index
         * @returns {String}
         */
        UntilIndex(Index) => SubStr(this, 1, Index)

        /**
         * Returns a substring that starts at the given index.
         * 
         * @param   {Integer}  Index  character index
         * @returns {String}
         */
        FromIndex(Index) => SubStr(this, Index)

        /**
         * Returns a substring that starts just after the given index.
         * 
         * @param   {Integer}  Index  character index
         * @returns {String}
         */
        AfterIndex(Index) => SubStr(this, Index + 1)

        /**
         * Returns a slice of a given window size, centered around a given
         * index inside the string, truncating on the left and right side
         * using `...` when appropriate. Negative indexing is supported.
         * 
         * `NewIndex` receives the index of the new location at which `Index`
         * is positioned in the resulting string.
         * 
         * @param   {Integer}   Index       string index to center around
         * @param   {Integer?}  WindowSize  size of slice to return
         * @param   {VarRef?}   NewIndex    (out) new index of center
         * @returns {String}
         * @example
         * ; "...ijk..."
         * "abcdefghijklmnopqrstuvwxyz".ViewAround(10, 3, &NewIndex)
         * MsgBox(NewIndex) ; 5 (location of `j`, index 10 in previous string)
         */
        ViewAround(Index, WindowSize := 20, &NewIndex?) {
            if (!IsInteger(WindowSize)) {
                throw TypeError("Expected an Integer")
            }
            if (WindowSize <= 0) {
                return ""
            }
            if (!IsInteger(Index)) {
                throw TypeError("Expected an Integer")
            }
            if (Index == 0) {
                throw ValueError("Index == 0")
            }
            Len := StrLen(this)
            if (Index < 0) {
                Index += Len + 1
            }
            Half := WindowSize // 2

            ; Start: first index to include
            ; End: first index *not* to include
            Start := Max(1, Index - Half)
            End   := Min(Len + 1, Start + WindowSize)
            Start := Max(1, End - WindowSize)

            if (Start > 1) {
                NewIndex := 4 + Half
            } else {
                NewIndex := Index
            }
            return (
                ((Start > 1) ? "..." : "")
              . SubStr(this, Start, End - Start)
              . ((End <= Len) ? "..." : "")
            )
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region String Cut

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

        static __New() {
            ({}.DefineProp)(this.Prototype, "Sub", { Call: SubStr })
            
            PropDesc := ({}.GetOwnPropDesc)(this.Prototype, "_Until")
            ({}.DeleteProp)(this.Prototype, "_Until")
            ({}.DefineProp)(this.Prototype, "Until", PropDesc)
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
        _Until(Pattern, CaseSense := false, Pos := 1, Occurrence := 1) {
            FoundPos := InStr(this, Pattern, CaseSense, Pos, Occurrence)
            if (FoundPos) {
                return SubStr(this, 1, FoundPos - 1 + StrLen(Pattern))
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

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Regex Cut

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
