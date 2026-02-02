#Include <AquaHotkeyX>

class Monoid extends Func {
    static IsInstance(Val?) {
        return IsSet(Val)
            && IsObject(Val)
            && HasMethod(Val)
            && HasProp(Val, "Identity")
    }
}

class Sum {
    static Call(A, B) => (A + B)
    static Identity => 0
    static Inverse(A) => (-A)
}

class Mul {
    static Call(A, B) => (A * B)
    static Identity => 1
    static Inverse(A) => (1 / A)
}

class Concat {
    static Call(A, B) => (A . B)
    static Identity => ""
}
