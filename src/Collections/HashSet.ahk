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
     * @param   {Any*}  Values  zero or more elements
     */
    __New(Values*) {
        M := HashMap()
        this.DefineProp("M", { Get: (_) => M })
        if (Values.Length) {
            this.Add(Values*)
        }
    }
}