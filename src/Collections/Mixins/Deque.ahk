/**
 * @mixin
 * Assumes:
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