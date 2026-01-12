#Requires AutoHotkey >=v2.1-alpha.3
; #Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include <AquaHotkeyX>

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
 * ### Constraints
 * 
 * Elements can be further constrained by passing a class between the square
 * brackets. They are assumed to have their own custom `static IsInstance()`
 * implementations.
 * 
 * ```ahk
 * class NonNull {
 *     ; NOTE: for constraints, `Val` is an optional parameter
 *     static Call(Val?) => IsSet(Val)
 * }
 * ```
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
 * ### Type-Checking
 * 
 * Existing classes are cached, which means calling e.g. `String[]` will
 * produce the same object, allowing you to use `is String[]` consistently.
 * 
 * However, it's highly recommended to use `.Is()` instead, in order to support
 * constraints.
 * 
 * @module  <Collections/Generic/Array>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * ; additional constraint (forbids `unset`)
 * class NonNull {
 *     static Call(Val?) => IsSet(Val)
 * }
 * 
 * ; a more specific version of `NonNull`
 * class NonNullNonEmpty {
 *     static Call(Val) => super(Val?) && (Val != "")
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
        if (!(T is Class)) {
            throw TypeError("Expected a Class",, Type(T))
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
            if (
                ; IsSet(Val) && !(Val is T)
                IsSet(Val) && !Val.Is(T)
            ) {
                throw TypeError("Expected a(n) " . T.Prototype.__Class,,
                                Type(Val))
            }
        }

        TypeCheckWithConstraint(_, Val?) {
            if (IsSet(Val) && !Val.Is(T)) {
                throw TypeError("Expected a(n) " . T.Prototype.__Class,,
                                Type(Val))
            }
            if (!Constraint.IsInstance(Val?)) {
                throw ValueError("Failed assertion",, Constraint.Name)
            }
        }
    }

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
}

class AquaHotkey_GenericArray extends AquaHotkey {
    class Class {
        /**
         * Returns the "array class" of this class.
         * 
         * @param   {Func?}  Constraint  additional validation function
         * @returns {Class}
         * @example
         * ArrClass := Number[]
         * Arr := ArrClass(23, 1, 45)
         * 
         * ; shorthand
         * Number[](23, 1, 45)
         */
        ArrayType[Constraint?] {
            get {
                static NONE := false
                static Classes := Map()

                if (Classes.Has(this)) {
                    Variations := Classes.Get(this)
                    Variation  := (IsSet(Constraint) && Constraint)
                    if (Variations.Has(Variation)) {
                        return Variations.Get(Variation)
                    }
                }

                ClsName := this.Prototype.__Class . "[]"
                ArrayType := AquaHotkey.CreateClass(
                        GenericArray,
                        ClsName,
                        this, Constraint?)
                
                if (!Classes.Has(this)) {
                    Classes.Set(this, Map())
                }
                Variations := Classes.Get(this)

                if (IsSet(Constraint)) {
                    GetMethod(Constraint)
                    Variations.Set(Constraint, ArrayType)
                } else {
                    Variations.Set(NONE, ArrayType)
                }
                return ArrayType
            }
        }

        /**
         * Returns the "array class" of this class.
         * 
         * @param   {Func?}  Constraint  additional validation function
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
         * Returns a type-checked array class.
         * 
         * @param   {Class}  T           type of elements contained in the array
         * @param   {Func?}  Constraint  additional validation function
         * @returns {Class}
         */
        static OfType(T, Constraint?) {
            if (!(T is Class)) {
                throw TypeError("Expected a Class",, Type(T))
            }
            return T[Constraint?]
        }
    }
}
