#Include "%A_LineFile%\..\..\Interfaces\IArray.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"
#Include "%A_LineFile%\..\..\Base\ToString.ahk"

/**
 * @mixin
 * @description
 * 
 * Mixin class for types that can enumerated with 2 parameters. As opposed
 * to {@link Enumerable1}, methods are suffixed with `2`.
 * For example, `.ForEach2()` is the two-parameter version of `.ForEach()`.
 * 
 * `Enumerable2.Strict` defines the same methods, except that they aren't
 * prefixed. This is useful for things like {@link DoubleStream}, which are
 * strictly 2-parameter.
 * 
 * @module  <Interfaces/Enumerable1>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * for Value1, Value2 in Obj { ... }
 */
class Enumerable2 extends Any {
    static __New() {
        static Clone := {}.Clone

        Prot := {}
        for PropName, PropDesc in OwnPropDescs(this.Prototype) {
            DefineProp(Prot, (SubStr(PropName, -1) == "2")
                    ? SubStr(PropName, 1, -1)
                    : PropName, PropDesc)
        }
        Cls := { base: ObjGetBase(this), Prototype: Prot }
        for PropName, PropDesc in OwnPropDescs(this) {
            DefineProp(Cls, (SubStr(PropName, -1) == "2")
                    ? SubStr(PropName, 1, -1)
                    : PropName, PropDesc)
        }
        DefineProp(this, "Strict", NestedClassProp(Cls))

        this.Extend(IArray, IMap)
        (this.Strict).Extend(DoubleStream)
    }

    ;@region Side Effects

    /**
     * Calls the given `Action` for each element.
     * 
     * ```ahk
     * Action(Value1?, Value2?, Args*) => void
     * ```
     * 
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more arguments
     * @returns {this}
     * @example
     * Map(1, 2, 3, 4).ForEach2((K, V) => MsgBox(K . " => " . V))
     */
    ForEach2(Action, Args*) {
        GetMethod(Action)
        for Key, Value in this {
            Action(Key?, Value?, Args*)
        }
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Reduction

    /**
     * Determines whether an element satisfies the given `Condition`.
     * 
     * ```ahk
     * Condition(Value1?, Value2?, Args*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     * @example
     * Map(1, 2, 3, 4).Any((K, V) => (K == 1)) ; true
     */
    Any2(Condition, Args*) {
        GetMethod(Condition)
        for Key, Value in this {
            if (Condition(Key?, Value?, Args*)) {
                return true
            }
        }
        return false
    }

    /**
     * Returns `true` if none of the elements satisfy the given `Condition`,
     * otherwise `false`.
     * 
     * ```ahk
     * Condition(Key?, Value?, Args*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     * @example
     * Map(1, 2, 3, 4).None((K, V) => (K == 3)) ; false
     */
    None2(Condition, Args*) {
        GetMethod(Condition)
        for Key, Value in this {
            if (Condition(Key?, Value?, Args*)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns `true` if all elements satisfy the given `Condition`, otherwise
     * `false`.
     * 
     * ```ahk
     * Condition(Value1?, Value2?, Args*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     * @example
     * Map(1, 2, 3, 4).All2((K, V) => (K != 6)) ; true
     */
    All2(Condition, Args*) {
        GetMethod(Condition)
        for Key, Value in this {
            if (!Condition(Key?, Value?, Args*)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns a string representation of this enumerable.
     * 
     * @returns {String}
     */
    ToString() {
        Result := Type(this) . " <"
        Enumer := GetEnumerator(this, 2)
        if (Enumer(&Key, &Value)) {
            Result .= "("
            Result .= String(Key)
            Result .= ", "
            Result .= String(Value)
            Result .= ")"

            for Key, Value in Enumer {
                Result .= ", ("
                Result .= String(Key)
                Result .= ", "
                Result .= String(Value)
                Result .= ")"
            }
        }
        Result .= ">"
        return Result
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Collect

    /**
     * Reduces all elements into a `Map`.
     * 
     * ```ahk
     * KeyMapper(Key: Any, Value: Any) => Any
     * ValueMapper(Key: Any, Value: Any) => Any
     * Merger(Left: Any, Right: Any) => Any
     * ```
     * 
     * @param   {Func?}  KeyMapper    retrieves key
     * @param   {Func?}  ValueMapper  retrieves value
     * @param   {Func?}  Merger       merges two values
     * @param   {Any?}   MapParam     internal map param
     * @returns {Map}
     * @see {@link AquaHotkey_Map.Map.Create Map.Create}
     * @example
     * ; Map { 1: 3, 2: 2, 3: 4 }
     * Array(3, 2, 4).DoubleStream().ToMap()
     */
    ToMap(
        KeyMapper   := ((k, *) => k),
        ValueMapper := ((k, v) => v),
        Merger      := ((l, r) => r),
        MapParam?)
    {
        GetMethod(KeyMapper)
        GetMethod(ValueMapper)
        GetMethod(Merger)

        M := Map.Create(MapParam?)
        for A, B in this {
            Key := KeyMapper(A?, B?)
            Value := ValueMapper(A?, B?)
            if (M.Has(Key)) {
                M.Set(Key, Merger(M.Get(Key), Value))
            } else {
                M.Set(Key, Value)
            }
        }
        return M
    }

    ;@endregion
}
