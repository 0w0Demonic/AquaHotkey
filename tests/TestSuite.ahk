#Requires AutoHotkey v2
#Include <AquaHotkey/cfg/VerboseLogging>

class TestSuite
{

static TestCount := 0
static FailCount := 0
static Line      := "--------------------------------------------------------------------------------"

static Close() {
    FileObj := FileOpen(A_LineFile . "\..\result.txt", "a")
    FileObj.Write(Format("
    (
    Total:  {2}
    Failed: {3}
    )", this.Line, this.TestCount, this.FailCount))
    FileObj.Close()
    ExitApp(0)
}


static __New() {
    static OutFile := (A_LineFile . "\..\result.txt")

    ; this should be the case on the first iteration
    if (this == TestSuite) {
        ToolTip("running...")
        SetTimer(() => ToolTip(), -400)

        FileObj := FileOpen(OutFile, "w")
        FileObj.Write(Format("
        (
        TESTS: AutoHotkey {1}

        {2}
        {3}

        )", A_AhkVersion, FormatTime(unset, "yyyy/MM/dd HH:mm:ss"), this.Line))
        FileObj.Close()
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
    Output .= this.Line
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
            Output .= TestSuite.Line
            Output .= "`n"
            Output .= E.Message . "`n"
            if (E.Extra == "") {
                E.Extra := '""'
            }
            Output .= "Specifically: " . E.Extra . "`n"
            Output .= FormatStack(E)
            Output .= TestSuite.Line
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
