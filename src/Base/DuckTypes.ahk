#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO use own class (e.g. `TypeDef`) for composing intersections, unions, etc.?

/**
 * Provides a flexible and customizable duck typing system which extends the
 * functionality of the `is`-keyword.
 * 
 * ```ahk
 * User := { age: Integer, name: String }
 * Pattern := Array.OfType(User)
 * 
 * Obj := [{ age: 21, name: "Sasha" },
 *         { age: 37, name: "Sofia" }]
 * 
 * Obj.Is(Pattern) ; true
 * ```
 * 
 * Instead of caring about the base object, duck types can impose any
 * arbitrary set of characteristics which a type must fulfill in order to
 * be considered *member* of that type.
 * 
 * To determine the *membership* of a value `V` to a duck type `T`, you can
 * use `V.Is(T)`.
 * 
 * ```ahk
 * "foo".Is(String) ; true
 * ```
 * 
 * ---
 * 
 * ### How it Works
 * 
 * A duck type is defined by its `.IsInstance()` function, a predicate that
 * determines whether a value is instance of the type. `"foo".Is(String)`
 * immediately dispatches to `String.IsInstance("foo")`, which determines
 * whether it "is" a string.
 * 
 * ```
 * "foo".Is(String) ; true
 * 
 * ; --> same as...
 * String.IsInstance("foo") ; true
 * ```
 * 
 * Because this system is predicate-based, it becomes extremely flexible
 * and customizable. To implement a duck type, define a new class, and
 * a method `static IsInstance(Val?)`:
 * 
 * ```ahk
 * class Numeric {
 *     ; note: `Val` should always be an optional parameter.
 *     static IsInstance(Val?) => IsSet(Val) && IsNumber(Val)
 * }
 * 
 * (42).Is(Numeric)      ; true
 * "235.5".Is(Numeric) ; true
 * 
 * ```
 * 
 * We've just implemented a simple duck type `Numeric`. A value is instance
 * of `Numeric`, if it's...
 * - 1. not `unset`;
 * - 2. a `Number`, or a numeric `String`.
 * 
 * ---
 * 
 * ### Literals
 * 
 * Primitive types, such as strings or numbers are used as literals which
 * are checked for equality ({@link AquaHotkey_Eq `.Eq()`}).
 * 
 * ```ahk
 * ; --> true
 * ({ Value: 1, foo: "bar", baz: Integer[](1, 2, 3) }).Is({ Value: 1 })
 * ```
 * 
 * ### Pattern Matching
 * 
 * Plain objects can be used as structural patterns that check for an object's
 * key-value mappings, for example:
 * 
 * ```ahk
 * Success := { status: 200, data: Any }
 * 
 * Obj := { status 200, data: "example" }
 * ```
 * 
 * To clarify, "plain object" should mean that it directly derives from
 * `Object.Prototype`, for example object literals such as `{ Value: 42 }`.
 * 
 * ---
 * 
 * You can also test for the "shape" of an array by using patterns, or - more
 * interestingly - {@link GenericArray generic array classes}.
 * 
 * ```ahk
 * ; T: a size 2 array, 1st element as string, 2nd element as integer
 * T := [ String, Integer ]
 * 
 * ; this pattern is order-specific
 * ([ "giraffe", 42 ]).Is(T) ; true
 * ([ 42, "giraffe" ]).Is(T) ; false (wrong order)
 * 
 * ; determine whether every element `.Is(Integer)`
 * ( [ 1, 2, 3, 4 ] ).Is(Integer[]) ; true
 * 
 * ; note:
 * ; on generic arrays, the component type (in other words, the type contained
 * ; in the generic array), as well as the additional constraint are checked
 * ; for compatibility, not its elements.
 * Integer[](1, 2, 3, 4).Is(Number[])
 * ; -> Number.CanCastFrom(Integer)
 * ; -> (Integer == Number) || HasBase(Integer, Number)
 * ; -> true
 * ```
 * 
 * ---
 * 
 * These patterns can be arbitrarily complex and used well in conjunction with
 * AquaHotkey's generic array and map types:
 * 
 * ```ahk
 * ; an object that matches any of these three shapes
 * ApiResponse := Type.Union(
 *     { status: 200, data: Any },
 *     { status: 301, to: String },
 *     { status: 400, error: Error }
 * )
 * 
 * ; custom type for timestamps (also see: `IsSet()` in AHK docs)
 * class Timestamp {
 *     static IsInstance(Val?) => IsSet(Val) && IsTime(Val)
 * }
 * 
 * ; create a generic Map class
 * Log := Map.OfType(Timestamp, ApiResponse)
 * ```
 * 
 * ---
 * 
 * ### Subtypes
 * 
 * `T1.CanCastFrom(T2)` determines whether `T1 == T2`, or if `T2` is
 * considered a subtype of `T1`.
 * 
 * ```ahk
 * Number.CanCastFrom(Number)  ; --> true (because `Number == Number`)
 * Number.CanCastFrom(Integer) ; --> true (because `HasBase(Integer, Number)`)
 * 
 * ; --> true
 * ({ Value: Number }).CanCastFrom({ Value: Integer, OtherValue: Any })
 * ```
 * 
 * @module  <Base/DuckTypes>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link GenericArray}
 * @see {@link GenericMap}
 * @example
 * ; user-defined type
 * class Numeric {
 *     static IsInstance(Val?) => IsSet(Val) && IsNumber(Val)
 * }
 * "123".Is(String)      ; true ("123" is String)
 * "123".Is(Numeric)     ; true (IsNumber("123"))
 * 
 * @example
 * ; test if `Integer` is equivalent to, or a subtype of `Number`
 * ; -> true, because `HasBase(Integer, Number)`
 * Number.CanCastFrom(Integer) 
 * 
 * @example
 * ; defining a custom constraint (`GreaterThan(0)` as numbers that are `> 0`)
 * class GreaterThan {
 *     __New(Num) {
 *         this.Value := Num
 *     }
 *     ; value must be a number and `> Num`
 *     IsInstance(Val?) {
 *         return IsSet(Val) && IsNumber(Val) && (Val > this.Value)
 *     }
 *     ; For example: every number greater than 1 (`GreaterThan(1)`) is also
 *     ; greater than 0 (`GreaterThan(0)`).
 *     CanCastFrom(Other) {
 *         return (Other is GreaterThan) && (Other.Value >= this.Value)
 *     }
 * }
 */
class AquaHotkey_DuckTypes extends AquaHotkey
{
    ;@region Any

    class Any {
        /**
         * Determines whether this value matches the type pattern specified
         * by the given object `T`. This method delegates to
         * `T.IsInstance(this)`, and should not be overridden.
         * 
         * @param   {Class}  T  expected class
         * @returns {Boolean}
         * @example
         * class Numeric {
         *     static IsInstance(Val?) => (IsSet(Val) && IsNumber(Val))
         * }
         * 
         * "123".Is(String)      ; true
         * "example".Is(Numeric) ; false
         */
        Is(T) => T.IsInstance(this)

        /**
         * Determines whether the given value matches the type pattern specified
         * by this value.
         * 
         * For non-objects, this is true whenever both values are considered
         * equal `.Eq()`.
         * 
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         * @example
         * (42).IsInstance(42) ; true (`IsSet(42) && 42.Eq(42)`)
         */
        IsInstance(Val?) => IsSet(Val) && this.Eq(Val)

        /**
         * Determines whether the given value can be "cast" into this value.
         * 
         * For non-objects, this is only true if both values are equal `.Eq()`.
         * 
         * @param   {Any}  T  any value
         * @returns {Boolean}
         * @example
         * (42).CanCastFrom(42) ; true
         */
        CanCastFrom(T) => this.Eq(T)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Object

    class Object {
        /**
         * Determines whether the given value matches the type specification
         * asserted by this object.
         * 
         * The calling object is required to be an object literal. In other
         * words, it must be a simple object that directly inherits from
         * `Object.Prototype`.
         * 
         * This object's own fields are used for pattern matching the own fields
         * of the given object. Primitive types are matched using `.Eq()`,
         * objects are matched using `.IsInstance()`
         * 
         * @param    {Any?}  Val  any value
         * @returns  {Boolean}
         * @example
         * Success := { status: 200, data: Any }
         * 
         * Success.IsInstance({ status: 200, data: String }) ; true
         */
        IsInstance(Val?) {
            static GetProp := {}.GetOwnPropDesc
            if (!IsSet(Val) || !IsObject(Val)) {
                return false
            }

            if (ObjGetBase(this) != Object.Prototype) {
                return false
            }
            if (ObjGetBase(Val) != Object.Prototype) {
                return false
            }

            for Name in ObjOwnProps(this) {
                ; get patterns of this object
                PropDesc := GetProp(this, Name)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    continue
                }
                Pattern := PropDesc.Value

                ; get the same property of other object, if applicable
                PropValue := unset
                if (ObjHasOwnProp(Val, Name)) {
                    PropDesc := GetProp(Val, Name)
                    if (ObjHasOwnProp(PropDesc, "Value")) {
                        PropValue := PropDesc.Value
                    }
                }

                ; property value must match pattern
                if (!Pattern.IsInstance(PropValue?)) {
                    return false
                }
            }
            return true
        }

        /**
         * Determines whether the object is considered equivalent to, or
         * a subtype of this type pattern.
         * 
         * @param   {Any}  T  any value
         * @returns {Boolean}
         * @example
         * ({ x: Number, y: Number }).CanCastFrom({ x: Integer, y: Integer })
         */
        CanCastFrom(T) {
            static GetProp := {}.GetOwnPropDesc

            ; this is only meant to work on object literals
            if (ObjGetBase(T) != Object.Prototype) {
                return false
            }

            for Name in ObjOwnProps(this) {
                PropDesc := GetProp(this, Name)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    continue
                }
                Pattern := PropDesc.Value
                if (!ObjHasOwnProp(T, Name)) {
                    return false
                }
                PropDesc := GetProp(T, Name)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    return false
                }
                PropT := PropDesc.Value
                if (!Pattern.CanCastFrom(PropT)) {
                    return false
                }
            }
            return true
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Array

    class Array {
        /**
         * Determines whether the given value (an array) can be pattern matched
         * with this array.
         * 
         * This array's elements are used for pattern matching the elements
         * of the other array. Primitive types are matched using `.Eq()`,
         * objects are matched using `.IsInstance()`.
         * 
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         * @example
         * ( ["foo", "bar", 42] ).Is( [String, String, Integer] ) ; true
         * 
         * ( [unset, 42] ).Is( [unset, Integer] ) ; true
         * ( ["foo", 42] ).Is( [unset, Integer] ) ; false
         */
        IsInstance(Val?) {
            if (!IsSet(Val) || !(Val is Array) || Val.Length != this.Length) {
                return false
            }

            loop this.Length {
                if (this.Has(A_Index)) {
                    Pattern := this.Get(A_Index)
                    Elem := Val.Has(A_Index)
                        ? Val.Get(A_Index)
                        : unset

                    if (!Pattern.IsInstance(Elem?)) {
                        return false
                    }
                } else if (Val.Has(A_Index)) { ; does not match `unset`
                    return false
                }
            }
            return true
        }

        /**
         * Determines whether the given type `Other` is equal to the pattern
         * imposed by this array, or its subtype.
         * 
         * Each element of this array is compared to the corresponding element
         * of the other array. For each pair of elements, `.CanCastFrom()` is
         * called on the pattern element (from this array) with the other
         * element as argument. Both arrays must have identical length, as
         * well as matching elements at each index position.
         * 
         * @param   {Any}  Val  any value
         * @returns {Boolean}
         * @example
         * ([Number, Integer]).CanCastFrom([Integer, Integer]) ; true
         * 
         * ([unset]).CanCastFrom([unset]) ; true
         * ([unset]).CanCastFrom([String]) ; false
         * ([String]).CanCastFrom([unset]) ; false
         * 
         * ([{ Value: Number }]).CanCastFrom([{ Value: Integer }])
         * ; --> `({ Value: Number }).CanCastFrom({ Value: Integer })`
         * ; --> true
         */
        CanCastFrom(Other) {
            if (!(Other is Array) || (this.Length != Other.Length)) {
                return false
            }

            loop (this.Length) {
                if (this.Has(A_Index)) {
                    if (!Other.Has(A_Index)) {
                        return false
                    }
                    if (!(this.Get(A_Index).CanCastFrom(Other.Get(A_Index)))) {
                        return false
                    }
                } else if (Other.Has(A_Index)) {
                    return false
                }
            }
            return true
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Class

    class Class {
        /**
         * Determines whether a value is an instance of this class.
         * 
         * The default behaviour of this method is using the `is` keyword to
         * determine if the value uses the prototype of this class as base
         * object.
         * 
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         * @example
         * "123".Is(String)      ; true
         * "example".Is(Numeric) ; false
         */
        IsInstance(Val?) => IsSet(Val) && (Val is this)

        /**
         * Determines whether the given value is equal to this class, or
         * its subclass.
         * 
         * @param   {Class}  T  any class
         * @returns {Boolean}
         * @example
         * 
         * ; Integer
         * ; `- Number <- (base class)
         * Number.CanCastFrom(Integer)
         */
        CanCastFrom(T) => (this == T) || HasBase(T, this) || (T is this)
        ; note: because something like `Any.CanCastFrom({ foo: Integer })`
        ;       should return `true` (makes sense), we're also checking
        ;       `(T is this)`. Somehow, this *didn't* destroy any tests?
        ;       very nice.
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type

    class Type {
        /**
         * Creates a type class that represents a union of the specified types.
         * 
         * @param   {Class*}  Types  one or more classes
         * @returns {Class}
         * @example
         * StringOrInteger := Type.Union(String, Integer)
         */
        static Union(Types*) {
            if (!Types.Length) {
                throw UnsetError("no values specified")
            }
            for T in Types {
                if (!IsSet(T)) {
                    throw UnsetError("unset value")
                }
            }
            return IsInstance

            /**
             * Returns whether the given value is considered an instance of
             * this union type.
             * 
             * @param   {Any?}  Val  any value
             * @returns {Boolean}
             * @example
             * "42".Is( Type.Union(String, Integer) ) ; true
             */
            IsInstance(Val?) {
                for T in Types {
                    if (T.IsInstance(Val?)) {
                        return true
                    }
                }
                return false
            }
        }

        /**
         * Creates a type class that represents an intersection of the specified
         * types.
         * 
         * @param   {Class*}  Types  one or more classes
         * @returns {Class}
         * @example
         * T := Type.Union({ status: 200 }, { data: Any })
         * 
         * Obj := { status: 200, data: "success!" }
         * MsgBox(Obj.Is(T)) ; true
         */
        static Intersection(Types*) {
            if (!Types.Length) {
                throw UnsetError("no values specified")
            }
            for T in Types {
                if (!IsSet(T)) {
                    throw UnsetError("unset value")
                }
            }
            return IsInstance

            /**
             * Determines whether the given value is considered an instance of
             * this intersection type.
             * 
             * @param   {Any?}  Val  any value
             * @returns {Boolean}
             * @example
             * "42".Is( Type.Intersection(Numeric, String) ) ; true
             */
            IsInstance(Val?) {
                for T in Types {
                    if (!T.IsInstance(Val?)) {
                        return false
                    }
                }
                return true
            }
        }

        /**
         * Creates a type class which represents an enumeration of the given
         * values. On pattern matching, `.Eq()` is used for comparing values.
         * 
         * @param   {Any*}  Values  one or more values
         * @returns {Class}
         * @example
         * Permission := Type.Enum("Admin", "User", "Guest")
         * 
         * Permission.IsInstance("Admin") ; true
         * Permission.IsInstance("Other") ; false
         */
        static Enum(Values*) {
            if (!Values.Length) {
                throw UnsetError("no values specified")
            }
            for V in Values {
                if (!IsSet(V)) {
                    throw UnsetError("unset value")
                }
            }
            return IsInstance

            /**
             * Determines whether the given value is considered an instance of
             * this enum type.
             * 
             * @param   {Any?}  Val  any value
             * @returns {Boolean}
             * @example
             * T := Type.Enum("A", "B", "C")
             * 
             * MsgBox("A".Is(T)) ; true
             * MsgBox("?".Is(T)) ; false
             */
            IsInstance(Val?) {
                for V in Values {
                    if (V.Eq(Val?)) {
                        return true
                    }
                }
                return false
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Func

    class Func {
        /**
         * Returns a wrapped function that checks whether its arguments
         * conform to the given type `Signature`.
         * 
         * @param   {Any}  Signature  the expected type of the first argument
         * @returns {Closure}
         * @example
         * Sum(A, B) => (A + B)
         * 
         * CheckedSum := Sum.Checked(Numeric, Numeric)
         * CheckedSum(2, 2)
         */
        Checked(Signature) {
            ObjSetBase(Checked, ObjGetBase(this))
            return Checked

            Checked(Args*) {
                if (Signature.IsInstance(Args)) {
                    return this(Args*)
                }

                if (Args.Length == 1) {
                    Value := (Args.Has(1)) ? Args.Get(1) : unset
                    if (Signature.IsInstance(Value?)) {
                        return this(Value?)
                    }
                }
                throw TypeError("Invalid type")
            }
        }

        /**
         * Determines whether the given value matches the type imposed by
         * this function.
         * 
         * Using this method on a function is somewhat discouraged, as
         * they do not implement `.CanCastFrom()`. Whenever possible, you
         * should define your own duck type class, or use type wrappers on
         * existing types.
         * 
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         * @example
         * Callable := (Val?) => IsSet(Val) && IsObject(Val) && HasMethod(Val)
         * 
         * MsgBox.Is(Callable) ; true
         * 
         * ; better alternative: define a duck type class
         * class Callable {
         *     static IsInstance(Val?) {
         *         return IsSet(Val) && IsObject(Val) && HasMethod(Val)
         *     }
         *     static CanCastFrom(T) {
         *         return super.CanCastFrom(T) || Func.CanCastFrom(T)
         *     }
         * }
         */
        IsInstance(Val?) => this(Val?)
    }

    ;@endregion
}
