/**
 * @duck
 * 
 * A boolean value that equals either `true`/`1` or `false`/`0`.
 * 
 * On versions above v2.1-alpha.10, this class can be used as a struct type.
 * 
 * @module  <Base/DuckTypes/Boolean>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Boolean extends Integer {
    /**
     * Determines whether the input value is considered a boolean.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * (true).Is(Boolean) ; true
     * (false).Is(Boolean) ; true
     * 
     * (0).Is(Boolean) ; true
     * (1).Is(Boolean) ; true
     */
    static IsInstance(Val?) => Integer.IsInstance(Val?)
            && ((Val == true) || (Val == false))
}
