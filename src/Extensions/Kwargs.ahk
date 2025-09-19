/**
 * AquaHotkey - Kwargs.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Kwargs.ahk
 */
class AquaHotkey_Kwargs extends AquaHotkey {
    class Class {
        With(ArgObj) {
            if (Type(ArgObj) != "Object") {
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
    }

    class Any {
        /**
         * To support named parameters, the `.With()` method is introduced
         * to bridge the gap. It lets you pass an object with key-value
         * pairs, effectively simulating keyword arguments.
         * 
         * To make it work, the target function must define a `.Signature`
         * string, which lists accepted parameter names and aliases.
         * 
         * For now, variadic arguments (`Args*`) aren't supported.
         * 
         * @example
         * ControlSend.Signature := "Keys/K, Control/Ctrl/Ctl/C, ..."
         * ControlSend.With({
         *     WinTitle: "ahk_exe notepad.exe",
         *     Ctrl: "Edit1",
         *     Keys: "foo"
         * })
         * 
         * @param   {Object}  ArgObj  object containing all arguments
         * @returns {Any}
         */
        With(ArgObj) {
            GetMethod(this)
            if (Type(ArgObj) != "Object") {
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

        Signature {
            get {
                return ""
            }
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
                for ArgNameList in Sig {
                    ArgNameList := Trim(ArgNameList)
                    if (IsObject(ArgNameList)) {
                        throw TypeError("Expected a String",, Type(ArgNameList))
                    }
                    Index := A_Index
                    for ArgName in StrSplit(ArgNameList, "/") {
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
                 * @param   {Map}  _ the map that contains parameter names + aliases
                 * @returns {String}
                 */
                static Signature_ToString(Sig) {
                    if (!(Sig is Map)) {
                        throw TypeError("Expected a Map",, Type(Sig))
                    }
                    M := Array()
                    M.Length := Sig.MaxParams
                    for ParameterName, Index in Sig {
                        if (M.Has(Index)) {
                            M[Index] .= "/" . ParameterName
                        } else {
                            M[Index] := Index . ": " . ParameterName
                        }
                    }
                    for Index, Str in M {
                        if (IsSet(Result)) {
                            Result .= ",`r`n" . Str
                        } else {
                            Result := Str
                        }
                    }
                    return Result
                }
            }
        }
    }

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

        ; TODO improve by making this lazy-init instead of `static __New()`
        Config := InitConfig()

        if (!(Config is Array)) {
            throw TypeError("Expected an Array",, Type(Config))
        }
        ; retrieve enumerator and yield key + value the easy way
        Enumer := Config.__Enum(1)
        while (Enumer(&Function) && Enumer(&Signature)) {
            ; this might apply to functions only present in the alpha releases.
            ; hence the reason we're using arrays: you can always fall back
            ; with the help of `?`, if the function doesn't exist in that version.
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
                    ; there's nothing we can do... (dans mon esprit
                    ; tout divague, ...)
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
}