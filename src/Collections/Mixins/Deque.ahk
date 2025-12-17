#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Stream\Stream>
#Include <AquaHotkey\src\Collections\Mixins\Enumerable1>

/**
 * @mixin
 */
class Deque {
    static __New() => this.Backup(Enumerable1)

    Drain() {
        return Stream(Drain)

        Drain(&Value) {
            if (this.IsEmpty) {
                return false
            }
            Node := this.Pop()
            Value := (Node.HasValue) ? Node.Value : unset
            return true
        }
    }

    Slurp() {
        return Stream(Slurp)

        Slurp(&Value) {
            if (this.IsEmpty) {
                return false
            }
            Node := this.Poll()
            Value := (Node.HasValue) ? Node.Value : unset
            return true
        }
    }
}