; << for quick one-off tests >>
#Requires AutoHotkey v2.0

#Include "%A_LineFile%\..\..\src\Core\AquaHotkeyX.ahk"
;#Include "%A_LineFile%\..\..\src\Core\AquaHotkey.ahk"

ConstantRef_Using_PropRef() {
    Obj := Object()
    OtherObj := Object()
    OtherObj.Value := 42

    Obj.DefineProp("Value", ConstantRef(&OtherObj.Value))
}


Transform_Array_Push() {
    WithLogging(PropDesc, Message) {
        return { Call: Method }

        Method(Args*) {
            MsgBox(Message)
            return (PropDesc.Call)(Args*)
        }
    }

    (Array.Prototype).TransformProp("Push", WithLogging, "pushing...")

    Arr := Array()
    Arr.Push(1, 2, 3)

    MsgBox(Format("Length: {}", Arr.Length))
}

FillWith_ArrayIndex() {
    Arr := Array()
    Arr.Length := 10

    Arr.FillWith(() => A_Index)
    Arr.Join(", ").MsgBox()
}

Deletion() {
    Obj1 := Object()
    Obj2 := { __Delete: (_) => MsgBox("deleting Obj2") }
    Obj3 := { __Delete: (_) => MsgBox("deleting Obj3") }

    Obj1.__Class := "Base"

    ObjSetBase(Obj2, Obj1)
    ObjSetBase(Obj3, Obj2)

    MsgBox("clearing Obj1")
    Obj1 := ""
    MsgBox("clearing Obj2")
    Obj2 := ""
    MsgBox("clearing Obj3")
    Obj3 := ""

    MsgBox("end")
}

class AquaHotkey_Conf_DisableGenerics {

}

MsgBox(Array.OfType(String) == Array)