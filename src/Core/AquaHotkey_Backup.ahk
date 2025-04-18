/**
 * AquaHotkey - AquaHotkey_Backup.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Init/AquaHotkey_Backup.ahk
 * 
 * This class creates a snapshot of all properties and methods of a target
 * class before any modifications are applied. This allows for restoring or
 * referencing the original functionality when extending or modifying
 * built-in classes.
 * 
 * To use it, extend `AquaHotkey_Backup` and set `static Class` to the target
 * class whose properties should be preserved.
 * 
 * @example
 * 
 * class OriginalGui extends AquaHotkey_Backup {
 *     static Class => Gui
 * }
 * ; Now OriginalGui stores all original properties/methods of Gui
 * ; before modifications.
 */
class AquaHotkey_Backup {
    static __New() {
        static Define(Obj, PropertyName, PropertyDesc) {
            (Object.Prototype.DefineProp)(Obj, PropertyName, PropertyDesc)
        }
        static GetPropDesc(Obj, PropertyName) {
            return (Object.Prototype.GetOwnPropDesc)(Obj, PropertyName)
        }
        static CreateGetter(Value) => { Get: (Instance) => Value }

        if (this.base == Object) {
            return
        }
        Receiver     := this
        ReceiverName := Receiver.Prototype.__Class
        if (!ObjHasOwnProp(this, "Class")) {
            throw UnsetError('expected "static Class" property',, ReceiverName)
        }
        Supplier     := this.Class
        SupplierName := Supplier.Prototype.__Class
        FormatString := "`n[Aqua] ######## Backup: {1} -> {2} ########`n"
        OutputDebug(Format(FormatString, SupplierName, ReceiverName))
        Transfer(this.Class, this)

        static Transfer(Supplier, Receiver) {
            ReceiverProto := Receiver.Prototype
            ReceiverName  := ReceiverProto.__Class
            switch {
                case (Supplier is Class):
                    SupplierProto := Supplier.Prototype
                    SupplierName  := SupplierProto.__Class
                case (Supplier is Func):
                    SupplierProto := Supplier
                    SupplierName  := Supplier.Name
                default:
                    throw TypeError("unexpected type")
            }
            FormatString := "[Aqua] {1:-40} -> {2}"
            OutputDebug(Format(FormatString, SupplierName, ReceiverName))

            for PropertyName in ObjOwnProps(Supplier) {
                ; DO NOT REMOVE THIS
                if (PropertyName = "Prototype") {
                    continue
                }

                try {
                    DoRecursion := (Supplier.%PropertyName% is Class)
                } catch {
                    DoRecursion := false
                } 

                if (DoRecursion) {
                    NestedClass     := Supplier.%PropertyName%
                    NestedClassName := NestedClass.Prototype.__Class
                    if (Index := InStr(NestedClassName, ".")) {
                        NestedClassName := SubStr(NestedClassName, Index + 1)
                    }
                    
                    NewClass := Class()
                    NewProto := Object()

                    Define(NewClass, "Prototype", CreateGetter(NewProto))
                    NewName := ReceiverName . "." . NestedClassName

                    Define(NewProto, "__Class", CreateGetter(NewName))
                    Define(Receiver, PropertyName, CreateGetter(NewClass))

                    Transfer(NestedClass, NewClass)
                } else {
                    PropDesc := GetPropDesc(Supplier, PropertyName)
                    Define(Receiver, PropertyName, PropDesc)
                }
            }

            for PropertyName in ObjOwnProps(SupplierProto) {
                PropDesc := GetPropDesc(SupplierProto, PropertyName)
                Define(ReceiverProto, PropertyName, PropDesc)
            }
        }
    }
}
