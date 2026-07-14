#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Parse\Patterns\Json>
#Include <AquaHotkeyX>

/**
 * Experimental JSON bindings.
 */
class AquaHotkey_FromJson extends AquaHotkey {
    static __New() {
        ; this has to load first because we're overriding `ParseJson()`.
        (AquaHotkey_ToJson)

        super.__New()
    }

    class Primitive {
        /**
         * Parses this JSON string into an AHK value, optionally "casting" and
         * reconstructing into the specified object.
         * 
         * @param   {Any?}  T  the type to be reconstructed
         * @returns {Any}
         */
        ParseJson(T?) {
            static Psr := (Json.Parser)
            Result := Psr.Parse(&this)
            if (IsSet(T)) {
                T.CastFromJson(&Result)
            }
            return Result
        }

    }

    class Func {
        CastFromJson(&Val) {
            Val := this(Val)
        }
    }

    class Number {
        static CastFromJson(&Val) {
            if (!IsNumber(Val)) {
                throw TypeError("Expected a Number",, Type(Val))
            }
            Val := this(Val)
        }
    }

    class String {
        static CastFromJson(&Val) {
            if (!(Val is String)) {
                throw TypeError("Expected a String",, Type(Val))
            }
        }
    }

    class Object {
        ; TODO does this need a boolean success flag?
        /**
         * Reconstructs a complex AHK object from JSON.
         * 
         * @param   {VarRef<String>}  Val  JSON in, AHK out
         */
        static CastFromJson(&Val) {
            Curr := this
            while (!ObjHasOwnProp(Curr, "Call")) {
                Curr := ObjGetBase(Curr)
            }
            Obj := Curr()
            ObjSetBase(Obj, this.Prototype)
            Obj.__Init()
            Obj.FromJson(Val)
            Val := Obj
        }

        CastFromJson(&Val) {
            static GetProp := {}.GetOwnPropDesc
            static Define := {}.DefineProp

            if (ObjGetBase(this) != Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(this))
            }
            if (ObjGetBase(Val) != Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(Val))
            }
            for PropertyName in ObjOwnProps(this) {
                PropDesc := GetProp(this, PropertyName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    continue
                }
                T := PropDesc.Value

                if (!ObjHasOwnProp(Val, PropertyName)) {
                    throw PropertyError("property not found",, PropertyName)
                }
                PropDesc := GetProp(Val, PropertyName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    throw ValueError("not a value property")
                }
                Value := PropDesc.Value
                T.CastFromJson(&Value)
                Define(Val, PropertyName, { Value: Value })
            }
        }
    }

    class Any {
        static CastFromJson(&Val) {
            if (!(Val is this)) {
                throw TypeError("Expected type " . this.Prototype.__Class,,
                        Type(Val))
            }
        }

        FromJson(Val) {
            throw MethodError("not applicable")
        }
    }

    class Map {
        FromJson(Val) {
            if (ObjGetBase(Val) != Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(Val))
            }
            for Key, Value in ObjOwnProps(Val) {
                this.Set(Key, Value)
            }
        }
    }

    class Array {
        CastFromJson(&Val) {
            if (ObjGetBase(Val) != Array.Prototype) {
                throw TypeError("Expected a plain array",, Type(Val))
            }
            if (Val.Length != this.Length) {
                throw ValueError("invalid size (TODO error message)")
            }
            loop (this.Length) {
                Item := Val[A_Index]
                this[A_Index].CastFromJson(&Item)
                Val[A_Index] := Item
            }
        }
    }
    
}

class Person {
    __New(Age) {
        this.Age := Age
    }

    FromJson(Val) {
        this.__New(Val.AssertType(IsInteger))
    }
}

Json.EnableComments()

42.ParseJson((V) => (V * 2))
  .ToString()
  .MsgBox()
