
#Include "%A_LineFile%\..\HashMap.ahk"
#Include "%A_LineFile%\..\Set.ahk"

; TODO refactor this into some sort of static constructor accepting
; internal map

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

    /**
     * Gets and retrieves case sensitivity of the underlying map
     * (unsupported).
     */
    CaseSense {
        get {
            throw MethodError("Not supported")
        }
        set {
            throw MethodError("Not supported")
        }
    }
}
