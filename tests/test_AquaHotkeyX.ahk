#Requires AutoHotkey >=v2.0.5

#Include %A_LineFile%/../../AquaHotkeyX.ahk
#Include %A_LineFile%/../../Src/String/StringFormatting.ahk
#Include %A_LineFile%/../../Src/Func/Kwargs.ahk

class TestSuite {
    static ThinLine  => "------------------------------"
                      . "------------------------------"
    
    static ThickLine => "=============================="
                      . "=============================="
    
    static __New() {
        ToolTip("running...")

        Output := Format("
            (
            TESTS: AutoHotkey {1}

            {2}
            {3}

            )",
            A_AhkVersion,
            FormatTime(unset, "yyyy/MM/dd HH:mm:ss"),
            TestSuite.ThickLine
        )

        for ClsName in ObjOwnProps(this) {
            if (ClsName ~= "^__") {
                continue
            }
            Cls := this.%ClsName%
            if (!(Cls is Class)) {
                continue
            }
            Count := 0
            for PropertyName in ObjOwnProps(Cls) {
                switch (StrLower(PropertyName)) {
                    case "prototype", "__init", "call":
                        continue
                }
                if (!HasMethod(Cls, PropertyName)) {
                    continue
                }
                ++Count
                Function := Cls.GetOwnPropDesc(PropertyName).Call
                try {
                    Function(Cls)
                    Output .= FormatTestResult(Function, true)
                } catch as E {
                    Output .= FormatTestResult(Function, false, E)
                }
            }
            if (Count) {
                Output .= TestSuite.ThickLine
                Output .= "`n"
            }
        }

        FileOpen(A_LineFile . "\..\result.txt", "w").Write(Output)
        Sleep(400)
        ExitApp()

        static FormatTestResult(Function, Successful, E?) {
            StartIndex    := InStr(Function.Name, ".") + 1
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
                Output .= TestSuite.ThinLine
                Output .= "`n"
                Output .= E.Message . "`n"
                if (E.Extra == "") {
                    E.Extra := '""'
                }
                Output .= "Specifically: " . E.Extra . "`n"
                Output .= FormatStack(E)
                Output .= TestSuite.ThinLine
                Output .= "`n"
            }
            return Output
        }
    }

    ;---- <Base>
    #Include "%A_LineFile%/../Base/Comvalue.ahk"
    #Include "%A_LineFile%/../Base/Eq.ahk"
    #Include "%A_LineFile%/../Base/Error.ahk"
    #Include "%A_LineFile%/../Base/Buffer.ahk"
    #Include "%A_LineFile%/../Base/TypeInfo.ahk"
    #Include "%A_LineFile%/../Base/Object.ahk"
    #Include "%A_LineFile%/../Base/VarRef.ahk"

    ;---- <Collections>
    #Include "%A_LineFile%/../Collections/Array.ahk"
    #Include "%A_LineFile%/../Collections/Map.ahk"
    #Include "%A_LineFile%/../Collections//Zip.ahk"

    ;---- <Stream>
    #Include "%A_LineFile%/../Stream/Stream.ahk"
    #Include "%A_LineFile%/../Stream/Collector.ahk"
    #Include "%A_LineFile%/../Stream/Gatherer.ahk"

    ;---- <Monads>
    #Include "%A_LineFile%/../Monads/Optional.ahk"
    #Include "%A_LineFile%/../Monads/TryOp.ahk"

    ;---- <Func>
    #Include "%A_LineFile%/../Func/Comparator.ahk"
    #Include "%A_LineFile%/../Func/Condition.ahk"
    #Include "%A_LineFile%/../Func/Mapper.ahk"
    #Include "%A_LineFile%/../Func/Func.ahk"

    ;---- <String>
    #Include "%A_LineFile%/../String/String.ahk"

    static AssertThrows(Function) {
        try {
            Function()
            throw ValueError("this function did not throw")
        }
    }
}

class AquaHotkey_Verbose {
}