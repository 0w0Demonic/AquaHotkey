#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Shorthand methods for `ComValue` types.
 * 
 * @example
 * ; VARIANT Types as Constants
 * MsgBox(ComValue.BSTR)    ; 0x0008 (VT_BSTR)
 * MsgBox(ComObjArray.BSTR) ; 0x2008 (VT_BSTR | VT_ARRAY)
 * MsgBox(ComValueRef.BSTR) ; 0x4008 (VT_BSTR | VT_BYREF)
 * 
 * ; VARIANT Type Constructors
 * Str := ComValue.BSTR("foo")
 * Ref := ComValueRef.BSTR(Buffer.OfString("foo"))
 * Arr := ComObjArray.BSTR(16, 2) ; ComObjArray(0x08, 16, 2)
 * 
 * ; `.Get()` and `.Set()` for `ComValueRef`
 * Ref := ComValueRef.VARIANT(Buffer(24, 0)).Set("value")
 * MsgBox(Ref.Get())
 * 
 * @module  <Base/ComValue>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_ComValue extends AquaHotkey
{
;@region ComValue
class ComValue {
    static __New() {
        static Define := (Object.Prototype.DefineProp)
        static ARRAY  := 0x2000
        static BYREF  := 0x4000

        IndexLastDot     := InStr(this.Prototype.__Class, ".",,, -1)
        RootClass        := SubStr(this.Prototype.__Class, 1, IndexLastDot)
        Name_ComValue    := RootClass . "ComValue"
        Name_ComValueRef := RootClass . "ComValueRef"
        Name_ComObjArray := RootClass . "ComObjArray"

        ; ComValue.ARRAY { get => 0x2000 }
        ; ComValue.BYREF { get => 0x4000 }
        Define(this, "ARRAY", { Get: Constant(Name_ComValue, "ARRAY", ARRAY) })
        Define(this, "BYREF", { Get: Constant(Name_ComValue, "BYREF", BYREF) })

        for Arr in [
                ["EMPTY",    0x00], ["NULL",     0x01], ["INT16",    0x02],
                ["INT32",    0x03], ["FLOAT32",  0x04], ["FLOAT64",  0x05],
                ["CURRENCY", 0x06], ["DATE",     0x07], ["BSTR",     0x08],
                ["DISPATCH", 0x09], ["ERROR",    0x0A], ["BOOL",     0x0B],
                ["VARIANT",  0x0C], ["UNKNOWN",  0x0D], ["DECIMAL",  0x0E],
                ["INT8",     0x10], ["UINT8",    0x11], ["UINT16",   0x12],
                ["UINT32",   0x13], ["INT64",    0x14], ["UINT64",   0x15],
                ["INT",      0x16], ["UINT",     0x17], ["RECORD",   0x24]]
        {
            Name  := Arr[1]
            Value := Arr[2]

            ; e.g.:
            ; - ComValue.BSTR        => 0x0008
            ; - ComValue.BSTR("foo") => ComValue(0x0008, "foo")
            Define(ComValue, Name, {
                Get:  Constant(Name_ComValue, Name, Value),
                Call: Constructor(Name_ComValue, Name, Value)})

            ; e.g.:
            ; - ComValueRef.BSTR      => (0x0008 | 0x4000)
            ; - ComValueRef.BSTR(Ptr) => ComValue(0x0008 | 0x4000, Ptr)
            Define(ComValueRef, Name, {
                Get:  Constant(Name_ComValueRef, Name, Value | BYREF),
                Call: RefConstructor(Name_ComValueRef, Name, Value | BYREF)})

            ; e.g.:
            ; - ComObjArray.BSTR    => (0x0008 | 0x2000)
            ; - ComObjArray.BSTR(3) => ComObjArray(0x0008, 3)
            Define(ComObjArray, Name, {
                Get:  Constant(Name_ComObjArray, Name, Value | ARRAY),
                Call: ArrConstructor(Name_ComObjArray, Name, Value)})
        }

        static Constant(ClassName, VarName, VarType) {
            Name := ClassName . "." . VarName . ".Get"
            Getter.DefineProp("Name", { Get: (_) => Name })
            return Getter

            Getter(Cls) {
                if ((Cls == ComObject) || HasBase(Cls, ComObject)) {
                    throw TypeError("invalid class",, Cls.Prototype.__Class)
                }
                return VarType
            }
        }

        static Constructor(ClassName, VarName, VarType) {
            Name := ClassName . "." . VarName
            Cons.DefineProp("Name", { Get: (_) => Name })
            return Cons

            Cons(Cls, Value, Flags?) {
                if ((Cls == ComObject) || HasBase(Cls, ComObject)) {
                    throw TypeError("invalid class",, Cls.Prototype.__Class)
                }
                return Cls(VarType, Value, Flags?)
            }
        }

        static RefConstructor(ClassName, VarName, VarType) {
            Name := ClassName . "." . VarName
            Cons.DefineProp("Name", { Get: (_) => Name })
            return Cons

            Cons(Cls, Value) {
                if (!IsInteger(Value)) {
                    if (!(Value is Buffer) && !HasProp(Value, "Ptr")) {
                        throw TypeError("Expected an Integer or a Buffer",,
                                        Type(Value))
                    }
                    Value := Value.Ptr
                }
                return Cls(VarType, Value)
            }
        }

        static ArrConstructor(ClassName, VarName, VarType) {
            Name := ClassName . "." . VarName
            Cons.DefineProp("Name", { Get: (_) => Name })
            return Cons

            Cons(Cls, Dimensions*) {
                return Cls(VarType, Dimensions*)
            }
        }
    }
} ; class ComValue

;@endregion
;-------------------------------------------------------------------------------
;@region ComValueRef

class ComValueRef {
    ; just reuse the existing `__Item[]` getter instead of wrapping
    static __New() => ({}.DefineProp)(
        this.Prototype,
        "Get",
        { Call: ({}.GetOwnPropDesc)(ComValueRef.Prototype, "__Item").Get })

    /**
     * Gets the value contained by this `ComValueRef`.
     * 
     * @returns {Any} the referenced value
     */
    Get() => this[]

    /**
     * Sets the value reference by this `ComValueRef`.
     * 
     * @param   {Value}  Value  the new value
     * @returns {this}
     */
    Set(Value) {
        this[] := Value
        return this
    }
} ; class ComValueRef
;@endregion
} ; class AquaHotkey_ComValue extends AquaHotkey
