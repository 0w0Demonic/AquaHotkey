; #Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include <AquaHotkeyX>

; TODO change `.AssertType()` to use this module's `.Is()` ?
; TODO provide a way to turn a type pattern into a string ?

;@region Extensions
/**
 * Provides a flexible duck typing system which extends the functionality
 * of the `is`-keyword with user-defined pattern-matching.
 * 
 * Duck typing means we care what a value *does*, not what it *is* as defined
 * by its base objects.
 * 
 * ---
 * 
 * ### Simple Type Checking
 * 
 * To determine whether a value is considered instance of a given type, you can
 * use `Value.Is(Type)`, which is equivalent to `Type.IsInstance(Value?)`.
 * 
 * ```ahk
 * "foo".Is(String) ; true
 * 
 * ; equivalent:
 * String.IsInstance("foo") ; true
 * ```
 * 
 * For regular classes, this is evaluated as `("foo" is String)`.
 * 
 * ---
 * 
 * ### Custom Types
 * 
 * Instead of relying solely on class inheritance and base objects, types are
 * defined using their `IsInstance()` method. It accepts one argument (the
 * tested value) and determines whether it is considered an instance of that
 * type.
 * 
 * ```
 * class Numeric {
 *     static IsInstance(Val?) => IsSet(Val) && IsNumber(Val)
 * }
 * "123".Is(Numeric)
 * ```
 * 
 * `Numeric.IsInstance(Val?)` determines whether its input `Val?` - a nullable
 * argument - is considered an instance of `Numeric`. This should be true, if
 * the value is non-null and `IsNumber(Val)` returns true.
 * 
 * ---
 * 
 * ### Pattern Matching
 * 
 * Plain objects can be used as structural patterns that check for an object's
 * key-value mappings, for example:
 * 
 * ```ahk
 * ; any plain object with these fields is considered a "Person"
 * Person := { Name: String, Age: Integer }
 * 
 * Obj := { Name: "0w0Demonic", Age: 21 }
 * 
 * ; match our object against the "Person" type
 * ({ Name: "0w0Demonic", Age: 21 }).Is(Person) ; true
 * ```
 * 
 * To clarify, "plain object" should mean that it directly derives from
 * `Object.Prototype`, for example object literals such as `{ Value: 42 }`.
 * 
 * ---
 * 
 * You can also check the "shape" of an array by using patterns, or - more
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
 * ; in the generic array), as well as the additional constraint are checked for
 * ; compatibility, not its elements.
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
 * ApiResponse := Type.Union(
 *     { status: 200, data: Any },
 *     { status: 301, to: String },
 *     { status: 400, error: Error }
 * )
 * 
 * class Timestamp {
 *     static IsInstance(Val?) => ...
 * }
 * 
 * Log := Map.OfType(Timestamp, ApiResponse)
 * ```
 * 
 * ---
 * 
 * ### Subtypes
 * 
 * `Type.CanCastFrom(OtherType)` determines whether one type is considered
 * equivalent to, or a subtype of another.
 * 
 * For example:
 * 1. `Object` can cast from `Object`, because both types are equivalent.
 * 2. `Object` can cast from `Array`, because `Array` is a subtype
 *    (in this case - subclass) of `Object`
 * 3. `{ Value: Number }` can cast from `{ Value: Integer, OtherValue: Any }`
 * 
 * @module  <Base/TypeChecks>
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
class AquaHotkey_TypeChecks extends AquaHotkey {
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
         * @augments Any#IsInstance
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
         * TODO `unset` behaviour
         * 
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
                MsgBox("nope")
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
         * Determines whether this value is an instance of the given class, or
         * its superclass.
         * 
         * @param   {Class}  T  expected class
         * @returns {Boolean}
         * @example
         * 
         * ; Integer
         * ; `- Number <- (base class)
         * Number.CanCastFrom(Integer)
         */
        CanCastFrom(T) => (this == T) || HasBase(T, this)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type

    class Type {
        ; TODO figure out `unset` behaviour
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
            Result := Class()
            for T in Types {
                if (!IsSet(T)) {
                    throw UnsetError("unset value")
                }
            }
            ({}.DefineProp)(Result, "IsInstance", { Call: IsInstance })
            return Result

            /**
             * Returns whether the given value is considered an instance of
             * this union type.
             * 
             * @param   {Any?}  Val  any value
             * @returns {Boolean}
             * @example
             * "42".Is( Type.Union(String, Integer) ) ; true
             */
            IsInstance(this, Val?) {
                for T in Types {
                    if (T.IsInstance(Val?)) {
                        return true
                    }
                }
                return false
            }
        }

        ; TODO figure out `unset` behaviour
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
            Result := Class()
            ({}.DefineProp)(Result, "IsInstance", { Call: IsInstance })
            return Result

            /**
             * Determines whether the given value is considered an instance of
             * this intersection type.
             * 
             * @param   {Any?}  Val  any value
             * @returns {Boolean}
             * @example
             * "42".Is( Type.Intersection(Numeric, String) ) ; true
             */
            IsInstance(this, Val?) {
                for T in Types {
                    if (!T.IsInstance(Val?)) {
                        return false
                    }
                }
                return true
            }
        }

        ; TODO figure out `unset` behaviour
        /**
         * Creates a type class which represents an enumeration of the given
         * values. On pattern matching, `.Eq()` is used for comparing values.
         * 
         * @param   {Any*}  Values  one or more values
         * @returns {Class}
         * @example
         * Permissions := Type.Enum("Admin", "User", "Guest")
         * 
         * Permissions.IsInstance("Admin") ; true
         * Permissions.IsInstance("Other") ; false
         */
        static Enum(Values*) {
            if (!Values.Length) {
                throw UnsetError("no values specified")
            }
            Result := Class()
            for V in Values {
                if (!IsSet(V)) {
                    throw UnsetError("unset value")
                }
            }
            ({}.DefineProp)(Result, "IsInstance", { Call: IsInstance })
            return Result

            ; TODO `unset` behaviour

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
            IsInstance(this, Val?) {
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

    class Func {
        /**
         * 
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
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Numeric

/**
 * A number or numeric string (as determined by `IsNumber()`).
 */
class Numeric {
    /**
     * Determines whether the value is numeric.
     * 
     * @param   {Any}  Val  any value
     * @returns {Boolean}
     * @example
     * "example".Is(Numeric)     ; false
     * Numeric.IsInstance("123") ; true
     */
    static IsInstance(Val?) => IsSet(Val) && IsNumber(Val)

    /**
     * Determines whether the given class is considered a subclass of `Numeric`.
     * 
     * @param   {Class}  T  any class
     * @returns {Boolean}
     * @example
     * Numeric.CanCastFrom(Numeric) ; true
     * Numeric.CanCastFrom(Integer) ; true (every integer is numeric)
     */
    static CanCastFrom(T) {
        return super.CanCastFrom(T) || Number.CanCastFrom(T)
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Callable

/**
 * An object with `Call` property (`HasMethod()`).
 */
class Callable {
    /**
     * Determines whether the value is callable, excluding `.__Call()`.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * "example".Is(Callable)                        ; false
     * Callable.IsInstance(MsgBox)                   ; true
     * ({ Call: (this) => this.Value }).Is(Callable) ; true
     */
    static IsInstance(Val?) => IsSet(Val) && IsObject(Val) && HasMethod(Val)

    /**
     * Determines whether the given class is considered a subclass of
     * `Callable`.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * Callable.CanCastFrom(Func) ; true (every function is callable)
     */
    static CanCastFrom(T) {
        return (super.CanCastFrom(T) || Func.CanCastFrom(T))
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region BufferObject

/**
 * An object with `Ptr` and `Size` property.
 */
class BufferObject {
    /**
     * Determines whether the buffer is buffer-like.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * Buffer(16, 0).Is(BufferObject)        ; true
     * { Ptr: 0, Size: 16 }.Is(BufferObject) ; true
     */
    static IsInstance(Val?) => (
            IsSet(Val)
            IsObject(Val) &&
            HasProp(Val, "Ptr") &&
            HasProp(Val, "Size"))
    
    /**
     * Determines whether the given class is considered a subtype of
     * `BufferObject`.
     * 
     * @param   {Class}  T  any class
     * @returns {Boolean}
     * @example
     * ; true (every buffer is a BufferObject)
     * BufferObject.CanCastFrom(Buffer)
     */
    static CanCastFrom(T) => (super.CanCastFrom(T) || Buffer.CanCastFrom(T))
}

;@endregion
;-------------------------------------------------------------------------------
;@region Record

/**
 * A `Record<K, V>` is an object with properties of type `K` and values `V`.
 * 
 * @example
 * Permissions := Type.Enum("Admin", "User", "Guest")
 * PermissionsMap := Record(Permissions, String)
 * 
 * Obj := {
 *     Admin: "just do what you want lol",
 *     User: "okay, you're allowed in",
 *     Guest: "fine. but don't touch anything"
 * }
 * MsgBox(Obj.Is(PermissionsMap))
 */
class Record {
    /**
     * Creates a new record type with the given key and value type.
     * 
     * @param   {Any}  KeyType    key type
     * @param   {Any}  ValueType  value type
     * @returns {Class}
     * @example
     * CatName := Type.Enum("Miffy", "Boris", "Mordred")
     * CatInfo := { Age: Number, Breed: String }
     * 
     * Cats := {
     *    Miffy:   { Age: 10, Breed: "Persian "},
     *    Boris:   { Age: 5,  Breed: "Maine Coon" },
     *    Mordred: { Age: 16, Breed: "British Shorthair" }
     * }
     */
    static Call(KeyType, ValueType) {
        static Define  := {}.DefineProp
        static GetProp := {}.GetOwnPropDesc

        if (!HasMethod(KeyType, "IsInstance")) {
            throw TypeError("not a valid pattern")
        }
        if (!HasMethod(ValueType, "IsInstance")) {
            throw TypeError("not a valid pattern")
        }

        Result := Class()
        Define(Result, "IsInstance", { Call: IsInstance })
        return Result

        /**
         * Determines whether the given value is considered an instance of
         * this record type. This only applies if the value is a plain object
         * (inherits directly from `Object.Prototype`).
         * 
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         * @example
         * Record(String, Integer).IsInstance({ Age: 21 })
         */
        IsInstance(this, Val?) {
            if (!IsSet(Val)) {
                return false
            }

            ; only supposed to work on plain objects, for now.
            if (ObjGetBase(Val) != Object.Prototype) {
                return false
            }

            for PropName in ObjOwnProps(Val) {
                PropDesc := GetProp(Val, PropName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    continue
                }
                PropVal := PropDesc.Value
                if (!KeyType.IsInstance(PropName)) {
                    return false
                }
                if (!ValueType.IsInstance(PropVal)) {
                    return false
                }
            }
            return true
        }
    }
}

;@endregion
