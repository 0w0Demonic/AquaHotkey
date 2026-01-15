#Include <AquaHotkey\src\Func\Cast>

/**
 * A zero-parameter function whose value is computed once by retrieving a value
 * from a {@link Supplier}, and then internally caching its result.
 * 
 * Supplier and mapper functions used on the Lazy type are assumed to be pure,
 * i.e. the same input always returns the same output value without any side
 * effects.
 * 
 * @module  <Func/Lazy>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * LoadConfig := Lazy(() => FileRead("myFile"))
 * 
 * LoadConfig() ; (file contents)
 * LoadConfig() ; (same file contents, but cached)
 */
class Lazy extends Func {
    /**
     * Creates a new Lazy function. The first time on which the Lazy is called,
     * it retrieves its value by calling `Supplier(Args*)`.
     * 
     * ```ahk
     * Supplier(Args: Any*) => Any
     * ```
     * 
     * @param   {Func}  Supplier  the function to be called
     * @param   {Any*}  Args      zero or more arguments
     * @returns {Lazy}
     * @example
     * ; when called for the first time, calls `Random(1, 6)`
     * Dice := Lazy(Random, 1, 6) ; alternatively: Lazy(() => Random(1, 6))
     * 
     * Dice() ; 2 (random)
     * Dice() ; 2 (cached value)
     * 
     * @example
     * ; read the contents of a file lazily
     * LoadConfig := Lazy(() => FileRead("myFile"))
     * 
     * ; Note: if you're dealing with huge strings, it's a good idea to wrap
     * ; them into a `VarRef` or an object to avoid needless copying.
     * LoadConfig := Lazy(() => { Value: FileRead("myFile") })
     */
    static Call(Supplier, Args*) {
        GetMethod(Supplier)
        Value := unset
        return this.Cast(Lazy)

        Lazy() {
            if (!IsSet(Value)) {
                Value := Supplier(Args*)
            }
            return Value
        }
    }

    /**
     * Maps the value of this Lazy function by applying the given `Mapper`
     * function.
     * 
     * ```ahk
     * Mapper(Value: Any, Args: Any*) => Any
     * ```
     * 
     * @param   {Func}  Mapper  the mapper function
     * @param   {Any*}  Args    zero or more arguments
     * @returns {Any}
     * @example
     * L := Lazy(() => "value").Map((Str) {
     *     Sleep(2000) ; some expensive operation
     *     return Str
     * })
     * 
     * L() ; returns "value" after 2s
     * L() ; returns "value" immediately
     */
    Map(Mapper, Args*) {
        return this.Cast(Mapped)
        Mapped(&Value) {
            if (!IsSet(Value)) {
                Value := Mapper(this, Args*)
            }
            return Value
        }
    }
}