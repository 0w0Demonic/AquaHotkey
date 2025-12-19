#Include <AquaHotkey>
#Include <AquaHotkey\src\Func\Cast>

/**
 * 
 */
class Comparator extends Func {
    static Num => this.Num()

    static Num(Mapper?, Args*) {
        Comp := this((A, B) => (A > B) - (B > A))
        if (!IsSet(Mapper)) {
            return Comp
        }
        return Comp.By(Mapper, Args*)
    }

    static Alpha => this.Alpha()

    static Alpha(CaseSense := false, Mapper?, Args*) {
        StrComp(A, B) => StrCompare(A, B, CaseSense)

        if (IsObject(CaseSense)) {
            throw TypeError("Expected a String or an Integer",, Type(CaseSense))
        }
        this.Cast(StrComp)
        if (!IsSet(Mapper)) {
            return StrComp
        }
        return StrComp.By(Mapper)
    }

    By(Mapper) {
        Comp(A?, B?) => this(Mapper(A?), Mapper(B?))

        GetMethod(Mapper)
        ObjSetBase(Comp, ObjGetBase(this))
        return Comp
    }

    Then(Other) {
        Comp(A?, B?) => this(A?, B?) || Other(A?, B?)

        GetMethod(Other)
        ObjSetBase(Comp, ObjGetBase(this))
        return Comp
    }

    ThenNum()   => this.Then(this.Num())
    ThenAlpha() => this.Then(this.Alpha())

    Rev() {
        Comp(A?, B?) => this(B?, A?)
        ObjSetBase(Comp, ObjGetBase(this))
        ({}.DefineProp)(Comp, "Rev", {
            Call: (_) => this
        })
        return Comp
    }

    NullFirst() {
        Comp(A?, B?) {
            if (IsSet(A)) {
                if (IsSet(B)) {
                    return this(A?, B?)
                }
                return 1
            }
            if (IsSet(B)) {
                return -1
            }
            return 0
        }
        ObjSetBase(Comp, ObjGetBase(this))
        return Comp
    }

    NullLast() {
        Comp(A?, B?) {
            if (IsSet(A)) {
                if (IsSet(B)) {
                    return this(A?, B?)
                }
                return -1
            }
            if (IsSet(B)) {
                return 1
            }
            return 0
        }
        ObjSetBase(Comp, ObjGetBase(this))
        return Comp
    }
}

class AquaHotkey_Comparator extends AquaHotkey {
    class StrCompare {
        static Locale => Comparator((A, B) => this(A, B, "Locale"))
        static Locale(A, B) => this(A, B, "Locale")

        static CS => Comparator((A, B) => this(A, B, true))
        static CS(A, B) => this(A, B, true)

        static CI => Comparator((A, B) => this(A, B, false))
        static CI(A, B) => this(A, B, false)
    }
}
