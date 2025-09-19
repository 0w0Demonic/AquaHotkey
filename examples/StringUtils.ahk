#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%/../../AquaHotkey.ahk"

/**
 * @file
 * @name StringUtils
 * @description
 * Demonstrates how to add custom string utilities.
 */
class StringUtils extends AquaHotkey {
    class String {
        /**
         * Returns the length of the string in characters.
         * 
         * @example
         * "Hello".Length ; 5
         * 
         * @returns  {Integer}
         */
        Length => StrLen(this)

        /**
         * Returns a character of the string at the given index.
         * 
         * @example
         * ("Foo")[1] ; "F"
         * ("Foo")[5] ; ""
         * 
         * @param    {Integer}  Index  position of the character
         * @returns  {String}
         */
        __Item[Index] => SubStr(this, Index, 1)

        /**
         * Determines whether the string starts with `Prefix`.
         * 
         * @example
         * "Fox".StartsWith("F")       ; true
         * "Fox".StartsWith("f", true) ; false
         * 
         * @param   {String}      Prefix     the given prefix
         * @param   {Primitive?}  CaseSense  case sensitivity options
         * @returns {Boolean}
         */
        StartsWith(Prefix, CaseSense?) {
            return InStr(SubStr(this, 1, StrLen(Prefix)),
                         Prefix,
                         CaseSense?)
        }

        /**
         * Determines whether the string ends with `Suffix`.
         * 
         * @example
         * "Fox".EndsWith("x")       ; true
         * "Fox".EndsWith("X", true) ; false
         * 
         * @param   {String}      Suffix     the given suffix
         * @param   {Primitive?}  CaseSense  case sensitivity options
         * @returns {Boolean}
         */
        EndsWith(Suffix, CaseSense?) {
            return InStr(SubStr(this, -StrLen(Suffix)),
                         Suffix,
                         CaseSense?)
        }
    }
}

MsgBox(Format("
    (
    "foo".Length == {1}
    ("bar")[1] == {2}
    "Hello, world!".StartsWith("Hell") == {3}
    "Example".EndsWith("te") == {4}
    )",

    "foo".Length,
    ("bar")[1],
    "Hello, world!".StartsWith("Hell"),
    "Example".EndsWith("te")
))