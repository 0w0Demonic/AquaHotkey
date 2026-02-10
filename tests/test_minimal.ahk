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



; Transform_Array_Push()