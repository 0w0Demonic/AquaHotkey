class AquaHotkey_Number extends AquaHotkey {
/**
 * AquaHotkey - Number.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Number.ahk
 */
class Number {
    /** Constants pi and e */
    static PI => 3.14159265358979
    static E  => 2.71828182845905
    
    /** Built-in math functions. */
    Abs()     => Abs(this)
    ASin()    => ASin(this)
    ACos()    => ACos(this)
    ATan()    => ATan(this)
    Ceil()    => Ceil(this)
    Chr()     => Chr(this)
    Cos()     => Cos(this)
    Exp()     => Exp(this)
    Floor()   => Floor(this)
    Ln()      => Ln(this)
    Mod(N)    => Mod(this, N)
    Round(N?) => Round(this, N?)
    Sin()     => Sin(this)
    Sqrt()    => Sqrt(this)
    Tan()     => Tan(this)

    /**
     * Returns the logarithm base `BaseN` of this number.
     * 
     * @example
     * (32).Log(2) ; 5.0
     * 
     * @param   {Number}  BaseN  logarithm base
     * @returns {Float}
     */
    Log(BaseN := 10) => (Log(this) / Log(BaseN))

    /**
     * Asserts that this number is greater than `x`. Otherwise, a `ValueError`
     * is thrown with the error message `Msg`.
     * 
     * @example
     * (12.23).AssertGreater(5, "number is not greater than 5")
     * 
     * @param   {Number}   x    any number
     * @param   {String?}  Msg  error message
     * @returns {this}
     */
    AssertGreater(x, Msg?) {
        if (this > x) {
            return this
        }
        throw ValueError(Msg ?? "number is not greater than " . x,, this)
    }

    /**
     * Asserts that this number is greater than or equal to `x`. Otherwise, a
     * `ValueError` is thrown with the error message `Msg`.
     * 
     * @example
     * (0).AssertGreaterOrEqual(0, "number is less than 0")
     * 
     * @param   {Number}   x    any number
     * @param   {String?}  Msg  error message
     * @returns {this}
     */
    AssertGreaterOrEqual(x, Msg?) {
        if (this >= x) {
            return this
        }
        throw ValueError(Msg ?? "number is less than " . x,, this)
    }

    /**
     * Asserts that this number is less than `x`. Otherwise, a `ValueError` is
     * thrown with the error message `Msg`.
     * 
     * @example
     * (23).AssertLess(65, "number is not less than 65")
     * 
     * @param   {Number}   x    any number
     * @param   {String?}  Msg  error message
     * @returns {this}
     */
    AssertLess(x, Msg?) {
        if (this < x) {
            return this
        }
        throw ValueError(Msg ?? "number is not less than " . x,, this)
    }

    /**
     * Asserts that this number is smaller than or equal to `x`. Otherwise,
     * a `ValueError` is thrown with the error message `Msg`.
     * 
     * @example
     * (23).AssertLessOrEqual(65, "number is greater than 65")
     * 
     * @param   {Number}   x    any number
     * @param   {String?}  Msg  error message
     * @returns {this}
     */
    AssertLessOrEqual(x, Msg?) {
        if (this <= x) {
            return this
        }
        throw ValueError(Msg ?? "number is greater than " . X,, this)
    }

    /**
     * Asserts that this number lies in the inclusive range between `x` and `y`.
     * 
     * @example
     * (12).AssertInRange(1, 100, "number is not between 1-100")
     * 
     * @param   {Number}   x    lower limit
     * @param   {Number}   y    upper limit
     * @param   {String?}  Msg  error message
     * @returns {this}
     */
    AssertInRange(x, y, Msg?) {
        Hi := Max(x, y)
        Lo := Min(x, y)
        if ((this < Lo) || (this > Hi)) {
            throw ValueError(Msg ?? "number is not in range "
                                  . Lo . " - " . Hi,, this)
        }
        return this
    }
} ; class Number
} ; class AquaHotkey_Number extends AquaHotkey