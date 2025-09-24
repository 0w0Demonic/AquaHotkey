#Include "%A_LineFile%/../../AquaHotkey.ahk"

;@region Tracer
/**
 * 
 */
class Tracer {
    /**
     * 
     */
    __New(Options?) {
        if (!IsSet(Options)) {
            return
        }
        if (!IsObject(Options)) {
            throw TypeError("Expected an Object")
        }
        if (HasProp(Options, "Writer")) {
            this.DefineProp("Writer", { Value: Options.Writer })
        }
        if (HasProp(Options, "Input")) {
            this.DefineProp("InputFormatter", { Value: Options.Input })
        }
        if (HasProp(Options, "Output")) {
            this.DefineProp("OutputFormatter", { Value: Options.Output })
        }
        if (HasProp(Options, "Error")) {
            this.DefineProp("ErrorFormatter", { Value: Options.Error })
        }
    }

    ;@region Defaults
    InputFormatter   => Tracer.InputFormatter.Default()
    OutputFormatter => Tracer.OutputFormatter.Default()
    ErrorFormatter  => Tracer.ErrorFormatter.Default()
    Writer          => Tracer.Writer.Debug()
    ;@endregion

    ;@region Formatters
    class Formatter {
        static None => this.None()
        static None() {
            static None(*) => ""
            return None
        }
    }

    class InputFormatter extends Tracer.Formatter {
        static Default() {
            static MsgBox := Tracer._FindGlobal("MsgBox")
            return (fn, Args*) => MsgBox("entering " . fn.Name . "...")
        }
    }

    class OutputFormatter extends Tracer.Formatter {
        static Default() {

        }
    }

    class ErrorFormatter extends Tracer.Formatter {
        static Default() {

        }
    }
    ;@endregion

    ;@region Writers
    class Writer {
        static WithTimestamp(TimeFormat := "[HH:mm:ss]") {
            static FormatTime := Tracer._FindGlobal("FormatTime")
            return (Str) => (FormatTime(Str, TimeFormat?) . " " . Str)
        }

        static ToMsgBox(Title?, Options?) {
            static MsgBox := Tracer._FindGlobal("MsgBox")
            return (Str) => MsgBox(Str, Title?, Options?)
        }

        static Debug => this.Debug()
        static Debug() {
            static OutputDebug := Tracer._FindGlobal("OutputDebug")
            return OutputDebug
        }
    }
    ;@endregion

    ;@region Tracing
    Call(fn, Args*) {
        this.Input(fn, Args*)
        try {
            Result := (Func.Prototype.Call)(fn, Args*)
        } catch as Err {
            this.Error(Err)
            throw Err
        }
        this.Output(Result)
        return Result
    }

    Input(fn, Args*) {
        Formatter := this.InputFormatter
        if (Formatter == Tracer.Formatter.None) {
            return
        }
        
        Str := Formatter(fn, Args*)
        (this.Writer)(Str)
    }

    Output(Result) {
        Formatter := this.OutputFormatter
        if (Formatter == Tracer.Formatter.None) {
            return
        }

        Str := Formatter(Result)
        (this.Writer)(Str)
    }

    Error(Err) {
        Formatter := this.ErrorFormatter
        if (Formatter == Tracer.Formatter.None) {
            return
        }

        Str := Formatter(Err)
        (this.Writer)(Str)
    }
    ;@endregion

    ;@region Support
    static _FindGlobal(VarName) {
        static Deref1(this)    => %this%
        static Deref2(VarName) => %VarName%

        if (!(VarName is String)) {
            throw TypeError("Expected a String",, Type(VarName))
        }
        return ObjBindMethod(Func.Prototype.Call,,
                (VarName != "this") ? Deref1(VarName)
                                    : Deref2(VarName))
    }
    ;@endregion
}
;@endregion

;@region Extensions
/**
 * 
 */
class AquaHotkey_Tracer extends AquaHotkey {
class Func {
    TraceWith(TracerObj) {
        this.DefineProp("Call", { Call: GetMethod(TracerObj) })
    }
} ; class Func
} ; class AquaHotkey_Tracer extends AquaHotkey
;@endregion

Tr := Tracer({
    Input: (fn, Args*) => "entering " . fn.Name . "...",
    Output: (Result) => "Output: " . Result,
    Error: (Err) => Err.Message,
    Writer: (Str) => MsgBox(Str)
})

Divide(a, b) {
    return (a / b)
}
Divide.TraceWith(Tr)

Result := Divide(1, 0)