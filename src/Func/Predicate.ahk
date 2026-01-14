#Include <AquaHotkey>
#Include <AquaHotkey\src\Func\Cast>

/**
 * 
 */
class Predicate extends Func {
    static Not(Fn) => this(Fn).Negate()

    static All(Fns*) {
        if (!Fns.Length) {
            throw UnsetError("No predicates specified")
        }
        for Fn in Fns {
            GetMethod(Fn)
        }
        return Predicate.Cast(All)

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
        return Predicate.Cast(None)
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
        return Predicate.Cast(Any)
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
        return Predicate.Cast((Val?) => (this(Val?) && Other(Val?, Args*)))
    }

    AndNot(Other, Args*) {
        GetMethod(Other)
        return Predicate.Cast((Val?) => (this(Val) && !Other(Val, Args*)))
    }

    Or(Other, Args*) {
        GetMethod(Other)
        return Predicate.Cast((Val) => (this(Val) || Other(Val, Args*)))
    }
    
    OrNot(Other, Args*) {
        GetMethod(Other)
        return Predicate.Cast((Val) => (this(Val) || !Other(Val, Args*)))
    }

    Negate() {
        Pred := Predicate.Cast((Val) => (!this(Val)))
        ({}.DefineProp)(Pred, "Negate", { Call: (_) => this })
        return Pred
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
