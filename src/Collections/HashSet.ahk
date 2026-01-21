#Include "%A_LineFile%\..\HashMap.ahk"
#Include "%A_LineFile%\..\Set.ahk"

/**
 * A set implementation that supports object equality comparisons
 * via a backing `HashMap`.
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
    static Call(Values*) {
        M := HashMap()
        for Value in Values {
            M[Value] := true
        }
        return this.FromMap(M)
    }
}