
class ImmutableMap extends Map
{
    __New(Values*) {
        if (this.Count) {
            throw Error("This map is immutable", -2)
        }
        super(Values*)
    }

    Clear() {
        throw PropertyError("This map is immutable", -2)
    }

    Delete(*) {
        throw PropertyError("This map is immutable", -2)
    }

    Set(*) {
        throw PropertyError("This map is immutable", -2)
    }

    ; TODO add CaseSense and Default? how?

    __Item[Key] {
        set {
            throw PropertyError("This map is immutable")
        }
    }
}

#Include <AquaHotkey>

class AquaHotkey_ImmutableMap {
    static __New() => (this == AquaHotkey_ImmutableMap)
                    && (IsSet(AquaHotkey)) && (AquaHotkey is Class)
                    && (AquaHotkey.__New)(this)

    class Map {
        Immutable() {
            ObjSetBase(Result := this.Clone(), ImmutableMap.Prototype)
            return Result
        }
    }
}

M := Map(1, 2, 3, 4).Immutable()
M.Set(5, 6)
MsgBox(Type(M))