
/**
 * Mixin class for types that can be enumeraed.
 */
class Enumerable1 {
    /**
     * Executes an action for each element.
     * 
     * @example
     * Array(1, 2, 3).ForEach(MsgBox)
     * 
     * @param   {Func}  Action  the function to call
     * @param   {Any*}  Args    zero or more arguments for the function
     */
    ForEach(Action, Args*) {
        for Value in this {
            Action(Value?, Args*)
        }
        return this
    }

    /**
     * Collects all elements into an array.
     * 
     * @returns {Array}
     * @example
     */
    ToArray() => Array(this*)

    /**
     * 
     */
    To(T) => T(this*)

    /**
     * 
     */
    Stream() => (Stream?)(this*)


    ; TODO let stream handle this?

    ToSet() {

    }

    /**
     * 
     */
    Reduce(Combiner, Identity?) {

    }

    /**
     * 
     * @param   {VarRef<Any>}  Out        (out) the result, if any
     * @param   {Func}         Condition  the given condition
     * @param   {Any*}         Args       zero or more arguments
     */
    Any(&Out, Condition, Args*) {
        Out := unset
        for Value in this {
            if (Condition(Value?, Args*)) {
                Out := Value ?? unset
                return true
            }
        }
        return false
    }

    /**
     * 
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     */
    None(Condition, Args*) {
        for Value in this {
            if (Condition(Value?, Args*)) {
                return false
            }
        }
        return true
    }

    /**
     * 
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     */
    All(Condition, Args*) {
        for Value in this {
            if (!Condition(Value?, Args*)) {
                return false
            }
        }
        return true
    }

    ; TODO mix this with Collector API?
    /**
     * 
     * 
     * @param   {Func}  Coll  collector that receives elements
     * @returns {Any}
     */
    Collect(Coll) {
        GetMethod(Coll)
        return Coll(this*)
    }
}