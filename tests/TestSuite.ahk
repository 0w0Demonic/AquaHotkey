#Requires AutoHotkey v2
#Include <AquaHotkey/cfg/VerboseLogging>

; OnExit((*) => MsgBox(TestSuite.FailCount))

class TestSuite
{

static TestCount := 0
static FailCount := 0

static __New() {
    static OutFile := (A_LineFile . "\..\result.txt")
    static Ln := "--------------------------------------------------------------------------------"

    if (this == TestSuite) {
        ToolTip("running...")
        SetTimer(() => ToolTip(), -400)

        FileOpen(OutFile, "w").Write(Format("
        (
        TESTS: AutoHotkey {1}

        {2}
        {3}

        )", A_AhkVersion, FormatTime(unset, "yyyy/MM/dd HH:mm:ss"), Ln))
        return
    }

    Output := ""
    for Name in ObjOwnProps(this) {
        switch (StrLower(Name)) {
            case "call", "prototype", "__init", "__new": continue
        }
        if (!HasMethod(this, Name)) {
            continue
        }
        Fn := GetMethod(this, Name)
        RunWithTimeout(() => Fn(this), &Err)
        Output .= FormatTestResult(Fn, Err?)
    }
    Output .= Ln
    Output .= "`n"
    FileAppend(Output, OutFile)

    static RunWithTimeout(Fn, &Err, TimeoutMs := 1000) {
        Err := unset
        try {
            SetTimer(Timeout, -TimeoutMs)
            Fn()
        } catch as Err {
            TestSuite.FailCount++
        } finally {
            TestSuite.TestCount++
            SetTimer(Timeout, false)
        }

        Timeout() {
            throw TimeoutError("timed out on function " . Fn.Name,,
                               "timeout of " . TimeoutMs . "ms")
        }
    }

    static FormatTestResult(Fn, E?) {
        static FormatStack(E) => RegExReplace(
                E.Stack,
                "m).*?(\(\d+\)) : (\S++)",
                "> $2 $1")

        Success := !IsSet(E)
        Name    := RegExReplace(Fn.Name, "i)^[a-zA-Z]++_", "")
        Output  := Format("{:-77}[{}]`n", Name, (Success ? "x" : " "))

        if (!Success) {
            Output .= Ln
            Output .= "`n"
            Output .= E.Message . "`n"
            if (E.Extra == "") {
                E.Extra := '""'
            }
            Output .= "Specifically: " . E.Extra . "`n"
            Output .= FormatStack(E)
            Output .= Ln
            Output .= "`n"
        }
        return Output
    }
} ; static __New()

static AssertThrows(Fn) {
    try {
        Fn()
        throw ValueError("this function did not throw")
    }
} ; static AssertThrows(Fn)
} ; class TestSuite
