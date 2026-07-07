#Include <AquaHotkey>
#Include <AquaHotkey\src\Interfaces\ISet>

class IMapEntry {
    static IsInstance(Val?) => IsSet(Val)
        && IsObject(Val)
        ; TODO change to just `HasProp()`?
        ;      let's not make it too complicated, though
        && ObjHasOwnProp(Val, "Key")
        && ObjHasOwnProp(Val, "Value")

    IsInstance(Val?) => IsSet(Val) && HasBase(Val, ObjGetBase(this))

    __New(Key, Value) {
        ({}.DefineProp)(this, "Key", { Get: (_) => Key })
        ({}.DefineProp)(this, "Value", { Get: (_) => Value })
    }

    Key {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    Value {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    Copy() => IMapEntry(this.Key, this.Value)

    Exists => (this is MapEntry) && (this.M).Has(this.Key)

    Move(NewKey) {
        throw PropertyError("not implemented")
    }

    ToString() => Type(this)
        . " { " . String(this.Key) . ": " . String(this.Value) . " }"
}


; TODO add `comparingByKey()` etc.

class MapEntry extends IMapEntry {
    __New(MapObj, Key) {
        if (!MapObj.Is(IMap)) {
            throw TypeError("Expected an IMap",, Type(MapObj))
        }
        ({}.DefineProp)(this, "M", { Get: (_) => MapObj })
        ({}.DefineProp)(this, "Key", { Get: (_) => Key })
    }

    Key {
        set {
            ; TODO what about `unset?`
            (this.M).Set(this.Key, (this.M).Delete(this.Key))
        }
    }

    Value {
        get => (this.M).Get(this, this.Key)
        set {
            (this.M).Set(this, this.Key, value)
        }
    }

    ; TODO just use `.Clone()`? add static version?
    Copy() => IMapEntry(this.Key, this.Value)
}

; TODO flyweight? use `.DefineProp()` to "inline" some props?

class MapEntrySet extends ISet {
    __New(MapObj) {
        if (!IMap.IsInstance(MapObj)) {
            throw TypeError("Expected an IMap",, Type(MapObj))
        }
        ({}.DefineProp)(this, "M", { Get: (_) => MapObj })
    }

    Clear() {
        (this.M).Clear()
    }

    ; TODO clone how?
    Clone() {

    }

    Delete(Entries*) {
        Count := 0
        M := (this.M)

        for Entry in Entries {
            if (!IMapEntry.IsInstance(Entry?)) {
                continue
            }
            Count += !!M.TryDelete(Entry.Key)
        }
        return Count
    }

    ; TODO how to perform equality checks
    Contains(Entry) {
        if (!IMapEntry.IsInstance(Entry)) {
            return false
        }
        return (this.M).TryGet(Entry.Key, &Candidate)
            && (Entry.Key).Eq(Candidate)
    }

    ; TODO allow `ArgSize == 2`?
    __Enum(ArgSize) {
        M := (this.M)
        Enumer := M.__Enum(1)
        return MapToEntries

        MapToEntries(&Out) {
            if (Enumer(&Key, &Value)) {
                Out := MapEntry(M, Key)
                return true
            }
            return false
        }
    }

    Size => (this.M).Count
}

class AquaHotkey_IMapEntry extends AquaHotkey {
    class IMap {
        ; TODO "inline" this
        ToEntrySet() => MapEntrySet(this)
    }
}


M := Map("foo", "bar", "baz", "qux")

S := M.ToEntrySet()

S.Stream().RetainIf(Entry => (Entry.Key).Eq("foo"))
    .ForEach(Entry => (Entry.Key := "42"))

MsgBox(M.ToString())
