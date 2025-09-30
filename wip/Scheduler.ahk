#Requires AutoHotkey >=v2

class AquaHotkey_Scheduler extends AquaHotkey {
    class Func {
        Schedule(Opt) {

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
        Options.Assert(IsObject)

    }
}

class AquaHotkey_Cycle extends AquaHotkey {
    class Any {
        Cycle(Count?) => Cycle(this, Count?)
    }
}

Scheduler({
    Second: 1,
    Minute: 0,
    Hour: [12, 17],
    DayOfMonth: Ignore,
    Month: Any,
    DayOfWeek: Any,
    Year:

})

Increment() {

}

class Ignore {

}