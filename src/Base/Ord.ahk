#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO Comparator mixin or subtype of Func?

/**
 * Provides an interface for comparing two values by order, which allows
 * precise control over sorting arrays and other collections.
 * 
 * In general, two values can be ordered by using `A.Compare(B)`.
 * This is done with so-called "comparators". Unset values are **not**
 * supported.
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
 * Use the {@link Comparator} class for creating custom comparators that can
 * handle objects.
 * 
 * ---
 * 
 * **<MyClass>.Compare()**:
 * 
 * 
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
 * Object.Compare(Object) ; Error! Class is not comparable.
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
class AquaHotkey_Ord extends AquaHotkey {
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

    class Array {
        /**
         * Compares this array with another array. This is done by comparing its
         * elements.
         * 
         * @example
         * 
         * ; 1.Compare(1) => 0
         * ; 2.Compare(2) => 0
         * ; 3.Compare(4) => -1
         * ([1, 2, 3]).Compare([1, 2, 4]) ; -1
         * 
         * @param   {Array}  Other  any array
         * @returns {Integer}
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
            }
        }
    }

    class Any {
        /**
         * Default, unsupported compare function.
         * 
         * @param   {Any}  Other  any value
         * @throws  always
         */
        Compare(Other) {
            throw TypeError("This type is not comparable",, Type(this))
        }
    }

    class Class {
        /**
         * Returns a type-checked comparison function.
         * 
         * @example
         * NumCompare := Number.Compare
         * 
         * NumCompare(1, 2) ; -1
         * NumCompare("foo", "bar") ; Error! Expected a Number.
         * 
         * @returns {Func}
         */
        Compare => (A, B) => this.Compare(A, B)

        /**
         * Compares two values by order.
         * 
         * @param   {Any}  A  first value
         * @param   {Any}  B  second value
         * @returns {Integer}
         */
        Compare(Args*) {
            switch (Args.Length) {
            case 1:
                return super.Compare(Args[1])
            case 2:
                A := Args[1]
                B := Args[2]
                if (!(A is this)) {
                    throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                            Type(A))
                }
                if (!(B is this)) {
                    throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                            Type(B))
                }
                return A.Compare(B)
            default:
                throw ValueError("invalid param count: " . Args.Length)
            }
        }
    }
}
