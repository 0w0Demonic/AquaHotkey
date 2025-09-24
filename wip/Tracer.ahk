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
        for Field in ["InputFormatter", "OutputFormatter",
                      "ErrorFormatter", "Writer"] {
            if (HasProp(Options, Field)) {
                this.DefineProp(Field, { Value: Options.%Field% })
            }
        }
    }

    ;@region Defaults
    InputFormtter   => Tracer.InputFormatter.Default()
    OutputFormatter => Tracer.OutputFormatter.Default()
    ErrorFormatter  => Tracer.ErrorFormatter.Default()
    Writer          => OutputDebug
    ;@endregion

    ;@region Formatters
    class Formatter {
        static None() {
            static None(*) => ""
            return None
        }
    }

    class InputFormatter extends Tracer.Formatter {
        static Default() {

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
            static FormatTime := FindGlobal("FormatTime")
            return WithTimestamp

            WithTimestamp(Str) {
                return FormatTime(Str, TimeFormat?) . " " . Str
            }
        }

        static ToMsgBox(Options*) {
            return Func.Protoype.Call.Bind(unset, Options*)
        }
    }
    ;@endregion

    ;@region Tracing
    Call(fn, Args*) {
        static Call := (Func.Prototype.Call)
    }

    Input(fn, Args*) {
        if (this.InputFormatter == Tracer.Formatter.None) {
            return
        }
        ; ...
    }

    Output(Result) {
        if (this.OutputFormatter == Tracer.Formatter.None) {
            return
        }
        ; ...
    }

    Error(Err) {
        if (this.ErrorFormatter == Tracer.Formatter.None) {
            return
        }
        ; ...
    }

    IsPresent(Formatter) {
        return (Formatter != Tracer.Formatter.None())
    }
    ;@endregion

    ;@region Support
    static _FindGlobal() {
        static Deref1(this)    => %this%
        static Deref2(VarName) => %VarName%

        if (!(VarName is String)) {
            throw TypeError("Expected a String",, Type(VarName))
        }
        return (VarName != "this") ? Deref1(VarName) : Deref2(VarName)
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

Tr := 
MsgBox(Tracer.Writer.WithTimestamp().Call("Hello"))