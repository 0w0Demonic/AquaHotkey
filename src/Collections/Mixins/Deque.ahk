#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Stream\Stream>
#Include <AquaHotkey\src\Collections\Mixins\Enumerable1>

/**
 * @mixin
 * Assumes:
 * - `IsEmpty => Boolean`
 * - `Pop()`
 * - `Poll()`
 */
class Deque {
    static __New() => this.Backup(Enumerable1)

    Drain() {
        return Stream(Drain)

        Drain(&Out) {
            if (!this.IsEmpty) {
                Out := this.Pop()
                return true
            }
            return false
        }
    }

    Slurp() {
        return Stream(Slurp)

        Slurp(&Out) {
            if (!this.IsEmpty) {
                Out := this.Poll()
                return true
            }
            return false
        }
    }
}