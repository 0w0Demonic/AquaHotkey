#Requires AutoHotkey >=v2.0.5

#Include %A_LineFile%/../../AquaHotkeyX.ahk
#Include %A_LineFile%/../../Src/String/StringFormatting.ahk
#Include %A_LineFile%/../../Src/Func/Kwargs.ahk

class TestSuite {
    static __New() {
        ToolTip("running...")

        Output := Format("
        (
        TESTS: AutoHotkey {1}

        {2}
        ------------------------------------------------------------

        )", A_AhkVersion, FormatTime(unset, "yyyy/MM/dd HH:mm:ss"))

        for ClsName in ObjOwnProps(this) {
            if (ClsName ~= "^__") {
                continue
            }
            Cls := this.%ClsName%
            if (!(Cls is Class)) {
                continue
            }
            for PropertyName in ObjOwnProps(Cls) {
                if (!HasMethod(Cls, PropertyName) || (PropertyName == "__Init")) {
                    continue
                }

                Function := Cls.GetOwnPropDesc(PropertyName).Call
                try {
                    Function(Cls)
                    Output .= FormatTestResult(Function, true)
                } catch as E {
                    Output .= FormatTestResult(Function, false, E)
                }
            }
            Output .= "=".Repeat(60) . "`n"
        }

        FileOpen(A_LineFile . "\..\result.txt", "w").Write(Output)
        Sleep(400)
        ExitApp()

        static FormatTestResult(Function, Successful, E?) {
            StartIndex    := InStr(Function.Name, ".") + 1
            SeparatorLine := "-".Repeat(60) . "`n"
            static FormatStack(E) {
                Pattern     := "m).*?(\(\d+\)) : (\S++)"
                Replacement := "> $2 $1"
                Stack       := E.Stack
                return RegExReplace(Stack, Pattern, Replacement)
            }
            static Check(Boolean) {
                return (Boolean) ? "x" : " "
            }
            Name   := SubStr(Function.Name, StartIndex)
            Output := Format("{:-57}[{}]`n", Name, Check(Successful))
            if (IsSet(E)) {
                Output .= SeparatorLine
                Output .= E.Message . "`n"
                if (E.Extra == "") {
                    E.Extra := '""'
                }
                Output .= "Specifically: " . E.Extra . "`n"
                Output .= FormatStack(E)
                Output .= SeparatorLine
            }
            return Output
        }
    }

    #Include %A_LineFile%/../Base/Array.ahk
    #Include %A_LineFile%/../Base/Comvalue.ahk
    #Include %A_LineFile%/../Base/Eq.ahk

    #Include %A_LineFile%/../Base/Buffer.ahk
    #Include %A_LineFile%/../Base/TypeInfo.ahk

    #Include %A_LineFile%/../Base/Func.ahk
    #Include %A_LineFile%/../Base/Map.ahk
    #Include %A_LineFile%/../Base/Object.ahk
    #Include %A_LineFile%/../Base/String.ahk
    #Include %A_LineFile%/../Base/VarRef.ahk
    
    #Include %A_LineFile%/../Extensions/Stream.ahk
    #Include %A_LineFile%/../Extensions/Optional.ahk
    #Include %A_LineFile%/../Extensions/TryOp.ahk
    #Include %A_LineFile%/../Extensions/Comparator.ahk
    
    #Include %A_LineFile%/../Extensions/Collector.ahk
    #Include %A_LineFile%/../Extensions/Gatherer.ahk
    
    #Include %A_LineFile%/../Extensions/Condition.ahk
    #Include %A_LineFile%/../Extensions/Mapper.ahk
    #Include %A_LineFile%/../Extensions/Combiner.ahk
    
    #Include %A_LineFile%/../Extensions/Zip.ahk

    static AssertThrows(Function) {
        try {
            Function()
            throw ValueError("this function did not throw")
        }
    }
}

class AquaHotkey_Verbose {
}