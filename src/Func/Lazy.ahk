/**
 * Represents a lazy evaluated and memoized value.
 * @example
 * RolledDice := Lazy(() => Random(1, 6))
 * 
 * RolledDice() ; 5 (randomly generated)
 * RolledDice() ; 5 (memoized)
 * 
 * TimesTwo := RolledDice.Map(x => (x * 2))
 * 
 * TimesTwo() ; 10 (evaluated)
 * TimesTwo() ; 10 (memoized)
 * 
 * @template T type of the evaluated value
 */
class Lazy {
    /**
     * Creates a new `Lazy` that requests its value from the given function.
     * @example
     * Sup := Lazy(() => Random(1, 6))
     * @constructor
     * @param   {() => T}  Fn  the function to be called
     */
    __New(Fn) {
        GetMethod(Fn)
        this.DefineProp("Call", { Call: Call })

        /**
         * Evaluates and memoizes the underlying value.
         * @returns {T}
         */
        Call(_) {
            Value := Fn()
            this.DefineProp("Call", { Call: (_) => Value })
            return Value
        }
    }

    /**
     * Maps the underlying value by applying the given mapper function.
     * @template U
     * @example
     * Lazy(() => Random(1, 6)).Map(x => (x * 2))
     * 
     * @param   {(value: T) => U}  Mapper  the function to apply
     * @returns {Lazy<U>}
     */
    Map(Mapper) => GetMethod(Mapper) && Lazy(() => Mapper(this()))
}
