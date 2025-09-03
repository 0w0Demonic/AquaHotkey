#Requires AutoHotkey >=v2.0.5
#Include %A_LineFile%/../../AquaHotkeyX.ahk

class TestSuite {
    static __New() {
        Output := "TESTS: AutoHotkey " . A_AHKVersion . "`n" . "-".Repeat(60) . "`n"

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

        Output.ToClipboard()

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

    #Include %A_LineFile%/../Builtins/Any.ahk
    #Include %A_LineFile%/../Builtins/Array.ahk
    #Include %A_LineFile%/../Builtins/Buffer.ahk
    #Include %A_LineFile%/../Builtins/Class.ahk
    #Include %A_LineFile%/../Builtins/Func.ahk
    #Include %A_LineFile%/../Builtins/Map.ahk
    #Include %A_LineFile%/../Builtins/Object.ahk
    #Include %A_LineFile%/../Builtins/String.ahk
    #Include %A_LineFile%/../Builtins/VarRef.ahk
    
    #Include %A_LineFile%/../Extensions/Stream.ahk
    #Include %A_LineFile%/../Extensions/Optional.ahk
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

ExitApp()
