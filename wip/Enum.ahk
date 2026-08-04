
#Include <AquaHotkey\src\Base\DuckTypes>
#Include <AquaHotkey\src\Collections\Generic\Array>
#Include <AquaHotkey\src\Collections\Generic\Set>

class Enum extends Any {
    static __New(Args*) {
        if (this == Enum) {
            return
        }
        if (!Args.Length) {
            throw ValueError("no enum members specified")
        }
        M := Map()
        for Arg in Args {
            if (!(Arg is Class)) {
                throw TypeError("Expected a Class",, Type(Arg))
            }
            M.Set(Arg, true)
        }
        ({}.DefineProp)(this, "Has", { Call: (Cls, Member) => M.Has(Member )})
    }

    static IsInstance(Val?) => IsSet(Val) && this.Has(Val)

    static CanCastFrom(Val?) => IsSet(Val) && ((Val == this) || this.Has(Val))

    static ValueOf(Members*) => Members.AssertType(Array.OfType(this)).Stream().Map(C => C.Value).Reduce(BitOr)
}

#Include <AquaHotkey\src\Base\TypeInfo>
#Include <AquaHotkey\src\Base\Assertions>

#Include <AquaHotkey\src\Func\Monoid>

class Color extends Enum {
    static __New() => super.__New(Red, Green, Blue)

}

class EnumSet extends GenericSet {
    static __New(T?) {
        if (this == EnumSet) {
            return
        }
        if (!IsSet(T)) {
            throw UnsetError("unset; Expected an Enum class")
        }
        if (!(T is Class)) {
            throw TypeError("Expected a Class",, Type(T))
        }
        if (!HasBase(T, Enum)) {
            throw TypeError("Expected an Enum Class",, T.Prototype.__Class)
        }
        super.__New(Set, T)
    }

    static OfType(T) {
        if (!(T is Class)) {
            throw TypeError("Expected a Class",, Type(T))
        }
        if (!HasBase(T, Enum)) {
            throw TypeError("Expected an Enum Class",, T.Prototype.__Class)
        }
        return Set.OfType(T)
    }
}

class Red {
    static Value => 0x1
}

class Green {
    static Value => 0x2
}

class Blue {
    static Value => 0x4
}

#Include <AquaHotkey\src\Stream\Stream>
#Include <AquaHotkey\src\Base\DuckTypes\Nullable>

MsgBox(Color.ValueOf( Red, Green, Blue ))
