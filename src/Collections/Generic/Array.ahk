#Requires AutoHotkey >=v2.1-alpha.3
; #Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include <AquaHotkeyX>

;TODO remove constraints completely in favor of type creation?

;@region GenericArray
/**
 * Introduces type-checked arrays using intuitive array syntax (`[]`).
 * 
 * ### Quick Start
 * 
 * Calling `__Item[]` on a class `T` returns its "array class" `T[]` - a
 * subclass of `GenericArray` - which asserts that an element `.Is(T)`
 * whenever added or modified.
 * 
 * ```ahk
 * Arr := String[]("foo", "bar")
 * Arr.Push(Buffer(16)) ; Error! Expected a(n) String.
 * ```
 * 
 * `unset` is generally allowed, unless the array class specifies additional
 * constraints.
 * 
 * ---
 * 
 * ### Constraints
 * 
 * Elements can be further constrained by passing a class between the square
 * brackets. They are assumed to have their own custom `static IsInstance(Val?)`
 * implementations.
 * 
 * ```ahk
 * class NonNull {
 *     ; NOTE: for constraints, `Val` is an optional parameter
 *     static Call(Val?) => IsSet(Val)
 * }
 * ```
 * 
 * ---
 * 
 * These "constraint classes" can further be narrowed by using subclasses,
 * for example:
 * 
 * ```ahk
 * class NonNullNonEmpty {
 *     static Call(Val?) => super(Val?) && (Val != "")
 * }
 * ```
 * 
 * ---
 * 
 * ### Type-Checking
 * 
 * The `is` keyword won't reliably be able to determine the type of generic
 * array. Instead, use `.Is()`.
 * 
 * @module  <Collections/Generic/Array>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * ; additional constraint (forbids `unset`)
 * class NonNull {
 *     static IsInstance(Val?) => IsSet(Val)
 * }
 * 
 * ; a more specific version of `NonNull`
 * class NonNullNonEmpty extends NonNull {
 *     static IsInstance(Val?) => super.IsInstance(Val?) && (Val != "")
 * }
 * 
 * Arr := String[NonNullNonEmpty]("foo", "bar")
 * 
 * Arr.Is(String[NonNull]) ; true (`NonNullNonEmpty extends NonNull`)
 * Arr.Is(String[])        ; true
 * Arr.Is(Any[])           ; true (`Any.CanCastFrom(String)`)
 * Arr.Is(Any[NonNull])    ; true
 * 
 * ( String[]() ).Is( Any[NonNull] ) ; false (because of `NonNull`)
 * 
 * Arr.Push([1, 2]) ; Error! Expected a string.
 * Arr.Push(unset)  ; Error! Failed assertion (NonNullNonEmpty)
 * Arr.Delete(1)    ; Error! Failed assertion (NonNullNonEmpty)
 * Arr[1] := "qux"  ; ok.
 */
class GenericArray extends Array {
    ;@region Construction
    /**
     * Constructs a new subclass of `GenericArray`.
     * 
     * @param   {Class}   T           the type to be checked
     * @param   {Class?}  Constraint  additional constraint to enforce
     * @example
     * ; constraint class
     * class NonNull {
     *     static Call(Val?) => IsSet(Val)
     * }
     * 
     * ; array class containing only strings
     * Arr := String[]()
     * 
     * ; array class that allows all data types, but not `unset`
     * Arr := Any[NonNull]()
     */
    static __New(T?, Constraint?) {
        static Define := {}.DefineProp

        if (this == GenericArray) {
            return
        }
        if (!IsSet(T)) {
            throw UnsetError("unset value")
        }

        Proto := this.Prototype

        if (IsSet(Constraint)) {
            if (!(Constraint is Class)) {
                throw TypeError("Expected a Class",, Type(Constraint))
            }
            Fn := TypeCheckWithConstraint
            Define(Proto, "Constraint", { Get: (_) => (Constraint) })
        } else {
            Fn := TypeCheck
        }

        Define(Proto, "Check", { Call: Fn })
        Define(Proto, "ComponentType", { Get: (_) => (T) })

        TypeCheck(_, Val?) {
            if (IsSet(Val) && !T.IsInstance(Val)) {
                throw TypeError("Invalid type")
            }
        }

        TypeCheckWithConstraint(_, Val?) {
            if (IsSet(Val) && !T.IsInstance(Val)) {
                throw TypeError("Invalid type")
            }
            if (!Constraint.IsInstance(Val?)) {
                throw ValueError("Failed assertion")
            }
        }
    }
    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Array Methods

    /**
     * Creates a new array with additional checking.
     * 
     * @param   {Any*}  Values  zero or more values
     */
    __New(Values*) {
        for Value in Values {
            this.Check(Value?)
        }
        super.__New(Values*)
    }

    /**
     * Determines whether the given value is a valid array element.
     * 
     * This method should be overridden by subclasses.
     * 
     * @abstract
     * @param   {Any?}  Val   the value
     * @returns {Boolean}
     */
    Check(Val?) {
        ; nop
    }

    /**
     * Pushes zero or more elements to the array with additional checking.
     * 
     * @param   {Any*}  Values  zero or more values to be pushed
     */
    Push(Values*) {
        for Value in Values {
            this.Check(Value?)
        }
        return super.Push(Values*)
    }

    /**
     * Inserts elements into the array at the given index.
     * 
     * @param   {Integer}  Idx     index at which to insert
     * @param   {Any*}     Values  the values to be inserted
     */
    InsertAt(Idx, Values*) {
        for Value in Values {
            this.Check(Value?)
        }
        return super.InsertAt(Idx, Values*)
    }

    /**
     * Sets a value in the array.
     * 
     * @param   {Integer}  Index  array index
     * @param   {Any?}     value  the new value
     */
    __Item[Index] {
        set {
            this.Check(value?)
            super[Index] := (value ?? unset)
        }
    }

    /**
     * Deletes an item from the array, returning the previously contained
     * value.
     * 
     * @param   {Integer}  Index  a valid array index
     * @returns {Any}
     */
    Delete(Index) {
        this.Check(unset)
        return super.Delete(Index)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Info

    /**
     * Returns the component type of this generic array. In other words, the
     * type of class out of which the array consists of.
     * 
     * @returns {Class}
     */
    static ComponentType => (this.Prototype).ComponentType

    /**
     * Returns the component type of this generic array. In other words, the
     * type of class out of which the array consists of.
     * 
     * @abstract
     * @returns {Class}
     */
    ComponentType {
        get {
            throw PropertyError("component type not found")
        }
    }

    /**
     * Returns the additional constraint of this array class, or `false` if
     * there is none.
     * 
     * @returns {Func}
     */
    static Constraint => (this.Prototype).Constraint

    /**
     * Returns the additional constraint of this array class, or `false` if
     * there is none.
     * 
     * @abstract
     * @returns {Func}
     */
    Constraint => false

    /**
     * Determines whether the given class `T` is considered a subclass of this
     * generic array class.
     * 
     * This depends on whether the component type can be assigned to that
     * of `T`. In other words, `A[].CanCastFrom(B[])`, if
     * `A.CanCastFrom(B)`.
     * 
     * If an array `A[]` has an additional constraint `C`, the component type is
     * simply seen as a narrower form of `A`. That means, `A[].CanCastFrom(A[C])`
     * is always `true`.
     * 
     * Lastly, `A[C1].CanCastFrom(B[C2])` requires both...
     * 1. `A.CanCastFrom(B)`
     * 2. `C1.CanCastFrom(C2)`
     * 
     * If this or the other array has additional constraints, they are assumed
     * to be classes with a method `static Call(Val?)`, and checked for
     * compatibility in the following way:
     * 
     * - `A[].CanCastFrom(B[Cons])` returns `true`
     * - `A[A_Cons].CanCastFrom(B[B_Cons])` requires`A_Cons.CanCastFrom(B_Cons)`
     * 
     * @param   {Class}  T  any class
     * @returns {Boolean}
     * @example
     * ; true (because `String`)
     * Any[].CanCastFrom(String[])
     */
    static CanCastFrom(T) {
        if (super.CanCastFrom(T)) {
            return true
        }
        if (!HasBase(T, GenericArray)) {
            return false
        }

        Cons := this.Constraint
        if (Cons && !Cons.CanCastFrom(T.Constraint)) {
            return false
        }
        return (this.ComponentType).CanCastFrom(T.ComponentType)
    }

    /**
     * Determines whether the given value is an instance of this generic array
     * class. Regular arrays are checked by their elements, while for generic
     * arrays, the component type is checked for compatibility via
     * `CanCastFrom()`.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * ([1, 2, 3]).Is(Integer[])       ; true
     * Integer[](1, 2, 3).Is(Number[]) ; true
     */
    static IsInstance(Val?) {
        if (!IsSet(Val) || !(Val is Array)) {
            return false
        }

        ; check non-generic array by their elements
        if (!(Val is GenericArray)) {
            T    := this.ComponentType
            Cons := this.Constraint

            if (Cons) {
                for Elem in Val {
                    if (!T.IsInstance(Elem?)) {
                        return false
                    }
                    if (!Cons.IsInstance(Elem?)) {
                        return false
                    }
                }
            } else {
                for Elem in Val {
                    if (!T.IsInstance(Elem?)) {
                        return false
                    }
                }
            }
            return true
        }

        return (this.ComponentType).CanCastFrom(Val.ComponentType)
            ; TODO make constraint check less fragile
            && (this.Constraint).CanCastFrom(Val.Constraint)
    }

    ;@endregion
}
;@endregion

;@region Extensions
class AquaHotkey_GenericArray extends AquaHotkey {
    class Any {
        /**
         * Returns the "array class" of this value.
         * 
         * @param   {Any?}  Constraint  additional type constraint
         * @returns {Class}
         * @example
         * User    := { name: String, age: Integer }
         * UserArr := User.ArrayType
         */
        ArrayType[Constraint?] => AquaHotkey.CreateClass(
                GenericArray,
                (this is Class) ? (this.Prototype.__Class  . "[]") : "",
                this,
                Constraint?)
    }

    class Class {
        /**
         * Returns the "array class" of this class.
         * 
         * @param   {Any?}  Constraint  additional type constraint
         * @returns {Class}
         * @example
         * ArrClass := Number[]
         * Arr := ArrClass(23, 1, 45)
         * 
         * ; shorthand
         * Number[](23, 1, 45)
         */
        __Item[Constraint?] => this.ArrayType[Constraint?]
    }

    class Array {
        /**
         * Returns the "array class" of the given type, and optional
         * type constraint.
         * 
         * @param   {Any}   T           type pattern
         * @param   {Any?}  Constraint  additional type constraint
         * @returns {Class}
         * @example
         * Cls := Array.OfType({ status: 200, data: Any })
         */
        static OfType(T, Constraint?) => T.ArrayType[Constraint?]
    }
}
;@endregion
