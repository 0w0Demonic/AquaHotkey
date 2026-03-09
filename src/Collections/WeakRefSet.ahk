#Include "%A_LineFile%\..\Set.ahk"
#Include "%A_LineFile%\..\WeakRefMap.ahk"

/**
 * An {@link ISet} of weak references.
 * 
 * Elements are stored in a manner that allows them to be freed regardless of
 * their presence in the set. Whenever an element is disposed of via
 * `.__Delete()`, it is automatically freed from the set.
 * 
 * @module  <Collections/WeakRefSet>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic
 * @example
 * O := Object()
 * S := WeakRefSet(O)
 * 
 * MsgBox(S.Size) ; 1
 * 
 * ; frees the object from the set
 * O := unset 
 * 
 * MsgBox(S.Size) ; 0
 */
class WeakRefSet extends Set {
    /**
     * Constructs a new weak ref set with the given elements.
     * 
     * @constructor
     * @param   {Any*}  Values  zero or more elements
     */
    __New(Values*) {
        M := WeakRefMap()
        this.DefineProp("M", { Get: (_) => M })
        this.Add(Values*)
    }
}