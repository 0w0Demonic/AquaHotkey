#Include <AquaHotkey>
#Include <AquaHotkey\src\Func\Cast>

class Predicate extends Func {
    static __New() {
        (AquaHotkey_FuncCasting)
        if (this == Predicate) {
            ({}.DeleteProp)(this, "Call")
        }
    }

    ; stop AHK++ from complaining
    static Call(*) {
        throw PropertyError("(internal error)")
    }

    static Not(Fn) => this(Fn).Negate()

    static All(Fns*) {
        if (!Fns.Length) {
            throw UnsetError("No predicates specified")
        }
        for Fn in Fns {
            GetMethod(Fn)
        }
        return Predicate(All)

        All(Args*) {
            for Fn in Fns {
                if (!Fn(Args*)) {
                    return false
                }
            }
            return true
        }
    }

    static None(Fns*) {
        if (!Fns.Length) {
            throw UnsetError("No predicates specified")
        }
        for Fn in Fns {
            GetMethod(Fn)
        }
        return Predicate(None)

        None(Args*) {
            for Fn in Fns {
                if (Fn(Args*)) {
                    return false
                }
            }
            return true
        }
    }

    static Any(Fns*) {
        if (!Fns.Length) {
            throw UnsetError("No predicates specified")
        }
        for Fn in Fns {
            GetMethod(Fn)
        }
        return Predicate(Any)

        Any(Val?) {
            for Fn in Fns {
                if (Fn(Val?)) {
                    return true
                }
            }
            return false
        }
    }

    And(Other, Args*) {
        GetMethod(Other)
        return Predicate(
            (Val?) => (
                this(Val?) && Other(Val?, Args*)
            )
        )
    }

    AndNot(Other, Args*) {
        GetMethod(Other)
        return Predicate(
            (Val?) => (
                this(Val) && !Other(Val, Args*)
            )
        )
    }

    Or(Other, Args*) {
        GetMethod(Other)
        return Predicate(
            (Val) => (
                this(Val) || Other(Val, Args*)
            )
        )
    }
    
    OrNot(Other, Args*) {
        GetMethod(Other)
        return Predicate(
            (Val) => (
                this(Val) || !Other(Val, Args*)
            )
        )
    }

    Negate() {
        Pred := Predicate((Val) => (!this(Val)))
        ({}.DefineProp)(Pred, "Negate", { Call: (_) => this })
        return Pred
    }
}

class AquaHotkey_Predicate extends AquaHotkey {
    class Object {
        AsPredicate() => Predicate(this)
        IsPredicate() => Predicate.Cast(this)
    }
}

Gt(A, B) => (A > B)
Ge(A, B) => (A >= B)
Lt(A, B) => (A < B)
Le(A, B) => (A <= B)

Eq(A, B) => (A = B)
Ne(A, B) => (A != B)
StrictEq(A, B) => (A == B)
StrictNe(A, B) => (A !== B)