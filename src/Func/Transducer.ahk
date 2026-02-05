#Include "%A_LineFile%\..\Cast.ahk"
#Include "%A_LineFile%\..\Func.ahk"

/**
 * Utility for creating reduction operations.
 * 
 * @module  <Func/Transducer>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see     https://clojure.org/reference/transducers
 * @example
 * Square(x) => (x * 2)
 * SumOfSquares := Transducer().Map(Square).Finally(Sum)
 * 
 * Array(1, 2, 3, 4).Reduce(SumOfSquares) ; (1 + 4 + 9 + 16) --> 30
 */
class Transducer extends Func {
    /**
     * Creates a new transducer.
     * 
     * @constructor
     * @returns {Transducer}
     */
    static Call() => this.Cast(Self)

    /**
     * Creates a reducer stage that only accepts elements for which the given
     * predicate holds.
     * 
     * ```ahk
     * Condition(Val: Any, Args: Any*) => Boolean
     * ```
     * 
     * @param   {Any*}  Args       zero or more arguments for `Condition`
     * @param   {Func}  Condition  the given condition
     * @returns {Transducer}
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Factory)

        Factory(Step) {
            GetMethod(Step)
            return this(RetainIf)

            RetainIf(Acc, Item) {
                if (Condition(Item, Args*)) {
                    return Step(Acc, Item)
                }
                return Acc
            }
        }
    }

    /**
     * Creates a reducer stage that only accepts elements for which the given
     * predicate doesn't hold.
     * 
     * ```ahk
     * Condition(Val: Any, Args: Any*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for `Condition`
     * @returns {Transducer}
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Factory)

        Factory(Step) {
            GetMethod(Step)
            return this(RemoveIf)

            RemoveIf(Acc, Item) {
                if (Condition(Item, Args*)) {
                    return Acc
                }
                return Step(Acc, Item)
            }
        }
    }

    /**
     * Creates a reducer stage where elements are transformed by applying
     * the given mapper function.
     * 
     * ```ahk
     * Mapper(Val: Any, Args: Any*) => Any
     * ```
     * 
     * @param   {Func}  Mapper  the mapper function
     * @param   {Any*}  Args    zero or more arguments for `Mapper`
     * @returns {Transducer}
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(Factory)

        Factory(Step) {
            GetMethod(Step)
            return this(Map)

            Map(Acc, Item) {
                return Step(Acc, Mapper(Item, Args*))
            }
        }
    }

    /**
     * Creates a reducer function from the given reducer.
     * 
     * @param   {Reducer}  Step  the reducer
     * @returns {Reducer}
     * @example
     * SumOfSquares := Transducer().Map(Square).Finally(Sum)
     * 
     * Array(1, 2, 3, 4).Reduce(SumOfSquares, 0)
     */
    Finally(Step) {
        GetMethod(Step)
        Result := this(Step)
        if (Step is Func) {
            Step.Cast(Result)
        }
        return Result
    }
}