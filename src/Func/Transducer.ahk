#Include "%A_LineFile%\..\Cast.ahk"

class Transducer extends Func {
    /**
     * Creates a new transducer.
     * 
     * @constructor
     * @returns {Transducer}
     */
    static Call() => this.Cast((x) => x)

    /**
     * Creates a reducer stage that only accepts elements for which the given
     * predicate holds.
     * 
     * ```ahk
     * Condition(Val: Any, Args: Any*) => Boolean
     * ```
     * 
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

    ; TODO FlatMap() ?

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
        return Step.Cast(this(Step))
    }
}

class Monoid extends Func {
    static IsInstance(Val?) {
        return IsSet(Val)
            && IsObject(Val)
            && HasMethod(Val)
            && HasProp(Val, "Empty")
    }
}

class Group extends Monoid {
    static IsInstance(Val?) {
        return super.IsInstance(Val?)
            && HasMethod(Val, "Inverse")
    }
}

class Sum extends Monoid {
    static Call(A, B) => (A + B)
    static Empty => 0
    static Inverse(X) => (-X)
}

class Mul extends Group {
    static Call(A, B) => (A * B)
    static Empty => 1
    static Inverse(X) => (1 / X)
}

class Concat extends Monoid {
    static Call(A, B) => (A . B)
    static Empty => ""
}

Square(x) => (x * x)
Gt(A, B) => (A > B)

;Td := Transducer()
;    .Map(Square)
;    .RetainIf(Gt, 100)
;    .Finally(Sum)

MsgBox(Monoid.IsInstance(Concat))