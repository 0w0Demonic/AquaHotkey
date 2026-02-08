#Include "%A_LineFile%\..\..\src\System\DLL.ahk"

class User32 extends DLL {
    static FilePath => "user32.dll"
}

GetProp := {}.GetOwnPropDesc
Result := "
(
List of User32 functions:
----

)"

Display(Cls, Truncate := 15) {
    for Name, Value in ObjOwnProps(User32) {
        Result .= Name . ": " . (Value ?? "(unset)")
        Result .= "`r`n"
        if (A_Index > Truncate) {
            Result .= "... (" . (ObjOwnPropCount(Cls) - Truncate) . " more)"
            break
        }
    }
    MsgBox(Result)
}

Display(User32)
