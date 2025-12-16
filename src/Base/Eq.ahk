#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Adds a universal `.Eq()` method for checking whether two values are
 * equivalent.
 * 
 * ---
 * 
 * **How to Implement**:
 * 
 * In general, these rules should apply for things to work correctly:
 * 
 * 1. `A.Eq(A)` is **always** `true`
 * 2. `A.Eq(unset)` is **always** `false`
 * 3. (symmetric) `A.Eq(B)` must equal `B.Eq(A)`
 * 4. (transitive) if `A.Eq(B)` and `B.Eq(C)`, then `A.Eq(C)`
 * 5. (consistent) the result of `A.Eq(B)`, when unmodified, must be
 *    **consistently** either `true` or `false`.
 * 
 * ---
 * 
 * **Any.Eq(A?, B?)**:
 * 
 * Determines whether two values are equal, even if they're both `unset`.
 * Depending on the class on which this method is called, additional
 * type checking is performed. For example, `Number.Eq("foo", "bar")` throws
 * an error because `!("foo" is Number)`.
 * 
 * You can retrieve the equality function directly by using `<MyClass>.Eq`.
 * 
 * @example
 * ({ foo: "bar" }).Eq({ FOO: "BAR" }) ; true
 * 
 * ; (unset == unset)
 * Any.Eq(unset, unset) ; true
 * 
 * ; <Class>.Eq() does type-checking.
 * Object.Eq(124, 45) ; Error! Expected an Object.
 * 
 * ; returns the equality function
 * MapEquality := Map.Eq ; Eq(Map A?, Map B?) { ... }
 * 
 * @module  <Base/Eq>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Eq extends AquaHotkey
{
;-------------------------------------------------------------------------------
;@region Any

class Any {
    /**
     * Determines whether this value is equal to the `Other` value.
     * 
     * If not otherwise overridden, two values `A` and `B` are
     * equal, if `A = B`.
     * 
     * In other words, regular (case-insensitive) equality checks are used,
     * unless specified otherwise.
     * 
     * @example
     * (1).Eq("1") ; true
     * 
     * Obj := {}
     * Obj.Eq(Obj) ; true
     * 
     * @param   {Any}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) => (IsSet(Other) && (this = Other))
}

;@endregion
;-------------------------------------------------------------------------------
;@region Class

class Class {
    /**
     * Returns a type-checked 2-parameter equality function that supports
     * `unset` values.
     * 
     * @returns {Func}
     * @example
     * Eq := Map.Eq
     * 
     * Eq(Map(1, 2), Map(1, 2)) ; true
     * Eq(unset, unset)         ; true
     * Eq("foo", "bar")         ; TypeError! Expected a Map.
     */
    Eq => (A?, B?) => this.Eq(A?, B?)
    
    /**
     * If called with 1 parameter, determines whether this class is equal to the
     * other class. Otherwise, determines whether two given values are equal.
     * 
     * Type-checking based on the class on which the method is called. This
     * method supports `unset` values.
     * 
     * @param   {Any*}  Args  a class object, or two values
     * @returns {Boolean}
     * @example
     * String.Eq(String) ; regular `Class.Eq(Class)` method
     * 
     * String.Eq("foo", "bar") ; false
     * String.Eq(unset, unset) ; true
     * String.Eq([1, 2], "")   ; TypeError! Expected a String.
     */
    Eq(Args*) {
        switch (Args.Length) {
            case 1:
                return Args.Has(1) && (Args.Pop() = this)
            case 2:
                if (!Args.Has(1)) {
                    return (!Args.Has(2))
                }
                if (!Args.Has(2)) {
                    return false
                }
                A := Args[1]
                if (!(A is this)) {
                    throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                            Type(A))
                }
                B := Args[2]
                if (!(B is this)) {
                    throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                            Type(B))
                }
                return (A = B) || A.Eq(B)
            default:
                throw ValueError("invalid param count: " . Args.Length)
        }
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Array

class Array {
    /**
     * Determines whether this array is equal to the `Other` value.
     * 
     * This happens when...
     * 
     * - `Other` is an array with the same length;
     * - Elements in this array are equal to elements in `Other` (`.Eq()`).
     * 
     * @example
     * ([1, 2, 3]).Eq([1, 2, 3]) ; true
     * 
     * ([1]).Eq([1, 2]) ; false
     * 
     * ([1]).Eq("example") ; false
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        static AnyEq := (Any.Eq)

        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is Array)) {
            return false
        }

        if (this.Length != Other.Length) {
            return false
        }
        Enumer1 := this.__Enum(1)
        Enumer2 := Other.__Enum(1)

        while (Enumer1(&A) && Enumer2(&B)) {
            if (!IsSet(A)) {
                if (IsSet(B)) {
                    return false
                }
                continue
            }
            if (!IsSet(B)) {
                return false
            }
            if (!A.Eq(B)) {
                return false
            }
        }
        return true
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Object

class Object {
    /**
     * Determines whether this object is equal to the `Other` object.
     * 
     * This happens when `this == Other`, or...
     * 
     * - `ObjGetBase(this) == ObjGetBase(Other)`
     * - `this` and `Other` share the same set of properties
     * - properties with `Value` descriptor are equal (`.Eq()`)
     */
    Eq(Other?) {
        static GetProp := ({}.GetOwnPropDesc)

        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!IsObject(Other)) {
            return false
        }
        if (ObjGetBase(this) != ObjGetBase(Other)) {
            return false
        }
        
        if (ObjOwnPropCount(this) != ObjOwnPropCount(Other)) {
            return false
        }

        ThisEnumer := ObjOwnProps(this)
        OtherEnumer := ObjOwnProps(Other)

        while (ThisEnumer(&ThisProp) && OtherEnumer(&OtherProp)) {
            if (ThisProp != OtherProp) {
                return false
            }
            ; value of this object prop
            PropDesc := GetProp(this, ThisProp)
            ThisValue := (ObjHasOwnProp(PropDesc, "Value"))
                    ? PropDesc.Value
                    : unset
            
            ; value of other object prop
            PropDesc := GetProp(Other, OtherProp)
            OtherValue := (ObjHasOwnProp(PropDesc, "Value"))
                    ? PropDesc.Value
                    : unset

            if (!IsSet(ThisValue)) {
                if (IsSet(OtherValue)) {
                    return false
                }
                ; both are `unset`
                continue
            }
            if (!IsSet(OtherValue) || !ThisValue.Eq(OtherValue)) {
                return false
            }
        }
        return true
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Reference Equality

class ByReference extends AquaHotkey_MultiApply {
    static __New() => super.__New(
        Buffer, Class, Error, File, Func, Gui, Gui.Control,
        InputHook, Menu, MenuBar, RegExMatchInfo, ComObjArray)

    /**
     * Determines whether this value is equal to the `Other` value according
     * to object reference.
     * 
     * This happens if both values share the same reference.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) => (IsSet(Other) && (this = Other))
}

;@endregion
;-------------------------------------------------------------------------------
;@region Map

class Map {
    /**
     * Determines whether this `Map` is equal to the `Other` value.
     * 
     * This happens when `Other` is a map that shares the same set of key-value
     * pairs.
     * 
     * @example
     * Map(1, 2, 3, 4).Eq(Map(1, 2, 3, 4)) ; true
     * 
     * @param   {Any*}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is Map)) {
            return false
        }
        if (this.Count != Other.Count) {
            return false
        }

        for Key, Value in this {
            if (!Other.Has(Key) || !Other.Get(Key).Eq(Value)) {
                return false
            }
        }
        return true
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region VarRef

class VarRef {
    /**
     * Determines whether this `VarRef` equals to the `Other` value.
     * 
     * This happens when `Other` is also a `VarRef` and the underlying values
     * are equal.
     * 
     * @example
     * A := &(StrA := "foo")
     * B := &(StrB := "foo")
     * 
     * MsgBox(A.Eq(B)) ; true
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is VarRef)) {
            return false
        }
        if (IsSetRef(this)) {
            return IsSetRef(Other) && (%this%.Eq(%Other%))
        }
        return !IsSetRef(Other)
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region ComValue

class ComValue {
    /**
     * Determines whether this `ComValue` is equal to the `Other` value.
     * 
     * This happens when the underlying value and `VARIANT` type are equal.
     * 
     * @example
     * ComValue(0xB, true).Eq(ComValue(0xB, true))
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is ComValue)) {
            return false
        }
        return (ComObjValue(this) == ComObjValue(Other))
            && (ComObjType(this) == ComObjType(Other))
    }
}

;@endregion
} ; class AquaHotkey_Eq extends AquaHotkey
