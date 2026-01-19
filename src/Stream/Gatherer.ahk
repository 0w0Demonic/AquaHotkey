#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Gatherers are functions that can transform a sequence of input
 * elements - usually an `Enumerator` or {@link Stream `Stream`} - into
 * a sequence of output elements.
 * 
 * They are available for use via the `.Gather(Gath)` method which is defined
 * for all streams.
 * 
 * ```
 * ; <[1, 2, 3], [2, 3, 4], [3, 4, 5]>
 * Range(5).Gather(WindowSliding(3))
 * ```
 * 
 * ---
 * 
 * **How it Works**:
 * 
 * Gatherers use the following type signature:
 * 
 * ```ahk
 * GathererOp(Upstream: Enumerator, Downstream: Func) => Boolean
 * ```
 * 
 * `Upstream` resembles the sequence of input elements, in the form of an
 * Enumerator object.
 * 
 * To output a `Value` into the output stream, use `Downstream(Value)`.
 * 
 * The return value should be `true`/`1` when successful, otherwise `false`/`0`
 * to indicate there are no more elements.
 * 
 * ---
 * 
 * @module  <Stream/Gatherer>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link Stream}
 * @example
 * TimesTwo(Upstream, Downstream) {
 *     if (!Upstream(&Value)) {
 *         return false
 *     }
 *     Downstream(Value?, Value?)
 *     return true
 * }
 * 
 * ; <1, 1, 2, 2, 3, 3>
 * Array(1, 2, 3).Stream().Gather(TimesTwo)
 */
class Gatherer extends Func {
} ; (empty marker class)

/**
 * Creates a {@link Gatherer} that collects elements in the form of fixed
 * windows.
 * 
 * @param   {Integer}  Size  window size
 * @returns {Gatherer}
 * @example
 * ; <[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]>
 * Range(10).Gather(WindowFixed(3))
 */
WindowFixed(Size) {
    if (!IsInteger(Size)) {
        throw TypeError("Expected an Integer",, Type(Size))
    }
    if (Size <= 0) {
        throw ValueError("<= 0",, Size)
    }
    Arr := Array()
    return Gatherer.Cast(WindowFixed)

    WindowFixed(Upstream, Downstream) {
        if (!Upstream(&Value)) {
            Downstream(Arr.Clone())
            return false
        }
        Arr.Push(Value?)
        if (Arr.Length == Size) {
            Downstream(Arr.Clone())
            Arr.Length := 0
        }
        return true
    }
}

/**
 * Creates a {@link Gatherer} that collects elements in the form of sliding
 * windows.
 * 
 * @param   {Integer}  Size  window size
 * @returns {Gatherer}
 * @example
 * ; <[1, 2, 3], [2, 3, 4], [3, 4, 5]>
 * Range(5).Gather(WindowSliding(3))
 */
WindowSliding(Size) {
    if (!IsInteger(Size)) {
        throw TypeError("Expected an Integer",, Type(Size))
    }
    if (Size <= 0) {
        throw ValueError("<= 0",, Size)
    }
    Arr := Array()
    return Gatherer.Cast(WindowSliding)

    WindowSliding(Upstream, Downstream) {
        if (!Upstream(&Value)) {
            Downstream(Arr.Clone())
            return false
        }
        Arr.Push(Value?)
        if (Arr.Length == Size) {
            Downstream(Arr.Clone())
            Arr.RemoveAt(1)
        }
        return true
    }
}

/**
 * Creates a {@link Gatherer} that collects a "running result" of its input
 * elements.
 * 
 * ```ahk
 * Merger(Left: Any, Right: Any?) => Any
 * ```
 * 
 * @param   {Any}   InitialValue  initial value
 * @param   {Func}  Merger        merges two values
 * @returns {Gatherer}
 * @example
 * ; <1, 3, 6, 10>
 * Array(1, 2, 3, 4).Stream().Gather(  Scan(0, (A, B) => (A + B))  )
 */
Scan(InitialValue, Merger) {
    GetMethod(Merger)
    Result := InitialValue
    return Gatherer.Cast(Scan)

    Scan(Upstream, Downstream) {
        if (!Upstream(&Value)) {
            return false
        }
        Result := Merger(Result, Value?)
        Downstream(Result)
        return true
    }
}

class AquaHotkey_Gatherer extends AquaHotkey {
    class Stream {
        /**
         * Returns a stream consisting of the result of appyling the given
         * {@link Gatherer} to the elements of this stream.
         * 
         * @param   {Gatherer}  Gath  gatherer operation
         * @returns {Stream}
         * @example
         * ; <[1, 2, 3], [2, 3, 4], [3, 4, 5]>
         * Range(5).Gather(WindowSliding(3))
         */
        Gather(Gath) {
            GetMethod(Gath)
            Arr        := Array()
            Downstream := ObjBindMethod(Arr, "Push")
            Enumer     := (*) => false
            return this.Cast(Gather)

            Gather(&Out) {
                loop {
                    ; drain the array
                    if (Enumer(&Out)) {
                        return true
                    }
                    Arr.Length := 0

                    ; fill it up again by using our gatherer
                    if (!Gath(this, Downstream)) {
                        return false
                    }
                    Enumer := Arr.__Enum(1)
                }
            }
        }
    }
}