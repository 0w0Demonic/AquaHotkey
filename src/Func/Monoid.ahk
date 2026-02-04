#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * A monoid is a binary operation with an identity.
 * 
 * In other words:
 * - An operation that combines two values into one;
 * - One value, for which this operation does nothing.
 * 
 * This class is useful together with {@link Enumerable1#Reduce `.Reduce()`}
 * to provide a default starting value when reducing elements.
 * 
 * ---
 * 
 * For example: addition is a monoid, where `0` does nothing.
 * 
 * ```ahk
 * ; automatically takes `Product.Identity` (`0`) as initial value
 * Array(1, 2, 3, 4, 5).Reduce(Product) ; 120
 * Array().Reduce(Product) ; 1 (fallback to `1`, instead of throwing)
 * ```
 * 
 * ---
 * 
 * @module  <Func/Monoid>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * class Product extends Any {
 *     static Call(A, B) => (A * B)
 *     static Identity => 1
 * }
 * Range(5).Reduce(Product) ; 120
 */
class Monoid extends Func {
    /**
     * Determines whether the value is considered a monoid. This happens,
     * if it's a callable object that implements `Identity` as property.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * Sum.Is(Monoid) ; true
     */
    static IsInstance(Val?) {
        return IsSet(Val)
            && IsObject(Val)
            && HasMethod(Val)
            && HasProp(Val, "Identity")
    }
}

/**
 * Addition.
 */
class Sum extends Any {
    static Call(A, B) => (A + B)
    static Identity => 0
}

/**
 * Multiplication.
 */
class Product extends Any {
    static Call(A, B) => (A * B)
    static Identity => 1
}

; TODO make this more flexible
/**
 * String concatenation
 */
class Concat extends Any {
    static Call(A, B) => (A . B)
    static Identity => ""
}

/**
 * Logical AND.
 */
class BoolAnd extends Any {
    static Call(A, B) => (A && B)
    static Identity => true
}

/**
 * Logical OR.
 */
class BoolOr extends Any {
    static Call(A, B) => (A || B)
    static Identity => false
}