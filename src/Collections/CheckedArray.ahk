#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

class CheckedArray extends Array
{
    static __New(T?) {
        if (this == CheckedArray) {
            return
        }
        if (!IsSet(T)) {
            throw UnsetError("Expected a Class or Func")
        }
        Proto := this.Prototype
        if (T is Class) {
            Proto.DefineProp("Check", { Call: TypeCheck })
        } else {
            GetMethod(T)
            Proto.DefineProp("Check", { Call: (_, Val) => T(Val) })
        }

        __New.DefineProp("Name", {
            Get: (_) => this.Prototype.__Class . ".__New"
        })

        Proto.DefineProp("__New", { Call: __New })

        TypeCheck(_, Val) {
            if (!(Val is T)) {
                throw TypeError("Expected a(n) " . T.Prototype.__Class,,
                                Type(Val))
            }
        }

        __New(Arr, Values*) {
            for Value in Values {
                Arr.Check(Value)
            }
            return (Array.Prototype.__New)(Arr, Values*)
        }
    }

    Check(Value?) {
        
    }
    
    ; TODO add getter?

    Check {
        set {
            GetMethod(value)
            this.DefineProp("Check", { Call: value })
        }
    }

    __New(Values*) {
        for Value in Values {
            this.Check(Value)
        }
        super.__New(Values*)
    }

    Push(Values*) {
        for Value in Values {
            this.Check(Value)
        }
        return super.Push(Values*)
    }

    InsertAt(Idx, Values*) {
        for Value in Values {
            this.Check(Value)
        }
        return super.InsertAt(Idx, Values*)
    }

    __Item[Key] {
        set {
            this.Check(value)
            super[Key] := value
        }
    }
}

class AquaHotkey_CheckedArray extends AquaHotkey
{
    class Any {
        static __Item {
            get {
                static Classes := Map()
                if (Classes.Has(this)) {
                    return Classes.Get(this)
                }
                ClsName := this.Prototype.__Class . "[]"
                ArrayType := AquaHotkey.CreateClass(CheckedArray, ClsName, this)
                Classes[this] := ArrayType
                return ArrayType
            }
        }
    }

    static __New() {
        this.RequiresVersion(">v2.1-alpha.3", "Any")
        super.__New()
    }
}