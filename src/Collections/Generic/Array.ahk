#Requires AutoHotkey >=v2.1-alpha.3
#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"

; TODO type casting
/**
 * Introduces type-checked arrays using intuitive array syntax (`[]`).
 * 
 * Calling `__Item[]` on a class (e.g. `Integer[]`) returns its "array class",
 * i.e. a subclass of `GenericArray` which asserts that an element
 * `is <Class>` whenever added or modified.
 * 
 * Elements can be further constrained by passing a validation function
 * between the square brackets.
 * 
 * ```ahk
 * Assertion(Elem?) => Boolean
 * ```
 * 
 * Existing classes are cached, which means calling e.g. `String[]` will
 * produce the same object, allowing you to use `is String[]` consistently.
 * 
 * @module  <Collections/Generic/Array>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * 
 * @example
 * ; additional constraint (forbids `unset`)
 * NonNull(Val?) => IsSet(Val?)
 * 
 * StrArray := String[NonNull]("foo", "bar")
 * 
 * MsgBox(StrArray is String[NonNull]) ; true
 * MsgBox(StrArray is String[])        ; false (unfortunately, for now)
 * 
 * StrArray.Push([1, 2]) ; Error! Expected a string.
 * StrArray.Push(unset)  ; Error! Failed assertion (NonNull)
 * StrArray.Delete(1)    ; Error! Failed assertion (NonNull)
 * StrArray[1] := "qux"  ; ok.
 */
class GenericArray extends Array {
    /**
     * Constructs a new subclass of `GenericArray`.
     * 
     * @param   {Class}  T           the type to be checked
     * @param   {Func?}  Constraint  additional constraint to enforce
     * @example
     * 
     * ; array class containing only strings
     * StringArray := String[]
     * 
     * ; array class that allows all data types, but not `unset`
     * Any[(V?) => IsSet(V)]
     */
    static __New(T?, Constraint?) {
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
            GetMethod(Constraint)
            Fn := TypeCheckWithConstraint
        } else {
            Fn := TypeCheck
        }
        ({}.DefineProp)(Proto, "Check", { Call: Fn })

        TypeCheck(_, Val?) {
            if (IsSet(Val) && !(Val is T)) {
                throw TypeError("Expected a(n) " . T.Prototype.__Class,,
                                Type(Val))
            }
        }

        TypeCheckWithConstraint(_, Val?) {
            if (IsSet(Val) && !(Val is T)) {
                throw TypeError("Expected a(n) " . T.Prototype.__Class,,
                                Type(Val))
            }
            if (!Constraint(Val?)) {
                throw ValueError("Failed assertion",,
                                 GetMethod(Constraint).Name)
            }
        }
    }

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
}

class AquaHotkey_GenericArray extends AquaHotkey {
    static __New() {
        if (this != AquaHotkey_GenericArray) {
            return
        }

        ; alias Class#ArrayType and Any.__Item
        ({}.DefineProp)(this.Class.Prototype, "ArrayType",
                ({}.GetOwnPropDesc)(this.Any, "__Item"))
        
        super.__New()
    }

    class Class {
        /**
         * Returns the "array class" of this class.
         * 
         * @param   {Func?}  Constraint  additional validation function
         * @returns {Class}
         * @example
         * Integer.ArrayType ; class Integer[]
         */
        ArrayType[Constraint?] {
            get {
                ; (Any) static __Item[]
            }
        }
    }

    class Any {
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
        static __Item[Constraint?] {
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
    }

    class Array {
        /**
         * Returns a type-checked array class.
         * 
         * @param   {Class}  T           type of elements contained in the array
         * @param   {Func?}  Constraint  additional validation function
         * @returns {Class<? extends GenericArray>}
         */
        static OfType(T, Constraint?) {
            if (!(T is Class)) {
                throw TypeError("Expected a Class",, Type(T))
            }
            ArrayClass := T[Constraint?]
        }
    }
}
