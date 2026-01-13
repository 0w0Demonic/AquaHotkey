/**
 * A zero parameter function that represents a supplier of results.
 * 
 * @module  <Func/Supplier>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * RollDice := Supplier(Random, 1, 6)
 * 
 * RollDice() ; 3 (random)
 * RollDice() ; 5 (random)
 * 
 * TimesTwo := RollDice.Map(x => (x * 2))
 * 
 * TimesTwo() ; 8 (random)
 * TimesTwo() ; 2 (random)
 */
class Supplier extends Func {
    /**
     * Creates a new supplier from an existing function and zero or more
     * arguments.
     * 
     * @param   {Callable}  Fn    any function
     * @param   {Any*}      Args  zero or more arguments
     * @returns {Supplier}
     * @example
     * RollDice := Supplier(Random, 1, 6)
     * 
     * RollDice() ; 3 (random)
     * RollDice() ; 5 (random)
     */
    static Call(Fn, Args*) {
        GetMethod(Fn)
        ObjSetBase(Sup, this.Prototype)
        return Sup

        Sup() => Fn(Args*)
    }

    /**
     * Returns a supplier that constantly returns the given `Value`.
     * 
     * @param   {Any}  Value  any value
     * @returns {Supplier}
     * @example
     * S := Supplier.Of(42)
     * S() ; 42
     */
    static Of(Value) {
        ObjSetBase(Constantly, this.Prototype)
        return Constantly

        Constantly() => Value
    }

    /**
     * Creates a new supplier that transforms the value of this supplier
     * using `Mapper`.
     * 
     * ```ahk
     * Mapper(Value: Any) => Any
     * ```
     * 
     * @param   {Func}  Mapper  function that transforms value
     * @returns {Supplier}
     * @example
     * S := Supplier.Of(Random, 1, 6).Map(x => (x * 2))
     * 
     * S() ; 4 (random)
     * S() ; 10 (random)
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        ObjSetBase(Mapped, ObjGetBase(this))
        return Mapped

        Mapped() => Mapper(this())
    }
}