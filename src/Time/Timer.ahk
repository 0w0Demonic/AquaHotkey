#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Func\Cast.ahk"

/**
 * Small utility that abstracts the use of timer objects and {@link SetTimer()}.
 * 
 * This feature is intended to be used together with
 * {@link AquaHotkey_Duration}.
 * 
 * @module  <Time/Scheduler>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic
 * @example
 * DoSomething(...) {
 *     ; ...
 * }
 * 
 * ; called every 10.5 seconds
 * DoSomething.ScheduleEvery((10).Seconds + (500).Milliseconds)
 * 
 * ; called once in the next 2 minutes
 * DoSomething.ScheduleAfter((2).Minutes)
 */
class Timer extends Func {
    /**
     * Schedules this function to be executed once after the given duration
     * in milliseconds.
     * 
     * @param   {Number}    DurationMs  duration in milliseconds
     * @param   {Integer?}  Priority    thread priority
     * @returns {this}
     */
    ScheduleAfter(DurationMs, Priority?) {
        if (!IsNumber(DurationMs)) {
            throw TypeError("Expected a Number",, Type(DurationMs))
        }
        if (DurationMs < 0) {
            throw ValueError("Must be > 0",, DurationMs)
        }
        SetTimer(this, -Integer(DurationMs))
        return this
    }

    /**
     * Schedules this function to be executed repeatedly at the given interval
     * in milliseconds.
     * 
     * The timer that waits before setting up repeated execution if
     * `InitialDelay` is nonzero cannot be cancelled.
     * 
     * @param   {Number}    Interval      duration in milliseconds
     * @param   {Number?}   InitialDelay  initial delay
     * @param   {Integer?}  Priority      thread priority
     */
    ScheduleEvery(Interval, InitialDelay := 0, Priority?) {
        switch {
          case (!IsNumber(Interval)):
            throw TypeError("Expected a Number",, Type(Interval))
          case (!IsNumber(InitialDelay)):
            throw TypeError("Expected a Number",, Type(InitialDelay))
          case (Interval < 0):
            throw ValueError("Must be > 0",, Interval)
          case (InitialDelay < 0):
            throw ValueError("Must be > 0",, InitialDelay)
          case (InitialDelay):
            SetTimer(Init, -Integer(InitialDelay))
          default:
            Init()
        }
        return this

        Init() => SetTimer(this, Integer(Interval))
    }

    /**
     * Disables the timer object.
     * 
     * @returns {this}
     */
    Disable() {
        SetTimer(this, 0)
        return this
    }

    /**
     * Sets the priority of the timer object.
     * 
     * @property {Integer}
     */
    Priority {
        set => SetTimer(this, unset, value)
    }
}

/**
 * Extension methods related to {@link Timer}.
 */
class AquaHotkey_Timer extends AquaHotkey {
    class Object {
        /**
         * Schedules this object to be called once after the given duration in
         * milliseconds, returning a {@link Timer} object.
         * 
         * @param   {Number}  Duration  duration in milliseconds
         * @returns {Timer}
         * @see {@link Timer#ScheduleAfter()}
         * @example
         * DoSomething.ScheduleAfter((10).Seconds)
         */
        ScheduleAfter(Duration) {
            GetMethod(this)
            return Timer(this).ScheduleAfter(Duration)
        }

        /**
         * Schedules this object to be called repeatedly at the given interval
         * in milliseconds, returning a {@link Timer} object.
         * 
         * @param   {Number}    Interval      interval in milliseconds
         * @param   {Number?}   InitialDelay  initial delay
         * @param   {Integer?}  Priority      thread priority
         * @returns {Timer}
         * @see {@link Timer#ScheduleEvery}
         * @example
         * DoSomething.ScheduleEvery((10).Seconds)
         */
        ScheduleEvery(Interval, InitialDelay?, Priority?) {
            GetMethod(this)
            return Timer(this).ScheduleEvery(Interval, InitialDelay?, Priority?)
        }
    }
}
