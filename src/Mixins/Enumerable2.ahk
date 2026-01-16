
/**
 * Mixin class for types that can enumerated with 2 parameters.
 * 
 * ```ahk
 * for Value1, Value2 in Obj { ... }
 * ```
 * 
 * @mixin
 */
class Enumerable2 {
    static __New() {
        static Clone   := {}.Clone
        static GetProp := {}.GetOwnPropDesc
        static Define  := {}.DefineProp

        if (this != Enumerable2) {
            return
        }

        Cls := Clone(this)
        Prot := Clone(this.Prototype)
        Define(Cls, "Prototype", { Value: Prot })

        WithAlias(Cls)
        WithAlias(Prot)

        this.Extend(Array, Map, Enumerator)
        Cls.Extend(DoubleStream)

        static WithAlias(Target) {
            M := Map()
            for PropName in ObjOwnProps(Target) {
                if (PropName ~= "2$") {
                    M.Set(SubStr(PropName, 1, -1), GetProp(Target, PropName))
                }
            }
            for PropName, PropDesc in M {
                Define(Target, PropName, PropDesc)
            }
        }
    }

    ; TODO static IsInstance(Val?) ?

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
        for Key, Value in this {
            Action(Key?, Value?, Args*)
        }
        return this
    }

    /**
     * Determines whether an element satisfies the given `Condition`.
     * 
     * ```ahk
     * Condition(Value1?, Value2?, Args*) => Boolean
     * ```
     * 
     * If present, `&Out1` and `&Out2` receive the values of the first
     * matching elements.
     * 
     * @param   {VarRef<Any>}  Out1       (out) value 1 of first match
     * @param   {VarRef<Any>}  Out2       (out) value 2 of first match
     * @param   {Func}         Condition  the given condition
     * @param   {Any*}         Args       zero or more arguments
     * @returns {this}
     * @example
     * Map(1, 2, 3, 4).ForEach2((K, V) => MsgBox(K . " => " . V))
     */
    Find2(&Out1, &Out2, Condition, Args*) {
        GetMethod(Condition)
        Out1 := unset
        Out2 := unset
        for Key, Value in this {
            if (Condition(Key?, Value?, Args*)) {
                Out1 := (Key?)
                Out2 := (Value?)
                return true
            }
        }
        return false
    }

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
}