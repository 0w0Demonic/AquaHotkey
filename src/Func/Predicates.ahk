#Include "%A_LineFile%\..\Predicate.ahk"
#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

class AquaHotkey_Predicates extends AquaHotkey {
    class String {
        static IsEmpty => Predicate((Str) => (Str == ""))
        static IsNotEmpty => Predicate((Str) => (Str != ""))
    }

    class Number {
        static Lt(x) => Predicate((a) => (a  < x))
        static Le(x) => Predicate((a) => (a <= x))
        static Gt(x) => Predicate((a) => (a  > x))
        static Ge(x) => Predicate((a) => (a >= x))
    }
}

Condition := Number.Lt(10).And(Number.Gt(6))

MsgBox(Condition(8))
MsgBox(Condition(12))