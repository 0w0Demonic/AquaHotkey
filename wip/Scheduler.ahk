#Requires AutoHotkey >=v2
#Include <AquaHotkey>

class AquaHotkey_Scheduler extends AquaHotkey {
    class Func {
        Schedule(Opt) {
            ;...
            SetTimer(-300, this)
        }
    }
}

With(Args*) {
    if (Args.Length < 2) {
        throw ValueError("invalid param count",, Args.Length)
    }
    Callback := Args.Pop()
    GetMethod(Callback)
    Callback(Args*)
}

class Schedule {
    static Call(Opt, Callback) {
        GetMethod(Callback)
    }

    Every(Expression) {
        if (!(Expression is String)) {
            throw TypeError("Expected a String",, Type(Expression))
        }
        if (!RegExMatch(Expression, "^(\d++)(\w)$", &Match)) {
            throw ValueError("invalid expression",, Expression)
        }
        ; TODO replace this with a map or something
        Unit := Match[2]
        switch (StrLower(Unit)) {
            case "s":
                ; ...
            default:
                throw ValueError("invalid unit",, Unit)
        }
    }
}

/**
 * 
 */
class Scheduler {
    /**
     * 
     * @param   {String}  Str  the cron expression
     * @returns {Scheduler}
     */
    static FromCronExpression(Str) {
        Str.AssertType(String)
    }

    /**
     * @constructor
     * @param   {Object}  Options  the schedule to be used
     */
    __New(Options) {
        if (!IsObject(Options)) {
            throw TypeError("Expected an Object",, Type(Options))
        }
    }
}