/**
 * AquaHotkey - Window.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Other/Window.ahk
 * 
 * The `Window` class wraps around the built-in window functions and minimizes
 * boilerplate code by summarizing WinTitle parameters into an object with
 * various methods and properties.
 * 
 * @example
 * 
 * cmd := Window.Run("cmd.exe").WaitActive().Maximize()
 */
class Window {
    /**
     * Constructs a new `Window` from the given WinTitle parameters.
     * 
     * @param   {Any?}     WinTitle      window title
     * @param   {String?}  WinText       window text
     * @param   {Any?}     ExcludeTitle  excluded window title
     * @param   {String?}  ExcludeText   excluded window text
     * @return  {Window}
     */
    __New(WinTitle?, WinText?, ExcludeTitle?, ExcludeText?) {
        this.WinTitle     := (WinTitle     ?? "")
        this.WinText      := (WinText      ?? "")
        this.ExcludeTitle := (ExcludeTitle ?? "")
        this.ExcludeText  := (ExcludeText  ?? "")
    }

    /**
     * Constructs a new `Window` by running an external program `Target`.
     * 
     * @param   {String}   Target      the program to execute
     * @param   {String?}  WorkingDir  initial working directory
     * @param   {String}   Options     additional options
     * @return  {Window}
     */
    static Run(Target, WorkingDir?, Options?) {
        Run(Target, WorkingDir?, Options?, &OutputPID)
        if (!OutputPID) {
            throw ValueError("unable to run application",, Target)
        }
        return Window("ahk_pid " . OutputPID)
    }
    
    /**
     * Enumerates the WinTitle parameters of the window in a for-loop.
     * 
     * @param   {Integer}  n  parameter length of the for-loop
     * @return  {Enumerator}
     */
    __Enum(n) {
        return Array(this.WinTitle,     this.WinText,
                     this.ExcludeTitle, this.ExcludeText).__Enum(n)
    }

    /**
     * Activates the top matching window.
     * 
     * @return  {this}
     */
    Activate() {
        WinActivate(this*)
        return this
    }

    /**
     * Activates the bottom matching window.
     * 
     * @return  {this}
     */
    ActivateBottom() {
        WinActivateBottom(this*)
        return this
    }

    /**
     * Returns the HWND if the window is currently active, otherwise `false`.
     * 
     * @return  {Integer}
     */
    Active => WinActive(this*)

    /**
     * Closes the first matching window with the given number of seconds
     * to wait.
     * 
     * @param   {Number?}  SecondsToWait  number of seconds to wait
     * @return  {this}
     */
    Close(SecondsToWait?) {
        if (IsSet(SecondsToWait)) {
            if (!IsNumber(SecondsToWait)) {
                throw TypeError("Expected a Number",, SecondsToWait)
            }
            if (SecondsToWait < 0) {
                throw ValueError("SecondsToWait < 0",, SecondsToWait)
            }
        }
        WinClose(this.WinTitle,     this.WinText,
                 SecondsToWait?,
                 this.ExcludeTitle, this.ExcludeText)
        return this
    }

    /**
     * Returns the HWND if the window exists, otherwise `false`.
     * 
     * @return  {Integer}
     */
    Exists => WinExist(this*)

    /**
     * Returns the class name of the window.
     * 
     * @return  {String}
     */
    ClassName => WinGetClass(this*)

    /**
     * Returns the client position of the window in the form of an
     * object.
     * 
     * @return  {Object}
     */
    ClientPos {
        Get {
            WinGetClientPos(&X, &Y, &Width, &Height, this*)
            return {
                X: X,
                Y: Y,
                Width: Width,
                Height: Height
            }
        }
    }

    /**
     * Returns an array of names (ClassNN) for all controls of the window.
     * 
     * @return  {Array}
     */
    Controls => WinGetControls(this*)

    /**
     * Returns an array of unique ID numbers (HWND) for all controls of the
     * window.
     * 
     * @return  {Array}
     */
    ControlsHwnd => WinGetControlsHwnd(this*)

    /**
     * Returns a `Control` by the given control name (ClassNN) or its HWND.
     * 
     * @param   {Integer/String}  Ctl  name or HWND of the control
     * @return  {Control}
     */
    Control[Ctl] => Control(ControlGetHwnd(Ctl, this*))

    /**
     * Returns the number of windows that match the WinTitle parameters.
     * 
     * @return  {Integer}
     */
    Count => WinGetCount(this*)

    /**
     * Returns the unique ID (HWND) of the window.
     * 
     * @return  {Integer}
     */
    ID => WinGetID(this*)

    /**
     * Returns the unique ID (HWND) of the window.
     * 
     * @return  {Integer}
     */
    Hwnd => WinGetID(this*)

    /**
     * Returns the unique ID (HWND) of the last matching window.
     * 
     * @return  {Integer}
     */
    IDLast => WinGetIDLast(this*)

    /**
     * Returns `true` if the window is minimized.
     * 
     * @return  {Integer}
     */
    Minimized => (WinGetMinMax(this*) == -1)

    /**
     * Returns `true` if the window is maximized.
     * 
     * @return  {Integer}
     */
    Maximized => (WinGetMinMax(this*) == 1)

    /**
     * Returns the process ID (PID) of the window.
     * 
     * @return  {Integer}
     */
    PID => WinGetPID(this*)

    /**
     * Returns the position of the window in the form of an object.
     * 
     * @return  {Object}
     */
    Pos {
        Get {
            WinGetPos(&X, &Y, &Width, &Height, this*)
            return {
                X: X,
                Y: Y,
                Width: Width,
                Height: Height
            }
        }
    }

    /**
     * Returns the process name of the window.
     * 
     * @return  {String}
     */
    ProcessName => WinGetProcessName(this*)

    /**
     * Returns the process path of the window.
     * 
     * @return  {String}
     */
    ProcessPath => WinGetProcessPath(this*)

    /**
     * Gets the current style of the window.
     * 
     * @return  {Integer}
     * 
     * ---
     * 
     * Changes the style of the window.
     * 
     * @param   {Integer/String}  Value  new settings
     * @return  {Integer}
     */
    Style {
        Get => WinGetStyle(this*)
        Set {
            WinSetStyle(Value, this*)
            return Value
        }
    }

    /**
     * Changes the style of the window.
     * 
     * @param   {Integer/String}  Value  new settings
     * @return  {this}
     */
    SetStyle(Value) {
        WinSetStyle(Value, this*)
        return this
    }

    /**
     * Gets the current extended style of the window.
     * 
     * @return  {Integer}
     * 
     * ---
     * 
     * Changes the extended style of the window.
     * 
     * @param   {Integer/String}  Value  new settings
     * @return  {Integer/String}
     */
    ExStyle {
        Get => WinGetExStyle(this*)
        Set {
            WinSetExStyle(Value, this*)
            return Value
        }
    }

    /**
     * Changes the extended style of the window.
     * 
     * @param   {Integer/String}  Value  new settings
     * @return  {this}
     */
    SetExStyle(Value) {
        WinSetExStyle(Value, this*)
        return this
    }

    /**
     * Retrieves the text from the window.
     * 
     * @return  {String}
     */
    Text => WinGetText(this*)

    /**
     * Retrieves the title of this window.
     * 
     * @return  {String}
     * 
     * ---
     * 
     * Changes the title of the window.
     * 
     * @param   {String}  Value  new window title
     * @return  {String}
     */
    Title {
        Get => WinGetTitle(this*)
        Set {
            WinSetTitle(Value, this*)
            return Value
        }
    }

    /**
     * Changes the title of the window.
     * 
     * @param   {String}  Value  new window title
     * @return  {this}
     */
    SetTitle(Value) {
        WinSetTitle(Value, this*)
        return this
    }

    /**
     * Returns the transparent color in the window.
     * 
     * @return  {String}
     * 
     * ---
     * 
     * Makes all pixels of the chosen color in the window invisible.
     * 
     * @param   {String}  Value  color name or RGB value, optional transparency
     * @return  {String}
     */
    TransColor {
        Get => WinGetTransColor(this*)
        Set {
            WinSetTransColor(Value, this*)
            return Value
        }
    }

    /**
     * Makes all pixels of the chosen color in the window invisible.
     * 
     * @param   {String}  Value  color name or RGB value, optional transparency
     * @return  {this}
     */
    SetTransColor(Value) {
        WinSetTransColor(Value, this*)
        return this
    }

    /**
     * Returns the transparency setting of the window.
     * 
     * @return  {Integer}
     * 
     * ---
     * 
     * Makes the window semi-transparent.
     * 
     * @param   {Integer/String}  Value  new transparency setting
     * @return  {Integer}
     */
    Transparent {
        Get => WinGetTransparent(this*)
        Set {
            WinSetTransparent(Value, this*)
            return Value
        }
    }

    /**
     * Makes the window semi-transparent.
     * 
     * @param   {Integer/String}  Value  new transparency setting
     * @return  {this}
     */
    SetTransparent(Value) {
        WinSetTransparent(Value, this*)
        return this
    }

    /**
     * Hides the window.
     * 
     * @return  {this}
     */
    Hide() {
        WinHide(this*)
        return this
    }

    /**
     * Shows the window.
     * 
     * @return  {this}
     */
    Show() {
        WinShow(this*)
        return this
    }

    /**
     * Forces the window to close with the given max number of seconds
     * to wait.
     * 
     * @param   {Number?}  Timeout  max number of seconds to wait
     * @return  {this}
     */
    Kill(Timeout?) {
        WinKill(this.WinTitle, this.WinText,
                Timeout?,
                this.ExcludeTitle, this.ExcludeText)
        return this
    }

    /**
     * Maximizes the window.
     * 
     * @return  {this}
     */
    Maximize() {
        WinMaximize(this*)
        return this
    }

    /**
     * Minimizes the window.
     * 
     * @return  {this}
     */
    Minimize() {
        WinMinimize(this*)
        return this
    }

    /**
     * Moves the window to the specified position or size.
     * 
     * @param   {Integer?}  x       x-coordinate of the upper left corner
     * @param   {Integer?}  y       y-coordinate of the upper left corner
     * @param   {Integer?}  Width   width in pixels
     * @param   {Integer?}  Height  height in pixels
     * @return  {this}
     */
    Move(x?, y?, Width?, Height?) {
        WinMove(x?, y?, Width?, Height?, this*)
        return this
    }

    /**
     * Sends the window to the bottom of the stack.
     * 
     * @return  {this}
     */
    MoveBottom() {
        WinMoveBottom(this*)
        return this
    }

    /**
     * Sends the window to the top of the stack.
     * 
     * @return  {this}
     */
    MoveTop() {
        WinMoveTop(this*)
        return this
    }

    /**
     * Redraws the window.
     * 
     * @return  {this}
     */
    Redraw() {
        WinRedraw(this*)
        return this
    }

    /**
     * Restores the window.
     * 
     * @return  {this}
     */
    Restore() {
        WinRestore(this*)
        return this
    }
    
    /**
     * Makes the window stay on top of all other windows.
     * 
     * @param   {Integer}  Value  new setting
     * @return  {Integer}
     */
    AlwaysOnTop {
        Set {
            WinSetAlwaysOnTop(Value, this*)
            return this
        }
    }

    /**
     * Makes the window stay on top of all other windows.
     * 
     * @param   {Integer?}  Value  new setting
     * @return  {this}
     */
    SetAlwaysOnTop(Value?) {
        WinSetAlwaysOnTop(Value?, this*)
        return this
    }

    /**
     * Enables or disables the window.
     * 
     * @param   {Integer}  Value  new setting
     * @return  {Integer}
     */
    Enabled {
        Set {
            WinSetEnabled(Value, this*)
            return Value
        }
    }

    /**
     * Enables or disables the window.
     * 
     * @param   {Integer}  Value  new setting
     * @return  {this}
     */
    SetEnabled(Value) {
        WinSetEnabled(Value, this*)
        return this
    }

    /**
     * Sets the window to be the specified rectangle, ellipse or polygon.
     * 
     * @param   {String}  Value  new setting
     * @return  {String}
     */
    Region {
        Set {
            WinSetRegion(Value, this*)
            return Value
        }
    }

    /**
     * Sets the window to be the specified rectangle, ellipse or polygon.
     * 
     * @param   {Integer}  Value  new setting
     * @return  {this}
     */
    SetRegion(Value) {
        WinSetRegion(Value, this*)
        return this
    }
    
    /**
     * Waits until the window exists with the given timeout in seconds.
     * 
     * @param   {Number?}  Timeout  max number of seconds to wait
     * @return  {Window}
     */
    Wait(Timeout?) {
        Hwnd := WinWait(this.WinTitle, this.WinText,
                        Timeout?,
                        this.ExcludeTitle, this.ExcludeText)
        if (Hwnd) {
            return Window("ahk_id " . Hwnd)
        }
        return false
    }

    /**
     * Waits until the window is active with the given timeout
     * in seconds.
     * 
     * @param   {Number?}  Timeout  max number of seconds to wait
     * @return  {Window}
     */
    WaitActive(Timeout?) {
        Hwnd := WinWaitActive(this.WinTitle, this.WinText,
                              Timeout?,
                              this.ExcludeTitle, this.ExcludeText)
        if (Hwnd) {
            return Window("ahk_exe " . Hwnd)
        }
        return false
    }

    /**
     * Waits until the window is not active anymore with the given timeout in
     * seconds.
     * 
     * @param   {Number?}  Timeout  max number of seconds to wait
     * @return  {Window}
     */
    WaitNotActive(Timeout?) {
        Hwnd := WinWaitNotActive(this.WinTitle, this.WinText,
                                 Timeout?,
                                 this.ExcludeTitle, this.ExcludeText)
        if (Hwnd) {
            return Window("ahk_id " . Hwnd)
        }
        return false
    }

    /**
     * Waits until no windows matching the WinTitle parameters of the `Window`
     * can be found, with the given timeout in seconds.
     * 
     * @param   {Number?}  Timeout  max number of seconds to wait
     * @return  {Window}
     */
    WaitClose(Timeout?) {
        Hwnd := WinWaitClose(this.WinTitle, this.WinText,
                             Timeout?,
                             this.ExcludeTitle, this.ExcludeText)
        if (Hwnd) {
            return Window("ahk_exe " . Hwnd)
        }
        return false
    }

    /**
     * Retrieves the text from a standard status bar control.
     * 
     * @param   {Integer?}  Index  index of the bar to retrieve
     * @return  {String}
     */
    StatusBarText[Index?] => StatusBarGetText(Index?, this*)

    /**
     * Waits until the window's status bar contains the specified string.
     * 
     * @param   {String?}   BarText   the text to wait for
     * @param   {Number?}   Timeout   max number of seconds to wait
     * @param   {Integer?}  Index     number of the bar to retrieve
     * @param   {Integer?}  Interval  interval in milliseconds
     * @param   {Boolean}
     */
    StatusBarWait(BarText?, Timeout?, Index?, Interval?) {
        return StatusBarWait(BarText?, Timeout?, Index?,
                this.WinTitle, this.WinText,
                Interval?,
                this.ExcludeTitle, this.ExcludeText)
    }
}