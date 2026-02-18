#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%\..\..\AquaHotkeyX.ahk"

/**
 * @file
 * @name Any
 * @description
 * 
 * Showcases AquaHotkey's `Any.ahk` extension.
 * 
 * - Piping values via `.__Call()` and `.o0()`
 * - Type inspection with `.Type` and `.Class`
 * - Easy inline assertions with `.Assert*()`
 */

; piping with `.o0()`
"goodbye".o0(StrUpper).o0(MsgBox)

; `.Type` and `.Class`
MsgBox("123".Type)           ; "String"
MsgBox("123".Class == String) ; 1

; assertions
IsGreaterThan(Other) {
    return (this) => (this > Other)
}

(42).Assert(IsNumber).Assert(IsGreaterThan(5))

"foo".AssertType(String).AssertNotEquals("")

try {
    "foo".AssertStrictEquals("FOO")
} catch as Err {
    MsgBox(Err.Message)
}

