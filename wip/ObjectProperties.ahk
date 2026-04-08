#Requires AutoHotkey v2.0
#Include <AquaHotkey\src\Interfaces\IMap>

class AquaHotkey_Object_Properties extends AquaHotkey {
class Object {
    Properties => Object.Properties(this)

    class Properties extends IMap {
        __New(Obj := Object()) {
            if (!IsObject(Obj)) {
                throw TypeError("Expected an Object",, Type(Obj))
            }
            this.DefineProp("O", { Get: (_) => Obj })
        }

        Clear() {
            static Delete := ({}.DeleteProp)

            Obj := this.O
            PropNames := Array()
            for PropName in ObjOwnProps(Obj) {
                PropNames.Push(PropName)
            }

            for PropName in PropNames {
                Delete(Obj, PropName)               
            }
        }

        Clone() => Object.Properties(this.O.Clone())

        Delete(Key) {
            Obj := this.O
            if (!ObjHasOwnProp(Obj, Key)) {
                throw UnsetItemError("property does not exist")
            }

            return ({}.DeleteProp)(Obj, Key)
        }

        Get(Key, Default?) {
            Obj := this.O
            if (ObjHasOwnProp(Obj, Key)) {
                return ({}.GetOwnPropDesc)(Obj, Key)
            }
            if (IsSet(Default)) {
                return Default
            }
            if (HasProp(this, "Default")) {
                return this.Default
            }
            throw UnsetItemError("property does not exist",, Type(Key))
        }

        Has(Key) => ObjHasOwnProp(this.O, Key)

        Set(Args*) {
            static Define := ({}.DefineProp)
            if (Args.Length & 1) {
                throw ValueError("invalid param count",, Args.Length)
            }
            Enumer := Args.__Enum(1)
            Obj := this.O
            while (Enumer(&Key) && Enumer(&Value)) {
                Define(Obj, Key, Value)
            }
        }

        __Enum(ArgSize) => ObjOwnProps(this.O)

        Count => ObjOwnPropCount(this.O)

        Capacity {
            get => ObjGetCapacity(this.O)
            set => ObjSetCapacity(this.O, value)
        }

        CaseSense {
            get => false
            set => ""
        }

        __Item[Key] {
            get => this.Get(Key)
            set => this.Set(Key, value)
        }

        AsObject() => (this.O)

        ToObject() => (this.O).Clone()
    }
}
}
