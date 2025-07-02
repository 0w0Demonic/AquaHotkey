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
         * @return  {Any}
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
                this.DefineProp("Signature", { Get: (_) => Sig })
            }
        }
    }

    static __New() {
        if (this != AquaHotkey_Kwargs) {
            return
        }
        super.__New()

        for Function, Signature in InitConfig() {
            Function.Signature := Signature
        }

        static InitConfig() {
            #Include "%A_LineFile%/../KwargsConfig.ahk"
        }
    }
}