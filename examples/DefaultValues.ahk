#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%/../../AquaHotkey.ahk"

/**
 * @file
 * @name DefaultValues
 * @description
 * Turns off case-sensitivity of all `Array` and `Map` objects.
 * 
 * While using custom functions or classes makes more sense most of the time,
 * it allows you to define project-wide defaults.
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
        Default := false
    }

    class Map {
        Default := "(empty)"
    }
}