#Requires AutoHotkey v2
#Include "%A_LineFile%\..\..\AquaHotkey.ahk"

/**
 * @file
 * @name DefaultValues
 * @description
 * Sets global settings for all `Array` and `Map` objects, such as default
 * object and case sensitivity of strings.
 * 
 * To assign these property during every construction of `Array` and `Map`,
 * create an extension which declares its own variable declarations.
 * 
 * You should always prefer writing an `.__Init()` method instead of the
 * regular "assignment syntax" such as `InstanceVar := Expression`.
 * 
 * Beware that array and object literals (such as `{ Key: "Value" }` or
 * `[1, 2, 3, 4]`) do not call `.__Init()` when created. The extension has no
 * effect on these values.
 * 
 * @example
 * ArrayObj := Array(unset, unset, unset)
 * MapObj := Map()
 * 
 * MsgBox(ArrayObj[3]) ; false
 * MapObj["foo"] ; "(empty)"
 */
class DefaultValues extends AquaHotkey {
    class Array {
        ; Default := false   <-- avoid assignment syntax
        __Init() { 
            this.Default := false
        }
    }

    class Map {
        __Init() {
            this.Default := "(empty)"
            this.CaseSense := false
        }
    }
}

MsgBox(Map().CaseSense) ; ==> "Off"
MsgBox(Array().Default) ; ==> false

; our variable declaration does nothing, because `[1, 2]` is an array literal.
MsgBox(  ObjHasOwnProp( [1, 2], "Default" )  ) ; ==> false
