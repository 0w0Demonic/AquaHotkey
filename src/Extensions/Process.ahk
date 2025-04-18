/**
 * AquaHotkey - Process.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Other/Process.ahk
 * 
 * **Overview**:
 * 
 * This class aims to improve code readability of wrapping over the built-in
 * process functions.
 * 
 * @example
 * 
 * Process.List().Map(Proc => Proc.Name).JoinLine().MsgBox()
 * 
 * Process("notepad.exe").Close()
 */
class Process {
    /**
     * Constructs a new `Process` from the given process ID or process name.
     * 
     * @param   {Integer/String}  Value  process ID or process name
     * @return  {Process}
     */
    __New(Value) {
        if ((Value is String) || (Value is Integer)) {
            this.Id := Value
            return
        }
        return TypeError("invalid argument",, Type(Value))
    }

    /**
     * Returns a list of all processes.
     * 
     * @return  {Array}
     */
    static List() {
        Result := Array()
        Query := ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process")

        Result := Array()
        for Proc in Query {
            Result.Push(Process(Proc.ProcessId))
        }
        return Result
    }

    /**
     * Closes the first matching process.
     * 
     * @return  {Integer}
     */
    Close() => ProcessClose(this.Id)

    /**
     * Closes all matching processes.
     * 
     * @return  {Array}
     */
    CloseAll() {
        Arr := Array()
        while (PID := ProcessClose(this.Id)) {
            Arr.Push(PID)
        }
        return Arr
    }

    /**
     * Returns this script as `Process`.
     * 
     * @return  {Process}
     */
    static Self => Process(ProcessExist())

    /**
     * Changes the priority level of the process.
     * 
     * @param   {String}  Value  new process priority level
     * @return  {String}
     */
    Priority {
        Set {
            ProcessSetPriority(Value, this.Id)
            return Value
        }
    }

    /**
     * Changes the priority level of the process.
     * 
     * @param   {String}  Value  new process priority level
     * @return  {Integer}
     */
    SetPriority(Value) => ProcessSetPriority(Value, this.Id)
    
    /**
     * Returns the PID, if the process exists.
     * 
     * @return  {Integer}
     */
    Exists => ProcessExist(this.Id)

    /**
     * Returns the name of the process.
     * 
     * @return  {String}
     */
    Name => ProcessGetName(this.Id)

    /**
     * Returns the parent of the process.
     * 
     * @return  {Process}
     */
    Parent => Process(ProcessGetParent(this.Id))

    /**
     * Returns the path of the process.
     * 
     * @return  {String}
     */
    Path => ProcessGetPath(this.Id)

    /**
     * Waits for the process to exist, with a given timeout in seconds.
     * 
     * @param   {Number?}  Timeout  seconds to wait
     * @return  {Process}
     */
    Wait(Timeout?) {
        if (!IsSet(Timeout)) {
            return Process(ProcessWait(this.Id))
        }
        if (!IsNumber(Timeout)) {
            throw TypeError("Expected a Number",, Type(Timeout))
        }
        if (Timeout < 0) {
            throw ValueError("Timeout < 0",, Timeout)
        }
        return Process(ProcessWait(this.Id, Timeout?))
    }

    /**
     * Waits for the process to close, with a given timeout in seconds.
     * 
     * @param   {Number?}  Timeout  seconds to wait
     * @return  {Integer}
     */
    WaitClose(Timeout?) {
        if (!IsSet(Timeout)) {
            return Process(ProcessWaitClose(this.Id))
        }
        if (!IsNumber(Timeout)) {
            throw TypeError("Expected a Number",, Type(Timeout))
        }
        if (Timeout < 0) {
            throw ValueError("Timeout < 0",, Timeout)
        }
        return Process(ProcessWaitClose(this.Id, Timeout?))
    }
}
