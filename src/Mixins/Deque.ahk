#Include "%A_LineFile%\..\Sizeable.ahk"

/**
 * Mixin class for double-ended queues.
 * 
 * @module  <Collections/Mixins/Deque>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @mixin
 * 
 * - `IsEmpty => Boolean`
 * - `Pop()`
 * - `Poll()`
 */
class Deque {
    /**
     * Determines whether the value can be used as a deque.
     * 
     * @param   {Any}  Val  any value
     * @returns {Boolean}
     */
    static IsInstance(Val) {
        return IsObject(Val)
            && HasProp(Val, "IsEmpty")
            && HasMethod(Val, "Pop")
            && HasMethod(Val, "Poll")
    }

    /**
     * Returns a stream of elements repeatedly `.Pop()`-ed from this deque.
     * 
     * @returns {Stream}
     * @example
     * Stack := Array(1, 2, 3)
     * for Value in Stack.Drain() {
     *     MsgBox(Value) ; 3, 2, 1
     * }
     * MsgBox(Stack.IsEmpty) ; true
     * 
     * @example
     * Arr := Array(1, 2, 3, 4)
     * Arr.Drain().Map(x => x * x).ForEach(MsgBox) ; 16, 9, 4, 1
     * 
     * MsgBox(Arr.IsEmpty) ; true
     */
    Drain() {
        return Stream(Drain)

        Drain(&Out) {
            if (!this.IsEmpty) {
                Out := (this.Pop()?)
                return true
            }
            return false
        }
    }

    /**
     * Returns a stream of elements repeatedly `.Poll()`-ed from this deque.
     * 
     * @returns {Stream}
     * @example
     * Lifo := Array(1, 2, 3)
     * 
     * for Value in Lifo.Slurp() {
     *     MsgBox(Lifo) ; 1, 2, 3
     * }
     * MsgBox(Lifo.IsEmpty) ; true
     * 
     * @example
     * Arr := Array(1, 2, 3, 4)
     * Arr.Slurp().Map(x => x * x).ForEach(MsgBox) ; 1, 4, 9, 16
     * 
     * MsgBox(Arr.IsEmpty) ; true
     */
    Slurp() {
        return Stream(Slurp)

        Slurp(&Out) {
            if (!this.IsEmpty) {
                Out := (this.Poll()?)
                return true
            }
            return false
        }
    }
}