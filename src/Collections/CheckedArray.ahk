#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

class CheckedArray extends Array
{
    static __New(T?, Constraint?) {
        static Define := ({}.DefineProp)
        static DefineMethod(Obj, Name, Fn) {
            GetMethod(Fn)
            Define(Obj, Name, { Call: Fn })
        }

        if (this == CheckedArray) {
            return
        }
        if (!IsSet(T)) {
            throw UnsetError("unset value")
        }
        if (!(T is Class)) {
            throw TypeError("Expected a Class",, Type(T))
        }

        Proto := this.Prototype

        if (IsSet(Constraint)) {
            GetMethod(Constraint)
            DefineMethod(Proto, "Check", TypeCheckWithConstraint)
        } else {
            DefineMethod(Proto, "Check", TypeCheck)
        }

        TypeCheck(_, Val?) {
            if (IsSet(Val) && !(Val is T)) {
                throw TypeError("Expected a(n) " . T.Prototype.__Class,,
                                Type(Val))
            }
        }

        TypeCheckWithConstraint(_, Val?) {
            if (IsSet(Val) && !(Val is T)) {
                throw TypeError("Expected a(n) " . T.Prototype.__Class,,
                                Type(Val))
            }
            if (!Constraint(Val?)) {
                throw ValueError("Failed assertion",,
                                 GetMethod(Constraint).Name)
            }
        }
    }

    __New(Values*) {
        for Value in Values {
            this.Check(Value?)
        }
        super.__New(Values*)
    }

    Check(Val?) {
        ; nop
    }

    Push(Values*) {
        for Value in Values {
            this.Check(Value?)
        }
        return super.Push(Values*)
    }

    InsertAt(Idx, Values*) {
        for Value in Values {
            this.Check(Value?)
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

class AquaHotkey_Verbose {

}

class AquaHotkey_CheckedArray extends AquaHotkey
{
    class Any {
        static __Item[Constraint?] {
            get {
                static NONE := false
                static Classes := Map()

                if (Classes.Has(this)) {
                    Variations := Classes.Get(this)
                    Variation  := (IsSet(Constraint) && Constraint)
                    if (Variations.Has(Variation)) {
                        return Variations.Get(Variation)
                    }
                }

                ClsName := this.Prototype.__Class . "[]"
                ArrayType := AquaHotkey.CreateClass(
                        CheckedArray,
                        ClsName,
                        this, Constraint?)
                
                if (!Classes.Has(this)) {
                    Classes.Set(this, Map())
                }
                Variations := Classes.Get(this)

                if (IsSet(Constraint)) {
                    GetMethod(Constraint)
                    Variations.Set(Constraint, ArrayType)
                } else {
                    Variations.Set(NONE, ArrayType)
                }
                return ArrayType
            }
        }
    }

    class Array {
        static Of(T) {
            if (!(T is Class)) {
                throw TypeError("Expected a Class",, Type(T))
            }
            return T[]
        }

        static Checked(Constraint) {
            GetMethod(Constraint)
            return Any[Constraint]
        }
    }

    static __New() {
        this.RequiresVersion(">v2.1-alpha.3", "Any")
        super.__New()
    }
}

; our "constraint" which all elements must fulfill
NonNull(Val?) => (IsSet(Val))

; an array of strings, in which elements *must* have a value
; (as specified by `NonNull`)
StringArray := String[NonNull]

; create a new array of non-null strings
Arr := StringArray("value 1", "value 2")

; alternatively just do this directly
Arr := String[NonNull]("value 1", "value2")

; yup, this also works.
MsgBox(Arr is String[NonNull])

Arr.Push(unset) ; Error! failed assertion (NonNull).
