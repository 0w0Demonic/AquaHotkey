#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO move this into base?
; TODO add `Number.InRange()` as duck type?

/**
 * Numbers and math utils.
 * 
 * @module  <Primitives/Number>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Number extends AquaHotkey {
    class Number {
        /**
         * Constants pi and e
         */
        static PI => 3.14159265358979
        static E  => 2.71828182845905
        
        /**
         * Built-in math functions.
         */
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
         * @param   {Number}  BaseN  logarithm base
         * @returns {Float}
         * @example
         * (32).Log(2) ; 5.0
         */
        Log(BaseN := 10) => (Log(this) / Log(BaseN))
    } ; class Number
} ; class AquaHotkey_Number extends AquaHotkey