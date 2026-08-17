; << for quick one-off tests >>
#Requires AutoHotkey v2.0

; /**
;  * Creates a regular expression suitable for regex callouts.
;  * 
;  * @param   {String}  Str        regex pattern
;  * @param   {VarRef}  Out        (out) regex callout callback
;  * @param   {Func}    Condition  predicate function that validates string
;  */
; Pattern(Str, &Out, Condition) {
;     GetMethod(Condition)
;     RegExMatch("", Str)
; 
;     ppName := (ObjPtr(&Out) + 8) + (6 * A_PtrSize)
;     Name   := StrGet(NumGet(ppName, "Ptr"), "UTF-16")
;     Out    := Callout
;     return "(?:(?<" . Name . ">" . Str . ")(?C" . Name . "))"
; 
;     Callout(Match, *) => !Condition(Match[Name])
; }
; 
; NumInRange(Lo, Hi, &Out) {
;     if (!IsNumber(Lo)) {
;         throw TypeError("Expected a Number",, Type(Lo))
;     }
;     if (!IsNumber(Hi)) {
;         throw TypeError("Expected a Number",, Type(Hi))
;     }
;     return Pattern("\b\d++\b", &Out, Condition)
; 
;     Condition(Num) {
;         MsgBox("matching...")
;         return IsNumber(Num) && (Num >= Lo) && (Num <= Hi)
;     }
; }
; 
; Pat := NumInRange(1, 255, &C_IsByte)
; 
; ; --> "(?:(?<C_IsByte>\b\d++\b)(?CC_IsByte))"
; MsgBox(Pat)
; 
; MsgBox(RegExMatch("0", Pat))   ; "matching..." ; 0
; MsgBox(RegExMatch("1", Pat))   ; "matching..." ; 1
; MsgBox(RegExMatch("255", Pat)) ; "matching..." ; 1
; MsgBox(RegExMatch("256", Pat)) ; "matching..." ; 0

#Include <AquaHotkey\src\Base\Assertions>
#Include <AquaHotkey\src\Base\DuckTypes>
#Include <AquaHotkey\src\Func\Predicate>

class TRange {
    __New(T, Low?, High?) {
        if (!IsSet(Low) && !IsSet(High)) {
            throw UnsetError("neither Low nor High is set")
        }
        this.T := T
        if (IsSet(Low)) {
            this.Low := Low.AssertType(T)
        }
        if (IsSet(High)) {
            this.High := High.AssertType(T)
        }
    }

    IsInstance(Val?) {
        if (!IsSet(Val)) {
            return false
        }
        if (ObjHasOwnProp(this, "Low") && Val.Lt(this.Low)) {
            return false
        }
        if (ObjHasOwnProp(this, "High") && Val.Gt(this.High)) {
            return false
        }
        return true
    }

    CanCastFrom(Val?) {
        return IsSet(Val) && (Val is TRange) && (this.T).CanCastFrom(Val.T)
            && (!ObjHasOwnProp(this, "Low") ||
                    (ObjHasOwnProp(Val, "Low") && (Val.Low).Lt(this.Low)))
            && (!ObjHasOwnProp(this, "High") ||
                    (ObjHasOwnProp(Val, "High") && (Val.High).Gt(this.High)))
    }
}

class StringUtils extends AquaHotkey {
    class String {
        static IsNullOrEmpty(Str?) {
            if (!IsSet(Str)) {
                return true
            }
            if (IsObject(Str) || !(Str is String)) {
                throw TypeError("Expected a String",, Type(Str))
            }
            return Str == ""
        }
        static IsNullOrWhiteSpace(Str?) {
            if (!IsSet(Str)) {
                return true
            }
            if (IsObject(Str) || !(Str is String)) {
                throw TypeError("Expected a String",, Type(Str))
            }
            return IsSpace(Str)
        }
    }
}
