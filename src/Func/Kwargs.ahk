#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Provides keyword argument (kwargs) support for callable objects.
 * 
 * Instead of calling functions with positional arguments, callers can use
 * named arguments through an object literal with the `.With()` method. This
 * improves code readability and makes function calls self-documenting.
 * 
 * ### How it Works
 * 
 * Each function or callable object can define a `.Signature` property that
 * maps parameter names (and their aliases) to positional indices. Once a
 * signature is defined, calling `.With(ArgObj)` on the function converts the
 * named arguments to positional arguments and invokes the function.
 * 
 * ### Signature Syntax
 * 
 * Signatures are strings with parameters separated by commas. Aliases for the
 * same parameter are separated by forward slashes. Parameter names are matched
 * case-insensitively.
 * 
 * ```ahk
 * ; Signature: "ParamName/Alias1/Alias2, OtherParam/Alt, ..."
 * Function.Signature := "Keys/K, Control/Ctrl/Ctl/C, WinTitle/Title"
 * ```
 * 
 * ### Basic Usage
 * 
 * Define a signature and call with named arguments:
 * 
 * ```ahk
 * ; Without kwargs (positional)
 * ControlSend("hello", "Edit1", "ahk_exe notepad.exe")
 * 
 * ; With kwargs (named)
 * ControlSend.Signature := "Keys/K, Control/Ctrl/Ctl/C, WinTitle/Title, ..."
 * ControlSend.With({
 *     Keys: "hello",
 *     Ctrl: "Edit1",
 *     Title: "ahk_exe notepad.exe"
 * })
 * 
 * ; Mix aliases (case-insensitive)
 * ControlSend.With({
 *     K: "hello",
 *     control: "Edit1",
 *     WinTitle: "ahk_exe notepad.exe"
 * })
 * ```
 * 
 * ### Customizing Built-In Function Signatures
 * 
 * By default, `AquaHotkey_Kwargs` applies pre-configured signatures to many
 * built-in AHK functions via the `InitConfig()` function. To customize these
 * or add new ones, override the `KwargsConfig.ahk` file or provide your own
 * configuration function.
 * 
 * #### Method 1: Override KwargsConfig.ahk
 * 
 * Create your own `KwargsConfig.ahk` and point the `#Include` statement to it:
 * 
 * ```ahk
 * ; Replace the #Include path in AquaHotkey_Kwargs.__New() to point here
 * MyKwargsConfig() {
 *     return [
 *         MsgBox,          "Title/T, Text/Msg, Options/O",
 *         WinGetTitle,     "WinTitle/Title",
 *         ControlSend,     "Keys/K, Control/Ctrl/Ctl/C, WinTitle/Title",
 *     ]
 * }
 * return MyKwargsConfig()
 * ```
 * 
 * #### Method 2: Set Signature Directly
 * 
 * For one-off custom functions or to override built-in signatures:
 * 
 * ```ahk
 * MyFunc.Signature := "FirstParam/F1, SecondParam/S2, ThirdParam/T3"
 * MyFunc.With({
 *     F1: "value1",
 *     T3: "value3"
 *     ; S2 is optional here if function supports it
 * })
 * ```
 * 
 * ### Advanced: Custom Signature Handlers
 * 
 * Instead of a string signature, you can provide a custom function that
 * implements the `.With()` behavior entirely:
 * 
 * ```ahk
 * MyFunc.With := CustomWithHandler
 * 
 * CustomWithHandler(ArgObj) {
 *     ; Custom logic to parse ArgObj and call MyFunc
 *     ; Return the result
 * }
 * ```
 * 
 * ### Signature Data Structure
 * 
 * When a signature is set, it is internally converted to a case-insensitive
 * `Map` with the following structure:
 * 
 * ```
 * Map {
 *   "ParamName" => 1,
 *   "Alias1"    => 1,
 *   "Alias2"    => 1,
 *   "OtherParam" => 2,
 *   "Alt"       => 2,
 *   ...
 *   MaxParams   => 3  (total number of parameters)
 * }
 * ```
 * 
 * Multiple keys map to the same positional index, enabling parameter aliases.
 * 
 * @module  <Func/Kwargs>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see     {@link KwargsConfig}
 * @example <caption>Simple Function Wrapper</caption>
 * MyFunc.Signature := "Name/N, Age/A, City/C"
 * MyFunc.With({ N: "Alice", C: "NYC", A: 30 })
 * 
 * @example <caption>Built-In Function</caption>
 * ControlSend.Signature := "Keys/K, Control/Ctrl/Ctl, WinTitle/Title"
 * ControlSend.With({
 *     Keys: "Hello",
 *     Ctrl: "Edit1",
 *     WinTitle: "ahk_exe notepad.exe"
 * })
 */
class AquaHotkey_Kwargs extends AquaHotkey
{
    ;@region Object
    class Object {
        /**
         * Calls this object with positional arguments.
         * 
         * @param   {Object}  ArgObj  object containing all arguments
         * @returns {Any}
         * @example
         * ControlSend.Signature := "Keys/K, Control/Ctrl/Ctl/C, ..."
         * ControlSend.With({
         *     WinTitle: "ahk_exe notepad.exe",
         *     Ctrl: "Edit1",
         *     Keys: "foo"
         * })
         */
        With(ArgObj) {
            GetMethod(this)
            if (ObjGetBase(ArgObj) != Object.Prototype) {
                throw TypeError("Expected an Object literal",, Type(ArgObj))
            }
            if (!HasProp(this, "Signature")) {
                throw UnsetError("Missing signature")
            }
            Sig := this.Signature
            if (!(Sig is Map)) {
                this.Signature := Sig
                Sig := this.Signature
            }
            Args := Array()
            Args.Length := Sig.MaxParams
            for ArgName, Value in ObjOwnProps(ArgObj) {
                Index := Sig[ArgName]
                if (Args.Has(Index)) {
                    throw ValueError("Alias already set",, ArgName)
                }
                Args[Index] := Value
            }
            return this(Args*)
        }

        /**
         * The signature of the function object.
         * 
         * Accepts...
         * - String
         *   - Parameters separated by commas
         *   - Aliases separated by slashes
         * - Arrays
         *   - Each element is a parameter or its aliases
         * 
         * ---
         * 
         * After assignment, `.Signature` returns a case-insensitive `Map`:
         * ```
         * Map {
         *   "Name" => 1,      ; main parameter name
         *   "N"    => 1,      ; alias
         *   "City" => 2,      ; another main parameter
         *   "C"    => 2,      ; its alias
         *   MaxParams => 2    ; total positional parameters
         * }
         * ```
         * 
         * This internal representation is what `.With()` uses to resolve
         * named arguments to positional indices.
         * 
         * @param   {String|Array}  value  the signature
         * @returns {Map}  the signature Map
         */
        Signature {
            get => ""
            set {
                Sig := value
                if (!IsObject(Sig)) {
                    Sig := StrSplit(Sig, ",", " ")
                }
                if (!(Sig is Array)) {
                    throw TypeError("Expected an Array",, Type(Sig))
                }
                ArgMap := Map()
                ArgMap.CaseSense := false
                ArgMap.MaxParams := Sig.Length
                for List in Sig {
                    List := Trim(List)
                    if (IsObject(List)) {
                        throw TypeError("Expected a String",, Type(List))
                    }
                    Index := A_Index
                    for ArgName in StrSplit(List, "/") {
                        ArgName := Trim(ArgName)
                        ArgMap[ArgName] := Index
                    }
                }
                Sig := ArgMap

                ; define a custom string representation
                Sig.DefineProp("ToString", { Call: Signature_ToString })
                this.DefineProp("Signature", { Get: (_) => Sig })

                /**
                 * Returns a custom string representation.
                 * 
                 * @param   {Map}  Sig  signature map
                 * @returns {String}
                 */
                static Signature_ToString(Sig) {
                    if (!(Sig is Map)) {
                        throw TypeError("Expected a Map",, Type(Sig))
                    }

                    M := Array()
                    M.Length := Sig.Count
                    for ParameterName, Index in Sig {
                        if (M.Has(Index)) {
                            M[Index] .= "/" . ParameterName
                        } else {
                            M[Index] := Index . ": " . ParameterName
                        }
                    }
                    return M.JoinLine()
                }
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region static __New

    static __New() {
        if (this != AquaHotkey_Kwargs) {
            return
        }
        super.__New()

        /**
         * the actual code of InitConfig is offloaded into a separate file
         * (KwargsConfig.ahk). To use your own configs, simply redirect the
         * `#Include` statement to elsewhere.
         */
        Enumer := InitConfig().__Enum(1)
        while (Enumer(&Function) && Enumer(&Signature)) {
            ; this might apply to functions only present in the alpha releases.
            ; hence the reason we're using arrays: you can always fall back
            ; with the help of `?`, if the function doesn't exist in that
            ; version.
            ; 
            ; ex.: `WinGetAlwaysOnTop?` -> either `Func` or `unset`
            if (!IsSet(Function)) {
                continue
            }

            ; don't remove this.
            ; you're gonna have a bad time without these error details.
            if (!HasMethod(Function)) {
                Extra := ""
                if (Function is String) {
                    ; a comma is missing somewhere...
                    if (HasMethod(Signature)) {
                        Extra .= "(near " .  Signature.Name . "): "
                    }
                    Extra .= Function
                } else {
                    Extra := Type(Function)
                }
                throw TypeError("Expected a Function",, Extra)
            }

            switch {
                case (Signature is String):
                    Function.Signature := Signature
                case (HasMethod(Signature)):
                    Function.DefineProp("With", { Call: Signature })
                default:
                    throw ValueError("Invalid signature",, Type(Signature))
            }
        }

        static InitConfig() {
            #Include "%A_LineFile%/../KwargsConfig.ahk"
        }
    }
    ;@endregion
}
