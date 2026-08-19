#Include "%A_LineFile%\..\..\Stream\Stream.ahk"
#Include "%A_LineFile%\..\..\Stream\DoubleStream.ahk"

; TODO
; - add `.Zip()` and `.ZipWith()` as stream methods?
; - let `.Pairwise()` be forwarded to `Zip()`?
; - cartesion product?

/**
 * Combines two enumerable object (arrays, maps, etc.) into a
 * {@link DoubleStream}. The stream stop as soon as one of the enumerables
 * has no more values.
 * 
 * @param   {Any*}  Args  one or more enumerable values
 * @returns {DoubleStream}
 */
Zip(Left, Right) {
    LeftEnumer := Stream(Left)
    RightEnumer := Stream(Right)
    return DoubleStream.Cast((&L, &R) => (LeftEnumer(&L) && RightEnumer(&R)))
}


; TODO switch order of parameters?
/**
 * Returns a {@link Stream} of elements from two enumerable combined into
 * a single value by applying the given `Mapper`.
 * 
 * ```ahk
 * Mapper(Left: Any?, Right: Any?) => Any
 * ```
 * 
 * @param   {Func}    Mapper  mapper function
 * @param   {Object}  Left    first enumerable
 * @param   {Object}  Right   second enumerable
 * @returns {Stream}
 */
ZipWith(Mapper, Left, Right) => Zip(Left, Right).Map(Mapper)

