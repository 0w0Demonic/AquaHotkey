#Requires AutoHotkey >=2.0.5
#Include "%A_LineFile%\..\..\AquaHotkey.ahk"

/**
 * A wrapper for the `SysIpAddress32` control used for selecting IPv4 addresses,
 * directly integrated as `GUI.IPv4` class. This class is automatically added
 * as static nested class to the `Gui` type.
 * 
 * ```
 * class Gui
 *         |- AddIPv4(Opt := "", Addr?)
 *         `- class IPv4 extends Gui.Custom
 *                     |- Address[Octet?] { get; set; }
 *                     |- Clear()
 *                     |- IsBlank
 *                     |- Focus(Index)
 *                     |- SetRange(Index, Lo := 0, Hi := 255)
 *                     `- OnEvent(EventName, Callback, AddRemove?)
 * ```
 */
class Gui_IPv4 extends AquaHotkey {
class Gui {
    /**
     * Adds an IPv4 control to the GUI.
     * 
     * @param   {String?}         Opt   additional GUI options
     * @param   {String?/Array?}  Addr  initial IPv4 address
     */
    AddIPv4(Opt := "", Addr?) {
        Ctl := this.AddCustom("ClassSysIPAddress32 r1 " . Opt)
        ObjSetBase(Ctl, Gui.IPv4.Prototype)
        (IsSet(Addr) && Ctl.Address := Addr)
        return Ctl
    }

    class IPv4 extends Gui.Custom {
        /**
         * Gets or sets the IPv4 address of the control.
         * 
         * This property allows reading and modifying the IPv4 address
         * as either:
         * - A full string (e.g., `"192.168.0.1"`)
         * - A segmented array of four octets (e.g., `[192, 168, 0, 1]`)
         * - A specific octet via indexed access (`Ctl.Address[1]` -> `192`)
         * 
         * When setting the address:
         * - Strings must be valid IPv4 addresses.
         * - Arrays must contain exactly four integers (0-255).
         * - Individual octets must be in the valid range.
         * @example
         * 
         * MsgBox(Ctl.Address)         ; "192.168.0.1"
         * MsgBox(Ctl.Address[1])      ; 192
         * 
         * Ctl.Address[1] := 78        ; updates first octet
         * Ctl.Address := "8.8.8.8"    ; assigns a new address
         * Ctl.Address := [8, 8, 8, 8] ; alternative array syntax 
         */
        Address[Octet?] {
            get {
                static IPM_GETADDRESS := 0x0400 + 102

                AddrWord := Buffer(4)
                SendMessage(IPM_GETADDRESS, 0, AddrWord, this)
                if (!IsSet(Octet)) {
                    return Format("{}.{}.{}.{}",
                            NumGet(AddrWord, 3, "UChar"),
                            NumGet(AddrWord, 2, "UChar"),
                            NumGet(AddrWord, 1, "UChar"),
                            NumGet(AddrWord, 0, "UChar"))
                }
                if (!IsInteger(Octet)) {
                    throw TypeError("Expected an Integer",, Type(Octet))
                }
                if ((Octet < 1) || (Octet > 4)) {
                    throw ValueError("Expected value between 1 and 4",, Octet)
                }
                return NumGet(AddrWord, 4 - Octet, "UChar")
            }

            set {
                static IPM_SETADDRESS := 0x0400 + 101
                static IPM_GETADDRESS := 0x0400 + 102

                if (IsSet(Octet)) {
                    if (!IsInteger(value) || (value < 0) || (value > 255)) {
                        throw ValueError("Invalid octet value",, value)
                    }
                    AddrWord := Buffer(4)
                    SendMessage(IPM_GETADDRESS, 0, AddrWord, this)
                    NumPut("UChar", value, AddrWord, 4 - Octet)
                    IPAddr := NumGet(AddrWord, 0, "UInt")
                    SendMessage(IPM_SETADDRESS, 0, IPAddr, this)
                    return value
                }

                if (value is String) {
                    value := StrSplit(value, ".")
                }
                if (!(value is Array)) {
                    throw TypeError("Expected an Array",, Type(value))
                }
                if (value.Length != 4) {
                    throw ValueError("invalid IPv4 address")
                }

                IPAddr := 0
                for Byte in value {
                    if (!IsInteger(Byte)) {
                        throw TypeError("Expected an Integer",, Type(Byte))
                    }
                    if ((Byte < 0) || (Byte > 255)) {
                        throw ValueError("Expected (0 <= Byte <= 255)",, Byte)
                    }

                    IPAddr <<= 8
                    IPAddr += Byte
                }
                SendMessage(IPM_SETADDRESS, 0, IPAddr, this)
            }
        }

        /**
         * Clears the contents of the IP address control.
         */
        Clear() {
            static IPM_CLEARADDRESS := 0x0400 + 100
            SendMessage(IPM_CLEARADDRESS, 0, 0, this)
        }

        /**
         * Determines whether all fields in the IP address control are blank.
         * 
         * @return  {Boolean}
         */
        IsBlank {
            get {
                static IPM_ISBLANK := 0x0400 + 105
                return !!SendMessage(IPM_ISBLANK, 0, 0, this)
            }
        }

        /**
         * Sets the keyboard focus to the specified field in the IP address
         * control. All of the text in that field will be selected.
         * 
         * @param   {Integer}  Index  index of the field to set
         */
        Focus(Index) {
            static IPM_SETFOCUS := 0x0400 + 104
            if (!IsInteger(Index) || (Index < 1) || (Index > 4)) {
                throw ValueError("invalid index")
            }
            SendMessage(IPM_SETFOCUS, Index - 1, 0, this)
        }

        /**
         * Sets the valid range for the specified field in the IP address
         * control.
         * 
         * @param  {Integer}  Index  index of the field to set (1-based)
         * @param  {Integer}  Lo     lower limit of the range
         * @param  {Integer}  Hi     upper limit of the range
         */
        SetRange(Index, Lo := 0, Hi := 255) {
            static IPM_SETRANGE := 0x0400 + 103
            if ((Lo < 0) || (Lo > 255) || (Hi < 0) || (Hi > 255)) {
                throw ValueError("invalid range",, Lo . " - " . Hi)
            }
            lParam := Lo | (Hi << 8)
            SendMessage(IPM_SETRANGE, Index - 1, lParam, this)
        }

        /**
         * Registers a callback function to be called when an event is raised.
         * 
         * @example
         * 
         * Focus(IPv4) { ... }
         * LoseFocus(IPv4) { ... }
         * Change(IPv4) { ... }
         * FieldChange(IPv4, lParam) { ... }
         * 
         * @param   {String}    EventName  name of the event
         * @param   {Func}      Callback   the function to call
         * @param   {Integer?}  AddRemove  add or remove the callback
         */
        OnEvent(EventName, Callback, AddRemove?) {
            static SupportedEvents := Map(
                "Focus",     0x0100,
                "LoseFocus", 0x0200,
                "Change",    0x0300)
            
            if (!(EventName is Primitive)) {
                throw TypeError("invalid event name",, Type(EventName))
            }
            if (EventName = "FieldChange") {
                return super.OnNotify(-860, Callback, AddRemove?)
            }
            if (!SupportedEvents.Has(EventName)) {
                throw ValueError("unsupported event",, EventName)
            }
            NotifyCode := SupportedEvents[EventName]
            return super.OnCommand(NotifyCode, Callback, AddRemove?)
        }
    }
} ; class Gui
} ; class Gui_IPv4
