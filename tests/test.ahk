#Requires AutoHotkey >=v2.0.5
#Include %A_LineFile%/../../src/AquaHotkeyX.ahk

class TestSuite {
    #Include %A_LineFile%/../Init/__New.ahk

    #Include %A_LineFile%/../Classes/Any.ahk
    #Include %A_LineFile%/../Classes/Array.ahk
    #Include %A_LineFile%/../Classes/Buffer.ahk
    #Include %A_LineFile%/../Classes/Class.ahk
    #Include %A_LineFile%/../Classes/Func.ahk
    #Include %A_LineFile%/../Classes/Map.ahk
    #Include %A_LineFile%/../Classes/Object.ahk
    #Include %A_LineFile%/../Classes/String.ahk
    #Include %A_LineFile%/../Classes/VarRef.ahk

    #Include %A_LineFile%/../Other/Stream.ahk
    #Include %A_LineFile%/../Other/Optional.ahk
    #Include %A_LineFile%/../Other/Comparator.ahk

    static AssertThrows(Function) {
        try {
            Function()
            throw ValueError("this function did not throw")
        }
    }
}

class Reflection extends AquaHotkey {
    class Object {
        ListAllProperties() {
            return ObjOwnProps(this).Stream().FlatMap(GetNames).ToArray()

            GetNames(PropName) {
                PropDesc := (Object.Prototype.GetOwnPropDesc)(this, PropName)
                if (PropDesc.HasOwnProp("Value")) {
                    return Array(PropName)
                }
                return "Get, Set, Call".StrSplit(", ")
                    .RetainIf(PropName => PropDesc.HasProp(PropName))
                    .Map(PropName => PropDesc.%PropName%.Name)
            }
        }
    }
}