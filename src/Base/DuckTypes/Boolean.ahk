/**
 * @duck
 * 
 * A boolean value that equals either `true`/`1` or `false`/`0`.
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
    static IsInstance(Val?) => super.IsInstance(Val?)
            && (  (Val == true) || (Val == false)  )
}
