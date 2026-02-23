#Include "%A_LineFile%\..\Stream.ahk"

/**
 * Creates an unbound arithmetic progression stream, starting at `Start` and
 * increasing by `Step` indefinitely,.
 * 
 * @param   {Number?}  Start  starting value
 * @param   {Number?}  Step   interval between elements (cannot be zero)
 * @returns {Stream}
 */
Count(Start := 1, Step := 1) {
    if (!IsNumber(Start)) {
        throw TypeError("Expected a Number",, Type(Start))
    }
    if (!IsNumber(Step)) {
        throw TypeError("Expected a Number",, Type(Step))
    }
    if (Step == 0) {
        throw ValueError("Interval must not be 0")
    }

    Value := Start
    return Stream.Cast(Counter)

    Counter(&Out) {
        Out := Value
        Value += Step
        return true
    }
}
 