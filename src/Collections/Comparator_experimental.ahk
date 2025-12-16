/**
 * 
 */
class Comparator extends Func {
    static Call(Fn) => this.Cast(ObjBindMethod(Fn))

    static Cast(Fn) {
        Fn := ObjBindMethod(Fn)
        ObjSetBase(Fn, this.Prototype)
        return Fn
    }

    static Num => this.Num()

    static Num(Mapper?, Args*) {
        
    }

    static Alpha => this.Alpha()

    static Alpha(CaseSense := false, Mapper?, Args*) {

    }

    By() {

    }

    Then() {

    }

    ThenNum() {

    }

    ThenAlpha() {

    }

    Rev() {

    }

    NullFirst() {

    }

    NullLast() {
        
    }
}

NumberCompare(A, B) => (A > B) - (B > A)

Comp := Comparator(NumberCompare)

Comparator.Cast(StrCompare)

MsgBox(Comp(1, 2))

class AquaHotkey_Comparator extends AquaHotkey {
    static __New() {
        ObjSetBase(StrCompare, Comparator.Prototype)
        ObjSetBase(NumberCompare, Comparator.Prototype)
    }

    class StrCompare {
        static Locale => Comparator(ObjBindMethod(this,,, "Locale"))
        static CS     => Comparator(ObjBindMethod(this,,, true))
        static CI     => Comparator(ObjBindMethod(this,,, false))
    }
}
