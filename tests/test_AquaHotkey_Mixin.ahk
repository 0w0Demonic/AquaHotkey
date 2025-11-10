#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%\..\..\AquaHotkey.ahk"
#Include <AquaHotkey\src\Extensions\Stream>

class Enumerable1 {
    static __New() {
        if (!IsSet(AquaHotkey_Stream)) {
            this.Prototype.DeleteProp("Stream")
        }
    }

    ForEach(Action, Args*) {
        GetMethod(Action)
        for Value in this {
            Action(Value, Args*)
        }
        return this
    }

    Stream() => (IsSet(Stream) && Stream)(this)
}


class Enumerable2 {
    static __New() {
        if (!IsSet(AquaHotkey_Stream)) {
            this.Prototype.DeleteProp("DoubleStream")
        }
    }

    ForEach(Action, Args*) {
        GetMethod(Action)
        for K, V in this {
            Action(K, V, Args*)
        }
        return this
    }

    DoubleStream() => (IsSet(DoubleStream) && DoubleStream)(this)
}

class Reflection extends AquaHotkey_MultiApply {
    static __New() => super.__New(Any)

    Ancestors() {
        Obj := this
        return Enumer

        Enumer(&Out) {
            if (!ObjGetBase(Obj)) {
                return false
            }
            Obj := ObjGetBase(Obj)
            Out := Obj
            return true
        }
    }
}

Map.Include(Enumerable1, Enumerable2)

MsgBox(Map().Ancestors().Stream().Map((Obj) {
    return ObjHasOwnProp(Obj, "ForEach") ? "yes" : "no"
}).Join(", "))
