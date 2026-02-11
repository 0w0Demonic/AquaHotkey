#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IArray.ahk"

; TODO make sure classes are deletable

;@region GenericArray

/**
 * Introduces a type-checked wrapper for {@link IArray} classes with intuitive
 * array syntax (for example, `String[]`).
 * 
 * Calling `.__Item[]` on a class `T` (in other words, `T.__Item[]` or `T[]`)
 * returns its "array class" - a subclass of {@link IArray} - which asserts
 * that elements are instance of `T`.
 * 
 * ```ahk
 * Arr := String[]("foo", "bar", "baz")
 * 
 * MsgBox(Type(Arr)) ; "String[]"
 * ```
 * 
 * ---
 * 
 * Elements can be further constrained by passing a *type wrapper* like
 * {@link Nullable} between the square brackets.
 * 
 * ```ahk
 * Arr_String := String[]
 * Arr_MaybeString := String[Nullable] ; array of `Nullable(String)`
 * ```
 * 
 * @module  <Collections/GenericArray>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example <caption>Array of Strings</caption>
 * Arr_String := String[]("foo", "bar")
 * Arr_String.Push("baz")
 * Arr_String.Push(Buffer(16, 0)) ; TypeError! Expected a(n) String.
 * Arr_String.Push(unset)         ; UnsetError!
 * 
 * @example <caption>Array of Nullable Strings</caption>
 * Arr_MaybeString := String[Nullable]("foo", "bar", unset)
 * 
 * ; equivalent to:
 * Arr_MaybeString := Nullable(String)[]("foo", "bar", unset)
 * 
 * @example <caption>Support With Duck Types</caption>
 * Arr_String := String[]("foo", "bar")
 * 
 * Arr_String.Is(String[])         ; true
 * Arr_String.Is(String[Nullable]) ; true (because of `Nullable#IsInstance()`)
 * Arr_String.Is(Any[])            ; true
 * 
 * @example <caption>Using `IArray.OfType()`</caption>
 * class Email extends String {
 *     static IsInstance(Val?) => String.IsInstance(Val?) && (Val ~= "(regex)")
 * }
 * 
 * User := { name: String, age: Integer, email: Nullable(Email) }
 * WaitingLine := LinkedList.OfType(User)
 * 
 * @template A the array class
 * @template T type contained in the array
 */
class GenericArray extends IArray {
    ;@region Construction
    /**
     * Constructs a new subclass of `GenericArray` from the given array class
     * and type.
     * 
     * @param   {Class<? extends IArray>}  A  array class
     * @param   {Any}                      T  element type
     * @param   {Any?}                     C  additional constraint
     * @constructor
     * @example <caption>Array of Nullable Strings</caption>
     * Arr_MaybeString := String[Nullable]
     * 
     * ; equivalent to:
     * Arr_MaybeString := GenericArray(Array, String, Nullable)
     */
    static __New(A?, T?, C?) {
        if (this == GenericArray) {
            return
        }

        static Define := {}.DefineProp
        if (!IsSet(A)) {
            throw UnsetError("unset; Expected an IArray class")
        }
        if (!IsSet(T)) {
            throw UnsetError("unset; Expected element type")
        }

        if (!IArray.CanCastFrom(A)) {
            throw TypeError("Expected an IArray class",, String(A))
        }

        if (IsSet(C)) {
            if (!(C is Class)) {
                throw TypeError("Expected a Class",, Type(C))
            }
            if (!HasBase(C, Class)) {
                throw TypeError("Expected a type wrapper",, C.Name)
            }
            T := C(T) ; e.g.: `T := Nullable(String)`
        }

        Proto := this.Prototype
        Define(Proto, "ComponentType", { Get: (_) => T })
        Define(Proto, "ArrayType",     { Get: (_) => A })
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Info

    /**
     * Returns the component type of this generic array. In other words, the
     * type which the array holds elements of.
     * 
     * @returns {Any}
     * @see {@link GenericArray#ComponentType}
     */
    static ComponentType => (this.Prototype).ComponentType
    
    /**
     * Returns the component type of this generic array. In other words, the
     * type which the array holds elements of.
     * 
     * This property should be overridden by subclasses of `GenericArray`.
     * 
     * @abstract
     * @returns {Any}
     * @example
     * StrArr := String[]("foo", "bar")
     * 
     * MsgBox(String(StrArr.ComponentType)) ; "class String"
     */
    ComponentType {
        get {
            throw PropertyError("component type not found")
        }
    }

    /**
     * The type of array wrapped around.
     * 
     * @returns {Any}
     * @see {@link GenericArray#ArrayType}
     */
    static ArrayType => (this.Prototype).ArrayType

    /**
     * The type of array wrapped around.
     * 
     * This property should be overridden by subclasses of `GenericArray`.
     * 
     * @abstract
     * @returns {Any}
     * @example
     * LL := LinkedList.OfType(String)
     * 
     * MsgBox(String(LL.ArrayType)) ; "class LinkedList"
     */
    ArrayType {
        get {
            throw PropertyError("array type not found")
        }
    }

    /**
     * Determines whether the given class `T` is equal to this generic array
     * class, or considered its subtype.
     * 
     * This depends on the array and component type used by the class.
     * 
     * @param   {Class<? extends IArray>}  Other  other generic array class
     * @returns {Boolean}
     * @example
     * Any[Nullable].CanCastFrom(String[])
     * ; --> Array.CanCastFrom(Array)
     * ;  && Nullable(Any).CanCastFrom(String)
     * ;
     * ; --> true
     */
    static CanCastFrom(Other) {
        ; note: super.CanCastFrom(Other) == Class#CanCastFrom(Other)
        if (super.CanCastFrom(Other)) {
            return true
        }
        if (!HasBase(Other, GenericArray)) {
            return false
        }
        return (this.ArrayType).CanCastFrom(Other.ArrayType)
            && (this.ComponentType).CanCastFrom(Other.ComponentType)
    }

    /**
     * Determines whether the given value is an instance of this generic array
     * class. Regular arrays are checked by their elements, while for generic
     * arrays, the array and component type are checked for compatibility.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * ([1, 2, 3]).Is(Integer[])
     * ; --> true (each element is checked `Val.Is(Integer)`)
     * 
     * Integer[](1, 2, 3).Is(Number[]) 
     * ; --> true (because `Number.CanCastFrom(Integer)`)
     */
    static IsInstance(Val?) {
        if (!IsSet(Val) || !Val.Is(IArray)) {
            return false
        }

        if (Val is GenericArray) {
            return (this.ArrayType).CanCastFrom(Val.ArrayType)
                && (this.ComponentType).CanCastFrom(Val.ComponentType)
        }

        T := this.ComponentType

        for Elem in Val {
            if (!T.IsInstance(Elem?)) {
                return false
            }
        }
        return true
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Creates a hash code for this generic array.
     * 
     * @returns {Integer}
     */
    HashCode() => (this.A).HashCode()

    /**
     * Returns a hash code for this generic array class.
     * 
     * @returns {Integer}
     */
    static HashCode() => Any.Hash(this.ArrayType, this.ComponentType)

    /**
     * Determines whether the given value is equal to this generic array class.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     * @example
     * ; Integer[] is equivalent to: Array.OfType(Integer)
     * C1 := Integer[]
     * C2 := Integer[]
     * 
     * C1.Eq(C2)
     * ; --> Array.Eq(Array) && Integer.Eq(Integer)
     * ; --> true
     */
    static Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!HasBase(Other, GenericArray)) {
            return false
        }
        return (this.ArrayType).Eq(Other.ArrayType)
            && (this.ComponentType).Eq(Other.ComponentType)
    }

    /**
     * Returns a string representation of the generic array.
     * 
     * @returns {String}
     * @see {@link AquaHotkey_GenericArray.IArray.OfType() IArray.OfType()}
     * @example
     * LL := LinkedList.OfType(Integer).Call(1, 2, 3, 4)
     * 
     * MsgBox(String(LL)) ; "LinkedList<Integer>[1, 2, 3, 4]"
     */
    ToString() => Type(this) . String(this.A)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Checking

    /**
     * Determines whether the given value is a valid array element.
     * 
     * @param   {Any?}  Val  the value
     */
    Check(Val?) {
        if (!this.ComponentType.IsInstance(Val?)) {
            throw TypeError("Expected " . String(this.ComponentType),,
                    Type(Val))
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Array Methods

    /**
     * Returns a shallow copy of the array.
     * 
     * @returns {GenericArray<A, T>}
     */
    Clone() {
        Copy := (this.A).Clone()

        Obj := Object()
        Obj.DefineProp("A", { Get: (_) => Copy })

        ; same class; `ArrayType` and `ComponentType` should already be there.
        ObjSetBase(Obj, ObjGetBase(this))
        return Obj
    }

    /**
     * Deletes an item from the array, returning the previously contained
     * value.
     * 
     * @param   {Integer}  Index  a valid array index
     * @returns {T}
     */
    Delete(Index) {
        this.Check(unset)
        return (this.A).Delete(Index)
    }

    /**
     * Retrieves an item from the generic array.
     * 
     * @param   {Integer}  Index    array index
     * @param   {Any?}     Default  default value
     * @returns {Any}
     */
    Get(Index, Default?) => (this.A).Get(Index, Default?)

    /**
     * Determines whether the index is valid and there is a non-null value at
     * that array index.
     * 
     * @param   {Integer}  Index  array index
     * @returns {Boolean}
     */
    Has(Index) => (this.A).Has(Index)

    /**
     * Inserts elements into the array at the given index.
     * 
     * @param   {Integer}  Index   index at which to insert
     * @param   {T*}     Values  the values to be inserted
     */
    InsertAt(Index, Values*) {
        for Value in Values {
            this.Check(Value?)
        }
        return (this.A).InsertAt(Index, Values*)
    }

    /**
     * Removes and returns the last array element.
     * 
     * @returns {T}
     */
    Pop() => (this.A).Pop()

    /**
     * Pushes zero or more elements to the array.
     * 
     * @param   {T*}  Values  zero or more values to be pushed
     */
    Push(Values*) {
        for Value in Values {
            this.Check(Value?)
        }
        return (this.A).Push(Values*)
    }

    /**
     * Removes items from the array.
     * 
     * @param   {Integer}   Index   array index
     * @param   {Integer?}  Length  length of the range of values to remove
     * @returns {T}
     */
    RemoveAt(Index, Length?) => (this.A).RemoveAt(Index, Length?)

    /**
     * Creates a new instance of this generic array class.
     * 
     * @constructor
     * @param   {T*}  Values  zero or more values
     */
    __New(Values*) {
        A := (this.ArrayType)()

        this.DefineProp("A", { Get: (_) => A })
        this.Push(Values*)
    }

    /**
     * Returns an {@link Enumerator} for the array.
     * 
     * @param   {Integer}  ArgSize  arg-size of for-loop
     * @returns {Enumerator}
     */
    __Enum(ArgSize) => (this.A).__Enum(ArgSize)

    /**
     * Retrieves and sets items in the array.
     * 
     * @param   {Integer}  Index  array index
     * @param   {T}        value  new array element
     * @returns {T}
     */
    __Item[Index] {
        get => (this.A)[Index]
        set {
            this.Check(value?)
            (this.A)[Index] := (value?)
        }
    }

    /**
     * Retrieves and sets the length of the array.
     * 
     * @param   {Integer}  value  new length
     * @returns {Integer}
     */
    Length {
        get => (this.A).Length
        set {
            (this.A).Length := (value?)
        }
    }

    /**
     * Retrieves and sets the capacity of the array.
     * 
     * @param   {Integer}  value  new capacity
     * @returns {Integer}
     */
    Capacity {
        get => (this.A).Capacity
        set {
            (this.A).Capacity := (value?)
        }
    }

    /**
     * Retrieves and sets the `Default` property of the array.
     * 
     * @param   {Any}  value  value of default property
     * @returns {Any}
     */
    Default {
        get => (this.A).Default
        set {
            (this.A).Default := (value?)
        }
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extension methods related to {@link GenericArray}.
 */
class AquaHotkey_GenericArray extends AquaHotkey {
    class Class {
        /**
         * Returns the "array class" of this class.
         * 
         * @param   {Class?}  Constraint  additional type constraint
         * @returns {Class<? extends GenericArray<Array, this>>}
         */
        __Item[Constraint?] => Array.OfType(this, Constraint?)
    }

    class IArray {
        /**
         * Returns the "array class" of the given type, and optional type
         * constraint.
         * 
         * @param   {Any}   T           type pattern
         * @param   {Any?}  Constraint  additional type constraint
         * @returns {Class<? extends GenericArray<Array, this>>}
         * @example
         * User := { name: String, age: Integer }
         * T := LinkedList.OfType(Nullable(User))
         */
        static OfType(T, Constraint?) {
            OuterType     := "IArray"
            try OuterType := this.Name

            InnerType := (T is Class) ? T.Name : String(T)
            return AquaHotkey.CreateClass(
                    GenericArray, (OuterType . "<" . InnerType . ">"),
                    this, T, Constraint?)
        }
    }
}

;@endregion
