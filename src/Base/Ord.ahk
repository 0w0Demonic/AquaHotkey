#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Func\Comparator.ahk"

/**
 * Provides an interface for comparing two values by order, which allows
 * precise control over sorting arrays and other collections.
 * 
 * In general, two values can be ordered by using `A.Compare(B)`.
 * This is done with so-called "comparators".
 * 
 * ---
 * 
 * **Comparator Functions**:
 * 
 * A function is considered a comparator, if it...
 * 
 * 1. takes two parameters `A` and `B` of the same type;
 * 2. returns an integer that specifies the order of the two values:
 *    - `x < 0`, if `A < B`;
 *    - `x == 0`, if `A == B`;
 *    - `x > 0`, if `A > B`.
 * 
 * Primitive types are provided a standard comparator function.
 * 
 * ---
 * 
 * **<MyClass>.Compare()**:
 * 
 * Allows two values to be compared by their natural ordering. Depending on
 * the calling class (e.g. `Number.Compare()`), input values are type-checked
 * to ensure a value `is <MyClass>`.
 * 
 * ---
 * 
 * **How to Implement**:
 * 
 * - Create a method with the signature `Compare(Other)`
 * - `Other` should **always** be the same type or subtype, without any coercion
 *   (e.g. converting a numeric string into a number).
 * - Return an integer based on the ordering of the two values.
 * - It's **strongly recommended** that if `A.Compare(B) == 0`, then `A.Eq(B)`.
 * 
 * ---
 * 
 * @example
 * ; << easy array sorting >>
 * ; result: [1.98, 23, 123, 3455]
 * Array(123, 23, 1.98, 3455).Sort(Number.Compare)
 * 
 * ; << using `static Compare(A, B)` >>
 * Number.Compare(-1, 2) ; -1
 * Object.Compare(Object) ; Error! Type "Class" is not comparable.
 * 
 * ; << `static Compare()` does type checking >>
 * Array.Compare(1, 2) ; TypeError! Expected an Array.
 * 
 * ; retrieve the comparator function
 * ArrCompare := Array.Compare
 * 
 * @module  <Base/Ord>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Ord extends AquaHotkey
{
    ;@region Any
    class Any {
        /**
         * Unsupported `.Compare()` method.
         * 
         * @param   {Any}  Other  any value
         * @returns {Integer}
         */
        Compare(Other) {
            throw PropertyError("Not applicable for this type",, Type(this))
        }

        /**
         * Determines whether this value has a natural ordering greater than
         * the other value.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * ([1, 2]).Gt([1, 1]) ; true
         */
        Gt(Other) => (this.Compare(Other) > 0)

        /**
         * Determines whether this value has a natural ordering greater than
         * or equal to the other value.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * "foo".Ge("foo") ; true
         */
        Ge(Other) => (this.Compare(Other) >= 0)

        /**
         * Determines whether this value has a natural ordering equal to
         * the other value. Unlike `.Eq()`, this method does NOT check actual
         * object equality.
         * 
         * It's strongly recommended that if `A.Eq(B)`, then also `A.OrdEq(B)`.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * (123).OrdEq(123) ; true
         */
        OrdEq(Other) => (this.Compare(Other) == 0)

        /**
         * Determines whether this value has a natural ordering that is not equal
         * to the other value, i.e. whether the value is greater or less than the
         * other.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * (123).OrdNe(42) ; true
         */
        OrdNe(Other) => (this.Compare(Other) != 0)

        /**
         * Determines whether this value has a natural ordering less than or equal
         * to the other value.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * (123).Le(123) ; true
         */
        Le(Other) => (this.Compare(Other) <= 0)

        /**
         * Determines whether this value has a natural ordering less than the
         * other value.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * (123).Lt(42) ; false
         */
        Lt(Other) => (this.Compare(Other) < 0)
    }
    ;@endregion

    ;@region Number
    class Number {
        /**
         * Compares this number with another number. Numeric strings are not
         * accepted by this method.
         * 
         * @example
         * (123).Compare(23.8723) ; 1
         * 
         * @param   {Number}  Other  any number
         * @returns {Integer}
         */
        Compare(Other) {
            if (!(Other is Number)) {
                throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                                Type(Other))
            }
            return (this > Other) - (Other > this)
        }
    }
    ;@endregion

    ;@region String
    class String {
        /**
         * Compares this string with another string via case-insensitive
         * string comparison.
         * 
         * @example
         * "foo".Compare("bar") ; 1
         * 
         * @param   {String}  Other  any string
         * @returns {Integer}
         */
        Compare(Other) {
            if (!(Other is String)) {
                throw TypeError("Expected a String",, Type(Other))
            }
            return StrCompare(this, Other)
        }
    }
    ;@endregion

    ;@region Array
    class Array {
        /**
         * Compares this array with another array. This is done by comparing its
         * elements.
         * 
         * @param   {Array}  Other  any array
         * @returns {Integer}
         * @example
         * ([1, 2, 3]).Compare([1, 2, 4]) ; -1
         */
        Compare(Other) {
            if (!(Other is Array)) {
                throw TypeError("Expected an Array",, Type(Other))
            }
            ThisEnumer := this.__Enum(1)
            OtherEnumer := Other.__Enum(1)

            Loop {
                AHasElements := !!ThisEnumer(&A)
                BHasElements := !!OtherEnumer(&B)
                if (AHasElements != BHasElements) {
                    ; the array with more elements is considered larger
                    return AHasElements - BHasElements
                }
                Result := A.Compare(B)
                if (Result) {
                    return Result
                }
            }
        }
    }
    ;@endregion

    ;@region Class
    class Class {
        /**
         * Returns a type-checked comparison function.
         * 
         * @returns {Func}
         * @example
         * MyArray.Sort(String.Compare)
         */
        Compare => Comparator(ObjBindMethod(this, "Compare"))

        /**
         * Compares two values by order. This method is type-checked, meaning
         * that both inputs are assured to be instances of the calling class.
         * 
         * @param   {Any}  A  first value
         * @param   {Any}  B  second value
         * @returns {Integer}
         * @example
         * String.Compare("foo", "bar")       ; 4
         * String.Compare([1, 2], Buffer(16)) ; TypeError!
         */
        Compare(A, B) {
            if ((A is this) && (B is this)) {
                return A.Compare(B)
            }
            throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                            Type(A) . ", " . Type(B))
        }
    }
    ;@endregion
}