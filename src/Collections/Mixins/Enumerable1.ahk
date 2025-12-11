
/**
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
    }

    ; TODO let stream handle this?

    /**
     * 
     */
    Map(Mapper) {
        
    }

    /**
     * 
     */
    ToArray() => Array(this*)

    ; TODO make this optional
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
     */
    Collect(Coll) {
        GetMethod(Coll)
        return Coll(this*)
    }
}