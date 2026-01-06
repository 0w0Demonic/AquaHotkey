
/**
 * Mixin class for types that can enumerated with 2 parameters.
 * 
 * ```ahk
 * for Value1, Value2 in Obj { ... }
 * ```
 * 
 * @mixin
 */
class Enumerable2 {
    static __New() => this.Extend(Array, Map, Enumerator)

    /**
     * Calls the given `Action` for each element.
     * 
     * ```ahk
     * Action(Value1?, Value2?, Args*) => void
     * ```
     * 
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more arguments
     * @returns {this}
     * @example
     * Map(1, 2, 3, 4).ForEach2((K, V) => MsgBox(K . " => " . V))
     */
    ForEach2(Action, Args*) {
        for Key, Value in this {
            Action(Key?, Value?, Args*)
        }
        return this
    }

    /**
     * Determines whether an element satisfies the given `Condition`.
     * 
     * ```ahk
     * Condition(Value1?, Value2?, Args*) => Boolean
     * ```
     * 
     * If present, `&Out1` and `&Out2` receive the values of the first
     * matching elements.
     * 
     * @param   {VarRef<Any>}  Out1       (out) value 1 of first match
     * @param   {VarRef<Any>}  Out2       (out) value 2 of first match
     * @param   {Func}         Condition  the given condition
     * @param   {Any*}         Args       zero or more arguments
     * @returns {this}
     * @example
     * Map(1, 2, 3, 4).ForEach2((K, V) => MsgBox(K . " => " . V))
     */
    Find2(&Out1, &Out2, Condition, Args*) {
        Out1 := unset
        Out2 := unset
        for Key, Value in this {
            if (Condition(Key?, Value?, Args*)) {
                Out1 := Key ?? unset
                Out2 := Value ?? unset
                return true
            }
        }
        return false
    }

    /**
     * Determines whether an element satisfies the given `Condition`.
     * 
     * ```ahk
     * Condition(Value1?, Value2?, Args*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     * @example
     * Map(1, 2, 3, 4).Any((K, V) => (K == 1)) ; true
     */
    Any2(Condition, Args*) {
        for Key, Value in this {
            if (Condition(Key?, Value?, Args*)) {
                return true
            }
        }
        return false
    }

    /**
     * Returns `true` if none of the elements satisfy the given `Condition`,
     * otherwise `false`.
     * 
     * ```ahk
     * Condition(Key?, Value?, Args*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     * @example
     * Map(1, 2, 3, 4).None((K, V) => (K == 3)) ; false
     */
    None2(Condition, Args*) {
        for Key, Value in this {
            if (Condition(Key?, Value?, Args*)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns `true` if all elements satisfy the given `Condition`, otherwise
     * `false`.
     * 
     * ```ahk
     * Condition(Value1?, Value2?, Args*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     * @example
     * Map(1, 2, 3, 4).All2((K, V) => (K != 6)) ; true
     */
    All2(Condition, Args*) {
        for Key, Value in this {
            if (!Condition(Key?, Value?, Args*)) {
                return false
            }
        }
        return true
    }
}