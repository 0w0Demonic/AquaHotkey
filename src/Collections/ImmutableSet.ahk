#Include "%A_LineFile%\..\Set.ahk"

/**
 * 
 */
class ImmutableSet extends ISet
{
    static FromSet(S) {
        if (!S.Is(ISet)) {
            throw TypeError("Expected an ISet",, Type(S))
        }
        if (S is ImmutableSet) {
            return S
        }
        Obj := Object()
        Obj.DefineProp("S", { Get: (_) => S })
        ObjSetBase(Obj, this.Prototype)
        return Obj
    }

    static Call(Values*) => this.FromSet(Set(Values*))

    Add(*) {
        throw PropertyError("This set is immutable", -2)
    }

    Clear() {
        throw PropertyError("This set is immutable", -2)
    }

    Clone() {
        S := this.S.Clone()
        Obj := Object()
        Obj.DefineProp("S", { Get: (_) => S })
        ObjSetBase(Obj, ObjGetBase(this))
        return Obj
    }

    Delete(*) {
        throw PropertyError("This set is immutable", -2)
    }

}

class AquaHotkey_ImmutableSet {
    static __New() => (this == AquaHotkey_ImmutableSet)
                && IsSet(AquaHotkey) && (AquaHotkey is Class)
                && (AquaHotkey.__New)(this)

    class Set {
        Freeze() => ImmutableSet.FromSet(this)
    }
}

S := Map(1, 2, 3, 4).AsSet(ImmutableSet)