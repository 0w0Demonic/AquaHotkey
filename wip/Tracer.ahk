#Requires >=v2.1-alpha.3
#Include "%A_LineFile%\..\..\AquaHotkey.ahk"

; TODO probably include something in this direction with the help of
;      `.TransformProp()`

;@region Tracer
/**
 * The tracer is a lightweight utility for keeping track of function
 * executions.
 * 
 * ```
 * Divide(a, b) =>  (a / b)
 * 
 * Divide.TraceWith(Tracer({
 *     Input:   (fn, Args*) => "entering " . fn.Name,
 *     Output:  (Result)    => "return " . String(Result),
 *     Error:   (Err)       => Type(Err) . " " . Err.Message,
 *     Writer:  (Str)       => MsgBox(Str)
 * }))
 * ```
 * 
 * ---
 * 
 * Tracer objects consist of four separate callback functions:
 * 
 * - `Input`: converts the called function and its arguments into a string
 * - `Output`: converts the return value into a string
 * - `Error`: converts errors into a string
 * - `Writer`: responsible for outputting the string
 * 
 * ---
 * 
 * To get some common useful formatters, you can use the methods provided in
 * the `Tracer.Formatter` and `Tracer.Writer` helper classes.
 */
class Tracer {
    /**
     * Creates a new tracer object, optionally setting formatters and writer
     * functions to be used by the tracer.
     * 
     * @constructor
     * @example
     * Tr := Tracer({
     *     Input: (fn, Args*) => "entering " . fn.Name,
     *     Error: (Err)       => Err.Message
     * })
     * 
     * @param   {Object?}  Options  additional tracer settings
     */
    __New(Options?) {
        if (!IsSet(Options)) {
            return
        }
        if (!IsObject(Options)) {
            throw TypeError("Expected an Object")
        }
        for Key, Value in Map(
            "Writer", "Writer",
            "Input",  "InputFormatter",
            "Output", "OutputFormatter",
            "Error",  "ErrorFormatter")
        {
            if (HasProp(Options, Key)) {
                this.DefineProp(Value, { Value: Options.%Key% })
            }
        }
    }

    ;@region Instance Properties
    /**
     * Formatter that converts the called function and its arguments into a
     * string.
     * 
     * @example
     * InputFormatter(fn: Func, Args*: Any*) => String
     * 
     * @property
     * @type {Func}
     */
    InputFormatter {
        get => Tracer.InputFormatter.Default()
        set => this.DefineProp("InputFormatter", { Value: Value })
    }

    /**
     * Formatter that converts the return value into a string.
     * 
     * @example
     * OutputFormatter(Result: Any) => String
     * 
     * @property
     * @type {Func}
     */
    OutputFormatter {
        get => Tracer.OutputFormatter.Default()
        set => this.DefineProp("OutputFormatter", { Value: Value })
    }

    /**
     * Formatter that converts an error object into a string.
     * 
     * @example
     * ErrorFormatter(Err: Error) => String
     * 
     * @property
     * @type {Func}
     */
    ErrorFormatter {
        get => Tracer.ErrorFormatter.Default()
        set => this.DefineProp("ErrorFormatter", { Value: Value })
    }

    /**
     * Default writer to output a string.
     * 
     * @example
     * Writer(Str: String) => void
     * 
     * @property
     * @type {Func}
     */
    Writer {
        get => Tracer.Writer.Debug()
        set => this.DefineProp("Writer", { Value: Value })
    }
    ;@endregion

    ;@region Formatters
    /**
     * Formatter base class.
     */
    class Formatter {
        /**
         * Formatter that does nothing.
         * 
         * @readonly
         * @property
         * @returns {Func}
         */
        static None() {
            static None(*) => ""
            return None
        }
    }

    /**
     * 
     */
    class InputFormatter extends Tracer.Formatter {
        /**
         * @returns {Func}
         */
        static Default() => (fn, Args*) {
            return "Entering: " . fn.Name
        }

        /**
         * @returns {Func}
         */
        static Detailed() => (fn, Args*) {

        }
    }

    /**
     * 
     */
    class OutputFormatter extends Tracer.Formatter {
        /**
         * @returns {Func}
         */
        static Default() => (Result) {
            ; ...
            return (Result) => "Returning: " . String(Result)
        }
    }

    class ErrorFormatter extends Tracer.Formatter {
        static Default() => (Err) {
            static Format := Tracer._FindGlobal("Format")
            static Type   := Tracer._FindGlobal("Type")

            return Format("
            (
            {1} : {2}
            Specifically: {3}
            ----
            {4}
            )", Type(Err), Err.Message, Err.Extra, Err.Stack)
        }
    }
    ;@endregion

    ;@region Writers
    /**
     * Helper class that provides methods of outputting a string.
     */
    class Writer {
        /**
         * 
         * 
         * @param   {String}  TimeFormat  the time format to be used
         * @returns {Func}
         */
        static WithTimestamp(TimeFormat := "[HH:mm:ss]") => (Str) {
            static FormatTime := Tracer._FindGlobal("FormatTime")
            return FormatTime(Str, TimeFormat?)
        }

        /**
         * 
         * 
         * @returns {Func}
         */
        static ToMsgBox(Title?, Options?) {
            static MsgBox := Tracer._FindGlobal("MsgBox")
            return (Str) => MsgBox(Str, Title?, Options?)
        }

        /**
         * 
         * 
         * @returns {Func}
         */
        static Debug() => (Result) {
            static OutputDebug := Tracer._FindGlobal("OutputDebug")
            return OutputDebug(Result)
        }
    }
    ;@endregion

    ;@region Tracing
    /**
     * 
     * @param   {Func}  fn    function being called
     * @param   {Any*}  Args  all passed arguments
     * @returns {Any}
     */
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

    /**
     * 
     * @param   {Func}  fn    function being called
     * @param   {Any*}  Args  all passed arguments
     */
    Input(fn, Args*) {
        Formatter := this.InputFormatter
        if (Formatter == Tracer.Formatter.None()) {
            return
        }
        
        Str := Formatter(fn, Args*)
        (this.Writer)(Str)
    }

    /**
     * 
     * @param   {Any}  Result  value returned by the function
     */
    Output(Result) {
        Formatter := this.OutputFormatter
        if (Formatter == Tracer.Formatter.None()) {
            return
        }

        Str := Formatter(Result)
        (this.Writer)(Str)
    }

    /**
     * 
     * @param   {Error}  Err  the error objec that was thrown
     */
    Error(Err) {
        Formatter := this.ErrorFormatter
        if (Formatter == Tracer.Formatter.None()) {
            return
        }

        Str := Formatter(Err)
        (this.Writer)(Str)
    }
    ;@endregion

    ;@region Support
    /**
     * Resolves a global function by name, and binds it via
     * `(Func.Prototype.Call)`. This circumvents any additional tracing of
     * functions that are being used in the formatters or writers.
     * 
     * @example
     * static MsgBox := Tracer._FindGlobal("MsgBox")
     * 
     * @param   {String}  VarName
     * @returns {BoundFunc}
     */
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
class AquaHotkey_Tracer extends AquaHotkey {
class Func {
    /**
     * Attaches and wraps the function to use the given tracer object.
     * 
     * @example
     * Divide(a, b) => (a / b)
     * 
     * Divide.TraceWith(Tracer())
     */
    TraceWith(TracerObj) {
        this.DefineProp("Call", { Call: GetMethod(TracerObj) })
    }
} ; class Func
} ; class AquaHotkey_Tracer extends AquaHotkey
;@endregion

;@region Testing
Tr := Tracer({
    Input: (fn, Args*) => "entering " . fn.Name . "...",
    Output: (Result) => "Output: " . Result,
    Writer: (Str) => MsgBox(Str)
})

Divide(a, b) {
    return (a / b)
}
Divide.TraceWith(Tr)

Result := Divide(1, 0)
;@endregion