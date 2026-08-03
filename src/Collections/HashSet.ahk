#Include "%A_LineFile%\..\..\Collections\HashMap.ahk"
#Include "%A_LineFile%\..\..\Collections\Set.ahk"

/**
 * A set implementation that supports object equality comparisons
 * by using a {@link HashMap} as backing map.
 * 
 * @module  <Collection/HashSet>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class HashSet extends Set {
    /**
     * Constructs a new hash set containing the specified elements.
     * 
     * @constructor
     * @param   {Any*}  Values  zero or more values
     * @returns {HashSet}
     */
    __New(Values*) {
        DefineConst(this, "M", HashMap()).Add(Values*)
    }
}
