#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
/**
 * AquaHotkey - ComValue.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/ComValue.ahk
 */
class AquaHotkey_ComValue extends AquaHotkey {
;@region ComValue
class ComValue {
    static __New() {
        static Define(Obj, PropertyName, PropertyDesc) {
            (Object.Prototype.DefineProp)(Obj, PropertyName, PropertyDesc)
        }

        IndexLastDot     := InStr(this.Prototype.__Class, ".",,, -1)
        RootClass        := SubStr(this.Prototype.__Class, 1, IndexLastDot)
        Name_ComValue    := RootClass . "ComValue"
        Name_ComValueRef := RootClass . "ComValueRef"
        Name_ComObjArray := RootClass . "ComObjArray"

        Define(this, "ARRAY", {
                Get: ComValueGet(Name_ComValue, "ARRAY", 0x2000)})
        Define(this, "BYREF", {
                Get: ComValueGet(Name_ComValue, "BYREF", 0x4000)})

        for Arr in [
                ["EMPTY",    0x0],  ["NULL",     0x1],  ["INT16",    0x2],
                ["INT32",    0x3],  ["FLOAT32",  0x4],  ["FLOAT64",  0x5],
                ["CURRENCY", 0x6],  ["DATE",     0x7],  ["BSTR",     0x8],
                ["DISPATCH", 0x9],  ["ERROR",    0xA],  ["BOOL",     0xB],
                ["VARIANT",  0xC],  ["UNKNOWN",  0xD],  ["DECIMAL",  0xE],
                ["INT8",     0x10], ["UINT8",    0x11], ["UINT16",   0x12],
                ["UINT32",   0x13], ["INT64",    0x14], ["UINT64",   0x15],
                ["INT",      0x16], ["UINT",     0x17], ["RECORD",   0x24]]
        {
            PropertyName := Arr[1]
            Constant     := Arr[2]
            
            ; unlike in other classes, this method directly accesses classes
            ; `ComValue`, `ComValueRef` and `ComObjArray` instead of relying on
            ; `AquaHotkey.__New()` to define properties.

            Define(ComValue, PropertyName, {
                Get:  ComValueGet(Name_ComValue, PropertyName, Constant),
                Call: ComValueCall(Name_ComValue, PropertyName, Constant)})

            Define(ComValueRef, PropertyName, {
                Call: ComValueRefCall(Name_ComValueRef,
                                      PropertyName, Constant | this.BYREF)})

            Define(ComObjArray, PropertyName, {
                Call: ComObjArrayCall(Name_ComObjArray,
                                      PropertyName, Constant | this.ARRAY)})
        }

        static ComValueGet(ClassName, PropertyName, Constant) {
            Name := ClassName . "." . PropertyName . ".Get"
            Getter.DefineProp("Name", { Get: (Instance) => Name })
            return Getter

            Getter(Instance) {
                return Constant
            }
        }

        static ComValueCall(ClassName, PropertyName, Constant) {
            Name := ClassName . "." . PropertyName
            Constructor.DefineProp("Name", { Get: (Instance) => Name })
            return Constructor

            Constructor(Instance, Value, Flags?) {
                if (Instance == ComObject) {
                    throw TypeError("invalid class",, "ComObject")
                }
                return Instance(Constant, Value, Flags?)
            }
        }

        static ComValueRefCall(ClassName, PropertyName, Constant) {
            Name := ClassName . "." . PropertyName
            Constructor.DefineProp("Name", { Get: (Instance) => Name })
            return Constructor

            Constructor(Instance, Value) {
                if (Instance == ComObject) {
                    throw TypeError("invalid class",, "ComObject")
                }
                if (!IsInteger(Value)) {
                    Value := Value.Ptr
                }
                return Instance(Constant, Value)
            }
        }

        static ComObjArrayCall(ClassName, PropertyName, Constant) {
            Name := ClassName . "." . PropertyName
            Constructor.DefineProp("Name", { Get: (Instance) => Name })
            return Constructor

            Constructor(Instance, Dimensions*) {
                return Instance(Constant, Dimensions*)
            }
        }
    }
} ; class ComValue
;@endregion

;@region ComValueRef
class ComValueRef {
    Get() {
        return this[]
    }

    Set(Value) {
        this[] := Value
        return this
    }
} ; class ComValueRef
;@endregion
} ; class AquaHotkey_ComValue extends AquaHotkey