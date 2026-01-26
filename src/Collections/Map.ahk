#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

#Include "%A_LineFile%\..\..\Interfaces\Enumerable1.ahk"
#Include "%A_LineFile%\..\..\Interfaces\Enumerable2.ahk"
#Include "%A_LineFile%\..\..\Interfaces\Sizeable.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"

; TODO remove stream ops?

/**
 * Map utils and stream-like operations.
 * 
 * @module  <Collections/Map>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Map extends AquaHotkey {
class Map {
    /**
     * Creates a new empty map with the same base object, case sensitivity and
     * `Default` property of the given map. None of the actual map elements
     * are copied.
     * 
     * @param   {Map}  M  the map to be copied
     * @returns {Map}
     * @example
     * M := Map(1, 2, 3, 4)
     * M.CaseSense := false
     * M.Default := "(empty)"
     * 
     * Copy := Map.BasedFrom(M)
     * MsgBox(ObjGetBase(Copy) == ObjGetBase(M)) ; always `true`
     * MsgBox(Copy.CaseSense) ; false
     * MsgBox(Copy.Default) ; "(empty)"
     */
    static BasedFrom(M) {
        static Define  := {}.DefineProp
        static GetProp := {}.GetOwnPropDesc

        Result := Map()
        ObjSetBase(Result, ObjGetBase(M))

        Result.CaseSense := M.CaseSense
        for PropertyName in ObjOwnProps(M) {
            Define(Result, PropertyName, GetProp(M, PropertyName))
        }
        return Result
    }

    /**
     * Returns a new map of all elements that fulfill the given `Condition`.
     * 
     * ```ahk
     * Condition(Key, Value, Args*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {Map}
     * @example
     * ; Map { 1 => 2 }
     * Map(1, 2, 3, 4).RetainIf((Key, Value) => (Key == 1))
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Map.BasedFrom(this)
        for Key, Value in this {
            (Condition(Key, Value, Args*) && Result[Key] := Value)
        }
        return Result
    }

    /**
     * Returns a new map of all elements that don't satisfy the given
     * `Condition`.
     * 
     * ```ahk
     * Condition(Key, Value, Args*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  function that evaluates a condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {this}
     * @example
     * ; Map { 3 => 4 }
     * Map(1, 2, 3, 4).RemoveIf((Key, Value) => (Key == 1))
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Map.BasedFrom(this)
        for Key, Value in this {
            (Condition(Key, Value, Args*) || Result[Key] := Value)
        }
        return Result
    }

    /**
     * Returns a new map of elements transformed by applying `Mapper` to
     * each element.
     * 
     * ```ahk
     * Mapper(Key, Value, Args*) => Any
     * ```
     * 
     * @param   {Func}  Mapper  function that returns a new value
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {Map}
     * @example
     * ; Map { 1 => 4, 3 => 8 }
     * Map(1, 2, 3, 4).Map((Key, Value) => (Value * 2))
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        Result := Map.BasedFrom(this)
        for Key, Value in this {
            Result[Key] := Mapper(Key, Value, Args*)
        }
        return Result
    }
} ; class Map
} ; class AquaHotkey_Map extends AquaHotkey