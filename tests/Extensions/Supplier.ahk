/**
 * A zero parameter function that represents a supplier of results.
 * 
 * @example
 * RollDice := Supplier(() => Random(1, 6))
 * 
 * RollDice() ; 3 (random)
 * RollDice() ; 5 (random)
 * 
 * TimesTwo := RollDice.Map(x => (x * 2))
 * 
 * TimesTwo() ; 8 (random)
 * TimesTwo() ; 2 (random)
 * 
 * @template T
 */
class Supplier {
    /**
     * Creates a new supplier that returns the given value.
     * 
     * @example
     * Sup := Supplier.Of(3)
     * Sup(3)
     * 
     * @template T
     * @param   {T}  Value  the value to supply  
     * @returns {Supplier<T>}
     */
    static Of(Value) => this(() => Value)

    /**
     * Creates a new supplier that requests its values from the given function.
     * 
     * @param   {() => T}  Sup  the function to be called
     */
    __New(Sup) {
        GetMethod(Sup)
        this.DefineProp("Call", {
            /**
             * Calls the supplier.
             * @returns {T}
             */
            Call: (_) => Sup()
        }).DefineProp("Map", {
            /**
             * Maps the underlying value by applying the given mapper function.
             * @template U
             * @example
             * Supplier(() => Random(1, 6)).Map(x => (x * 2))
             * 
             * @param   {(value: T) => U}  Mapper  the function to apply
             * @returns {Supplier<U>}
             */
            Call: (_, Mapper) => (
                GetMethod(Mapper) && Supplier(() => Mapper(Sup()))
            )
        })
    }
}