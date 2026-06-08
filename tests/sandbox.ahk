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

Define  := {}.DefineProp
GetProp := {}.GetOwnPropDesc

WithLogging(PropDesc) => { Call: (Value) {
    MsgBox("__Init() constructing " . Type(Value))
    if (Value is Class) {
        MsgBox(Value.Prototype.__Class)
    }
    return (PropDesc.Call)(Value)
} }

Define(Any.Prototype, "__Init", WithLogging(GetProp(Any.Prototype, "__Init")))

Define(Class.Prototype, "__New", {
    Call: (Cls) => MsgBox("static __New() on class " . Cls.Prototype.__Class)
})

Define(Gui.Control.Prototype, "__New", {
    Call: (Obj) => MsgBox("__New() constructing " . Type(Obj))
})

G := Gui()
G.AddButton("w50", "OK")
G.Show()
