#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

;@region Func
/**
 * Basic function composition.
 * 
 * @module  <Func/Func>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Func extends AquaHotkey {
    class Func {
        ;@region Composition
        /**
         * Returns a composed function that first applies this function with
         * the given input, and then forwards the result to `After` as first
         * parameter, followed by zero or more additional arguments
         * `NextArgs*`.
         * 
         * @param   {Func}  After     function to apply after this function
         * @param   {Any*}  NextArgs  zero or more additional arguments
         * @returns {Func}
         * @example
         * TimesTwo(x) => (x * 2)
         * PlusFive(x) => (x + 5)
         * 
         * TimesTwoPlusFive := TimesTwo.AndThen(PlusFive)
         * TimesTwoPlusFive(3) ; 11
         */
        AndThen(After, NextArgs*) {
            GetMethod(After)
            if (After is Func) {
                ObjSetBase(AndThen, ObjGetBase(After))
            }
            return AndThen

            AndThen(Args*) {
                return After( this(Args*), NextArgs* )
            }
        }

        /**
         * Returns a composed function that first applies `Before` with
         * the given input, and then forwards the result to this function,
         * followed by zero or more additional arguments `NextArgs*`.
         * 
         * @param   {Func}  Before    function to apply before this function
         * @param   {Any*}  NextArgs  zero or more additional arguments
         * @returns {Func}
         * @example
         * TimesTwo(x) => (x * 2)
         * PlusFive(x) => (x + 5)
         * 
         * PlusFiveTimesTwo := TimesTwo.Compose(PlusFive)
         * PlusFiveTimesTwo(3) ; 16
         */
        Compose(Before, NextArgs*) {
            GetMethod(Before)
            return (Args*) => this( Before(Args*), NextArgs* )
        }
        ;@endregion

        ;@region Memoization
        /**
         * Returns a memoized version of this function, caching previously
         * computed results in a Map to avoid redundant computation.
         * 
         * ```ahk
         * Hasher(Args: Any*) => Any
         * ```
         * 
         * @param   {Func?}  Hasher    creates map keys
         * @param   {Any?}   MapParam  internal map options
         * @returns {Func}
         * @example
         * Fibonacci(x) {
         *     if (x > 1) {
         *         ; If you recurse, you need to call the memoized version.
         *         return FibonacciMemo(x - 2) + FibonacciMemo(x - 1)
         *     }
         *     return 1
         * }
         * FibonacciMemo := Fibonacci.Memoized()
         * FibonacciMemo(80) ; 23416728348467685
         */
        Memoized(Hasher?, MapParam := Map()) {
            Cache := IMap.Create(MapParam)

            Result := IsSet(Hasher) ? HashedMemoized : Memoized
            Result.DefineProp("Memoized", { Call: x => x })
            return Result

            Memoized(Key) {
                if (!Cache.Has(Key)) {
                    Value := this(Key)
                    Cache.Set(Key, Value)
                    return Value
                }
                return Cache.Get(Key)
            }

            HashedMemoized(Args*) {
                Key := Hasher(Args*)
                if (!Cache.Has(Key)) {
                    Value := this(Args*)
                    Cache.Set(Key, Value)
                    return Value
                }
                return Cache.Get(Key)
            }
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Wrapping

        /**
         * Wraps the function with `try/catch/finally` logic.
         * 
         * ```ahk
         * OnCatch(Err: Error) => void
         * OnFinally() => void
         * ```
         * 
         * @param   {Func?}  OnCatch    error handler called if error is thrown
         * @param   {Func?}  OnFinally  callback that resembles `finally` block
         * @returns {Func}
         * @example
         * Divide(a, b) => (a / b)
         * SafeDivide := Divide.WithCatch(
         *     (Err) => MsgBox(Err.Message),
         *     () => MsgBox("finished")
         * )
         */
        WithCatch(OnCatch := DefaultOnCatch, OnFinally := DefaultOnFinally) {
            static DefaultOnCatch(*) {
            } ; do nothing
            static DefaultOnFinally() {
            } ; do nothing

            GetMethod(OnCatch)
            GetMethod(OnFinally)
            return WithCatch

            WithCatch(Args*) {
                try {
                    return this(Args*)
                } catch as Err {
                    OnCatch(Err)
                } finally {
                    OnFinally()
                }
            }
        }

        /**
         * Wraps the function so that it executes multiple times in a loop.
         * The resulting function gains access to `A_Index`.
         * 
         * @param   {Integer}  Count  number of repeats
         * @returns {Func}
         * @example
         * Print() => MsgBox(A_Index)
         * Print.Loop(100).Call()
         */
        Loop(Count) {
            return WithLoop

            WithLoop(Args*) {
                loop (Count) {
                    this(Args*)
                }
            }
        }

        ;@endregion
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Self()

/**
 * Represents the identity function which always returns its input argument.
 * 
 * @param   {Any}  x  any value
 * @returns {Any}
 * @example
 * Self(23) ; --> 23
 */
Self(x) => x

;@endregion