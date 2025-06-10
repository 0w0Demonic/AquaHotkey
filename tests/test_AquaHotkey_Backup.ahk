#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%/../../AquaHotkeyX.ahk"

class A extends AquaHotkey_Backup {
    static __New() => super.__New(Hotkey)
}

class B extends AquaHotkey_Backup {
    static __New() => super.__New(Gui)
}

Display(Obj) => Obj.OwnProps().Stream().JoinLine().MsgBox()

Array(A, B, B.Prototype).ForEach(Display)
