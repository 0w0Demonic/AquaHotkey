#Include <AquaHotkey>

class CheckedMap extends Map {
    static __New(K?, V?) {
        if (this == CheckedMap) {
            ; alias `.__New()` and `.Set()`
            ({}.DefineProp)(this.Prototype, "__New",
                    ({}.GetOwnPropDesc)(this.Prototype, "Set"))
            return
        }

        if (!IsSet(K)) {
            throw UnsetError("unset value")
        }
        if (!IsSet(V)) {
            throw UnsetError("unset value")
        }
        if (!(K is Class)) {
            throw TypeError("Expected a Class",, Type(K))
        }
        if (!(V is Class)) {
            throw TypeError("Expected a Class",, Type(V))
        }
        ({}.DefineProp)(this.Prototype, "Check", { Call: TypeCheck })

        TypeCheck(_, Key, Value) {
            if (!(Key is K)) {
                throw TypeError(
                        "Expected a(n) " . K.Prototype.__Class . " as key",
                        -2, Type(Key))
            }
            if (!(Value is V)) {
                throw TypeError(
                        "Expected a(n) " . V.Prototype.__Class . " as value",
                        -2, Type(Value))
            }
        }
    }

    Check(K, V) {
        ; nop
    }

    __New(Args) => this.Set(Args*) ; (aliased)

    Set(Args*) {
        if (Args.Length & 1) {
            throw ValueError("invalid param count",, Args.Length)
        }
        Enumer := Args.__Enum(1)
        while (Enumer(&K) && Enumer(&V)) {
            this.Check(K, V)
        }
        super.Set(Args*)
    }

    __Item[Key] {
        set {
            if (IsSet(value)) {
                this.Check(Key, value)
                super[Key] := value
            } else {
                super[Key] := unset
            }
        }
    }
}

class AquaHotkey_CheckedMap extends AquaHotkey {
    class Map {
        static Of(K, V) {
            static Keys := Map()

            if (Keys.Has(K)) {
                Values := Keys.Get(K)
                if (Values.Has(V)) {
                    return Values.Get(V)
                }
            }

            if (!(K is Class)) {
                throw TypeError("Expected a Class",, Type(K))
            }
            if (!(V is Class)) {
                throw TypeError("Expected a Class",, Type(V))
            }

            ClsName := Format("{}<{}, {}>",
                    this.Prototype.__Class,
                    K.Prototype.__Class, V.Prototype.__Class)

            MapType := AquaHotkey.CreateClass(
                    CheckedMap,
                    ClsName,
                    K, V)

            if (!Keys.Has(K)) {
                Keys.Set(K, Map())
            }
            Values := Keys.Get(K)
            Values.Set(V, MapType)
            return MapType
        }
    }
}

MapCls := Map.Of(String, Integer)
M := MapCls("foo", 12, "bar", 5)

MsgBox(M is Map.Of(String, Integer))