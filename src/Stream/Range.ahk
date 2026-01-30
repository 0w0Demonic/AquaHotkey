#Include "%A_LineFile%\..\..\Func\Cast.ahk"

/**
 * Returns a {@link Stream} containing an arithmetic progression of numbers
 * between `Start` and `End`, inclusive, optionally in increments of `Step`.
 * 
 * @module  <Stream/Range>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * 
 * @param   {Number}   From  start of the sequence
 * @param   {Number?}  To    end of the sequence
 * @param   {Number?}  Step  interval between elements
 * @returns {Stream}
 * @see {@link Stream}
 * @example
 * Range(10)      ; <1, 2, 3, 4, 5, 6, 7, 8, 9, 10>
 * Range(4, 7)    ; <4, 5, 6, 7>
 * Range(5, 3)    ; <5, 4, 3>
 * Range(3, 8, 2) ; <3, 5, 7>
 */
Range(Start, End?, Step := 1) {
    if (!IsSet(End)) {
        End := Start
        Start := 1
    }
    if (!IsNumber(Start) || !IsNumber(End) || !IsNumber(Step)) {
        throw TypeError("Expected a Number",,
                        Type(Start) . " " . Type(End) . " " . Type(Step))
    }
    if (Step == 0) {
        throw ValueError("Step cannot be 0",, Step)
    }

    ; avoid going in the "wrong direction"
    if (Start > End && Step > 0 || Start < End && Step < 0) {
        Step *= -1
    }
    return Stream.Cast((Step > 0) ? RangeUp : RangeDown)

    RangeUp(&OutValue) {
        OutValue := Start
        Start += Step
        return (OutValue <= End)
    }
    RangeDown(&OutValue) {
        OutValue := Start
        Start += Step
        return (OutValue >= End)
    }
}
