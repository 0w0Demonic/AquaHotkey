#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Small DSL for specifying durations of time by accessing properties which
 * convert a number into milliseconds based on the time unit.
 * 
 * Because these time units are converted to integers, you can very easily
 * perform arithmetic with them.
 * 
 * For the sake of simplicity, one month is hard-coded to be equal to 30 days.
 * 
 * @module  <Time/Duration>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link Scheduler}
 * @example
 * Duration := (10).Seconds ; 10000
 * SetTimer(DoSomething, Duration)
 * 
 * ; 9030000
 * RemindMeIn := (2).Hours + (30).Minutes + (30).Seconds
 */
class AquaHotkey_Duration extends AquaHotkey {
    class Number {
        Millisecond  => Integer(this)
        Milliseconds => Integer(this)
        Second       => Integer(this * 1000)
        Seconds      => Integer(this * 1000)
        Minute       => Integer(this * 1000 * 60)
        Minutes      => Integer(this * 1000 * 60)
        Hour         => Integer(this * 1000 * 60 * 60)
        Hours        => Integer(this * 1000 * 60 * 60)
        Day          => Integer(this * 1000 * 60 * 60 * 24)
        Days         => Integer(this * 1000 * 60 * 60 * 24)
        Month        => Integer(this * 1000 * 60 * 60 * 24 * 30)
        Months       => Integer(this * 1000 * 60 * 60 * 24 * 30)
        Year         => Integer(this * 1000 * 60 * 60 * 24 * 30 * 12)
        Years        => Integer(this * 1000 * 60 * 60 * 24 * 30 * 12)
    }
}
