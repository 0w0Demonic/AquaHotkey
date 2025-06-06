/**
 * AquaHotkey - Control.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Controls.ahk
 * 
 * **Overview**:
 * 
 * The `Control` class provides an object-oriented interface for interacting
 * with GUI controls in AutoHotkey. It serves as an abstraction over
 * control-related functions such as `ControlClick`, `ControlGetText`,
 * `ControlSetText`, and others. This class encapsulates these operations into
 * a class and focuses on code readability and conciseness.
 *
 * ---
 *
 * @example
 * 
 * EditCtl      := Control("Edit1", "ahk_exe notepad.exe")
 * EditCtl.Text := "Hello, world!"
 */
class Control {
    /**
     * Constructs a new `Control` from the given control parameter, followed
     * by WinTitle parameters.
     * 
     * @param   {Any}      Value         GUI control parameter
     * @param   {Any?}     WinTitle      window title
     * @param   {String?}  WinText       window text
     * @param   {Any?}     ExcludeTitle  excluded window title
     * @param   {String?}  ExcludeText   excluded window text
     * @return  {Control}
     */
    __New(Value?, WinTitle?, WinText?, ExcludeTitle?, ExcludeText?) {
        this.Value        := (Value        ?? "")
        this.WinTitle     := (WinTitle     ?? "")
        this.WinText      := (WinText      ?? "")
        this.ExcludeTitle := (ExcludeTitle ?? "")
        this.ExcludeText  := (ExcludeText  ?? "")
    }
    
    /**
     * Enumerates the control and WinTitle parameters of the `Control` object.
     * 
     * @param   {Integer}  n  parameter length of the for-loop
     * @return  {Enumerator}
     */
    __Enum(n) {
        return Array(this.Value,
                     this.WinTitle, this.WinText,
                     this.ExcludeTitle, this.ExcludeTitle).__Enum(n)
    }

    /**
     * Adds the specified string as new entry at the bottom of a ListBox or
     * ComboBox.
     * 
     * @param   {String}  Str  the string to add
     * @return  {this}
     */
    AddItem(Str) {
        ControlAddItem(Str, this*)
        return this
    }

    /**
     * Deletes the specified entry number from a ListBox or ComboBox.
     * 
     * @param   {Integer}  n  index of the item to delete
     * @return  {this}
     */
    DeleteItem(n) {
        ControlDeleteItem(n, this*)
        return this
    }

    /**
     * Returns the entry number of a ListBox or ComboBox that is a complete
     * match for the specified string `Str`.
     * 
     * @param   {String}  Str  the string to find
     * @return  {Integer}
     */
    FindItem(Str) => ControlFindItem(Str, this*)

    /**
     * Gets the index of the currently selected entry or tab in a ListBox,
     * ComboBox or Tab control.
     * 
     * @return  {Integer}
     * 
     * ---
     * 
     * Sets the index of the currently selected entry or tab in a ListBox,
     * ComboBox or Tab control.
     * 
     * @param   {Integer}  Value  the index to choose
     * @return  {Integer}
     */
    Index {
        Get => ControlGetIndex(this*)
        Set {
            ControlChooseIndex(Value, this*)
            return Value
        }
    }

    /**
     * Sets the index of the currently selected entry or tab in a ListBox,
     * ComboBox or Tab control.
     * 
     * @param   {Integer}  Value  the index to choose
     * @return  {this}
     */
    ChooseIndex(Value) {
        ControlChooseIndex(Value, this*)
        return this
    }

    /**
     * Returns the name of the currently selected entry in the ListBox or
     * ComboBox.
     * 
     * @return  {String}
     * 
     * ---
     * 
     * Chooses the first entry in the ListBox or ComboBox which matches the
     * given string `Value`.
     * 
     * @param   {String}  Value  the string to choose
     * @return  {String}
     */
    Choice {
        Get => ControlGetChoice(this*)
        Set {
            ControlChooseString(Value, this*)
            return Value
        }
    }

    /**
     * Chooses the first entry which matches the given string `Str`.
     * 
     * @param   {String}  Str  the string to choose
     * @return  {this}
     */
    ChooseString(Str) {
        ControlChooseString(Str, this*)
        return this
    }

    /**
     * Sends a mouse event to the specified control.
     * 
     * @param   {String}   Button   name of the button to press
     * @param   {Integer}  n        number of times to click or turn mouse wheel
     * @param   {String}   Options  additional options (see AHK docs)
     * @return  {this}
     */
    Click(Button?, n?, Options?) {
        ControlClick(this.Value, this.WinTitle, this.WinText, Button,
                     n?, Options?, this.ExcludeTitle, this.ExcludeText)
        return this
    }

    /**
     * Sets input focus to the control.
     * 
     * @return  {this}
     */
    Focus() {
        ControlFocus(this*)
        return this
    }

    /**
     * Returns the ClassNN (class name and sequence number) of the control.
     * 
     * @return  {String}
     */
    ClassNN => ControlGetClassNN(this*)

    /**
     * Returns whether the control is current enabled.
     * 
     * @return  {Boolean}
     * 
     * ---
     * 
     * Enables or disables the control.
     * 
     * @param   {Boolean}  Value  the new setting
     * @return  {Boolean}
     */
    Enabled {
        Get => ControlGetEnabled(this*)
        Set {
            ControlSetEnabled(Value, this*)
            return !!Value
        }
    }

    /**
     * Enables or disables the control.
     * 
     * @param   {Integer}  Value  the new setting
     * @return  {this}
     */
    Enable(Value) {
        ControlSetEnabled(Value, this*)
        return this
    }

    /**
     * Retrieves the control of the target window that has keyboard focus. If
     * none, this method returns `false`.
     * 
     * @param   {Any?}     WinTitle      window title
     * @param   {String?}  WinText       window text
     * @param   {Any?}     ExcludeTitle  excluded window title
     * @param   {String?}  ExcludeText   excluded window text
     * @return  {Control}
     */
    static Focus(WinTitle?, WinText?, ExcludeTitle?, ExcludeText?) {
        Hwnd := ControlGetFocus(WinTitle?, WinText?,
                                ExcludeTitle?, ExcludeText?)
        if (Hwnd) {
            return Control(Hwnd, WinTitle?, WinText?,
                                 ExcludeTitle?, ExcludeText?)
        }
        return false
    }

    /**
     * Returns the HWND of the control.
     * 
     * @return  {Integer}
     */
    Hwnd => ControlGetHwnd(this*)

    /**
     * Returns an array of all items from a ListBox, ComboBox or DropDownList.
     * 
     * @return  {Array}
     */
    Items => ControlGetItems(this*)

    /**
     * Returns positional information of the control in the form of an object
     * with properties `x`, `y`, `Width` and `Height`.
     * 
     * @return  {Object}
     */
    Pos {
        Get {
            ControlGetPos(&X, &Y, &Width, &Height, this*)
            return {
                X: X,
                Y: Y,
                Width: Width,
                Height: Height,
            }
        }
    }

    /**
     * Gets the style of the control.
     * 
     * @return  {Integer}
     * 
     * ---
     * 
     * Changes the style of the control.
     * 
     * @param   {Integer/String}  Value  new settings
     * @return  {Integer}
     */
    Style {
        Get => ControlGetStyle(this*)
        Set {
            ControlSetStyle(Value, this*)
            return Value
        }
    }


    /**
     * Changes the style of the control.
     * 
     * @param   {Integer/String}  Value  new settings
     * @return  {this}
     */
    SetStyle(Value) {
        ControlSetStyle(Value, this*)
        return this
    }

    /**
     * Gets the extended style of the control.
     * 
     * @return  {Integer}
     * 
     * ---
     * 
     * Changes the extended style of the control.
     * 
     * @param   {Integer/String}  Value  new settings
     * @return  {Integer/String}
     */
    ExStyle {
        Get => ControlGetExStyle(this*)
        Set {
            ControlSetExStyle(Value, this*)
        }
    }

    /**
     * Changes the extended style of the control.
     * 
     * @param   {Integer/String}  Value  new settings
     * @return  {this}
     */
    SetExStyle(Value) {
        ControlSetExStyle(Value, this*)
        return this
    }

    /**
     * Retrieves the text from the control.
     * 
     * @return  {String}
     * 
     * ---
     * 
     * Changes the text of the control.
     * 
     * @param   {String}  Value  the new text of the control
     * @return  {String}
     */
    Text {
        Get => ControlGetText(this*)
        Set {
            ControlSetText(Value, this*)
            return Value
        }
    }

    /**
     * Changes the text of the control.
     * 
     * @param   {String}  Value  the new text of the control
     * @return  {this}
     */
    SetText(Value) {
        ControlSetText(Value, this*)
        return this
    }

    /**
     * Returns `true`, if the control is currently visible.
     * 
     * @return  {Boolean}
     * 
     * ---
     * 
     * Shows or hides the control.
     * 
     * @param   {Boolean}  Value  visibility of the control
     * @return  {Boolean}
     */
    Visible {
        Get => ControlGetVisible(this*)
        Set {
            if (Value) {
                ControlShow(this*)
            } else {
                ControlHide(this*)
            }
            return !!Value
        }
    }

    /**
     * Shows or hides the control.
     * 
     * @param   {Integer}  Value  visibility of the control
     * @return  {this}
     */
    SetVisible(Value) {
        switch (Value) {
            case 1: ControlShow(this*)
            case 0: ControlHide(this*)
            case -1:
                if (ControlGetVisible(this*)) {
                    ControlHide(this*)
                } else {
                    ControlShow(this*)
                }
            default:
                throw ValueError("invalid argument")
        }
        return this
    }

    /**
     * Returns `true`, if the checkbox or radio button is checked.
     * 
     * @return  {Boolean}
     * 
     * ---
     * 
     * Checks or unchecks the checkbox or radio button.
     * 
     * @param   {Boolean}  Value  new setting of this control
     * @return  {Boolean}
     */
    Checked {
        Get => ControlGetChecked(this*)
        Set {
            ControlSetChecked(Value, this*)
            return !!Value
        }
    }

    /**
     * Checks or unchecks the checkbox or radio button.
     * 
     * @param   {Integer}  Value  new setting
     * @return  {this}
     */
    Check(Value) {
        ControlSetChecked(Value, this*)
        return this
    }

    /**
     * Shows the drop-down list of the ComboBox control.
     * 
     * @return  {this}
     */
    ShowDropDown() {
        ControlShowDropDown(this*)
        return this
    }

    /**
     * Hides the drop-down list of the ComboBox control.
     * 
     * @return  {this}   
     */
    HideDropDown() {
        ControlHideDropDown(this*)
        return this
    }

    /**
     * Moves the control to the specified position.
     * 
     * @param   {Integer}  x       x-coordinate of the upper left corner
     * @param   {Integer}  y       y-coordinate of the upper left corner
     * @param   {Integer}  Width   width of the control
     * @param   {Integer}  Height  height of the control
     * @return  {this}
     */
    Move(x?, y?, Width?, Height?) {
        ControlMove(x?, y?, Width?, Height?, this*)
        return this
    }

    /**
     * Sends simulated keystrokes or text to the control.
     * 
     * @param   {String}  Keys  the keys to send
     * @return  {this}
     */
    Send(Keys) {
        ControlSend(Keys, this*)
        return this
    }

    /**
     * Sends text to the control without translating special keys.
     * 
     * @param   {String}  Keys  the text to send
     * @return  {this}
     */
    SendText(Keys) {
        ControlSendText(Keys, this*)
        return this
    }

    /**
     * Returns the current column number of the caret in the edit control.
     * 
     * @return  {Integer}
     */
    CurrentCol => EditGetCurrentCol(this*)

    /**
     * Returns the current line number of the caret in the edit control.
     * 
     * @return  {Integer}
     */
    CurrentLine => EditGetCurrentLine(this*)

    /**
     * Returns the contents of the specified line in the edit control.
     * 
     * @param   {Integer}  n  line number to retrieve
     * @return  {String}
     */
    Line[n] => EditGetLine(n, this*)

    /**
     * Returns the number of lines present in the edit control.
     * 
     * @return  {Integer}
     */
    LineCount => EditGetLineCount(this*)

    /**
     * Returns the currently selected text in the edit control.
     * 
     * @return  {String}
     */
    SelectedText => EditGetSelectedText(this*)

    /**
     * Pastes the given string `Str` at the caret of the edit control.
     * 
     * @param   {String}  Str  the string to paste
     * @return  {this}
     */
    Paste(Str) {
        EditPaste(Str, this*)
        return this
    }

    /**
     * Sends a message to the control and waits for acknowledgement.
     * 
     * @param   {Integer}           MsgNumber  the message number to send
     * @param   {Integer?/Buffer?}  wParam     first component of the message
     * @param   {Integer?/Buffer?}  lParam     second component of the message
     * @param   {Integer?}          Timeout    timeout in milliseconds
     * @return  {Integer}
     */
    SendMessage(MsgNumber, wParam?, lParam?, Timeout?) {
        return SendMessage(MsgNumber, wParam?, lParam?, this.Value,
                this.WinTitle, this.WinText, this.ExcludeTitle,
                this.ExcludeText, Timeout?)
    }

    /**
     * Places a message in the message queue of the control.
     * 
     * @param   {Integer}           MsgNumber  the message number to send
     * @param   {Integer?/Buffer?}  wParam     first component of the message
     * @param   {Integer?/Buffer?}  lParam     second component of the message
     * @return  {this}
     */
    PostMessage(MsgNumber, wParam?, lParam?) {
        PostMessage(MsgNumber, wParam?, lParam?, this.Value,
                    this.WinTitle, this.WinText,
                    this.ExcludeTitle, this.ExcludeText)
        return this
    }
}
