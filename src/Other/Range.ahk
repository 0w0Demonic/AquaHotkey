/**
 * AquaHotkey - Range.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Other/Range.ahk
 * 
 * **Overview**:
 * 
 * Returns a stream containing an arithmetic progression of numbers between
 * `Start` and `End`, inclusive, optionally at a specified interval of `Step`
 * (otherwise `1` or `-1`).
 * @example
 * 
 * Range(10)      ; <1, 2, 3, 4, 5, 6, 7, 8, 9, 10>
 * Range(4, 7)    ; <4, 5, 6, 7>
 * Range(5, 3)    ; <5, 4, 3>
 * Range(3, 8, 2) ; <3, 5, 7>
 * 
 * @param   {Number}   From  start of the sequence
 * @param   {Number?}  To    end of the sequence
 * @param   {Number?}  Step  interval between elements
 * @return  {Stream}
 */
Range(Start, End?, Step := 1) {
    if (!IsSet(End)) {
        End := Start
        Start := 1
    }
    if (!IsSet(Step)) {
        Step := 1
    }

    Start.AssertNumber()
    End.AssertNumber()
    Step.AssertNumber()

    if (!Step) {
        Step := 1
    }
    if (Start > End && Step > 0 || Start < End && Step < 0) {
        Step *= -1
    }
    
    Count := 1
    if (Step > 0) {
        return Stream(RangeUp)
    }
    return Stream(RangeDown)

    RangeUp(&OutValue) {
        OutValue := Start
        Start += Step
        return (OutValue <= End)
    }
    RangeDown(&OutValue) {
        OutValue := Start
        Start += Step
        return (OutValue <= End)
    }
}