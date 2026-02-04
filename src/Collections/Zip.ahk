#Include "%A_LineFile%\..\..\Stream\Stream.ahk"
#Include "%A_LineFile%\..\..\Stream\DoubleStream.ahk"

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
ZipWith(Mapper, Left, Right) {
    GetMethod(Mapper)
    Step := Zip(Left, Right)
    return Stream.Cast(ZipWithEnumer)

    ZipWithEnumer(&Out) {
        if (Step(&L, &R)) {
            Out := Mapper(L?, R?)
            return true
        } else {
            Out := unset
            return false
        }
    }
}