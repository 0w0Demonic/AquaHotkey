#Requires AutoHotkey >=2.0.5
#Include %A_LineFile%/../../../AquaHotkey.ahk

/**
 * AquaHotkey - IPv4.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - examples/lib/IPv4.ahk
 * 
 * **Overview**:
 * 
 * An AquaHotkey extension class that adds a custom GUI control class
 * for entering IPv4 addresses (`Gui.Custom.IPv4`).
 * 
 * This control provides a segmented input fields with automatic formatting,
 * validation and events.
 * 
 * - Easily integrates with `Gui.Prototype.AddIPv4()`.
 * 
 * @example
 * 
 * g := Gui()
 * Ctl := g.AddIPv4("w250", "192.168.0.1")
 * Ctl.OnEvent("Change", ChangedCallback)
 * 
 * g.Show()
 * 
 * MsgBox(IPv4Control.Address)      ; "192.168.0.1"
 * MsgBox(IPv4Control.Address[4])   ; 1
 * IPv4.Control[1] := 76            ; new address: "76.168.0.1"
 * IPv4Control.Address := "8.8.4.4" ; new address: "8.8.4.4"
 * 
 * ; alternatively:
 * ; IPv4Control.Address := [8, 8, 4, 4]
 * 
 * @summary
 * 
 * ---
 * 
 * **Gui**:
 * - `AddAPv4(Opt := "", Addr?)`
 * 
 * ---
 * 
 * **Gui.Custom.IPv4**:
 * - `OnEditChange(Callback, AddRemove?)`
 * - `OnFieldChange(Callback, AddRemove?)`
 * - `Address[Octet?] { get; set; }`
 * - `Clear()`
 * - `IsBlank { get; }`
 * - `Focus(Index)`
 * - `SetIndex(Index, Lo := 0, Hi := 255)`
 * 
 * ---
 * 
 * @extends AquaHotkey
 */
class IPv4Extension extends AquaHotkey {
    class Gui {
        /**
         * Adds an IPv4 control to the GUI.
         * 
         * @param   {String?}         Opt   additional GUI options
         * @param   {String?/Array?}  Addr  initial IPv4 address
         */
        AddIPv4(Opt := "", Addr?) {
            Ctl := this.Add("Custom", "ClassSysIPAddress32 r1 " . Opt)
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
                                NumGet(AddrWord, 3, "Uchar"),
                                NumGet(AddrWord, 2, "Uchar"),
                                NumGet(AddrWord, 1, "Uchar"),
                                NumGet(AddrWord, 0, "Uchar"))
                    }
                    Octet.AssertInteger().AssertGreaterOrEqual(0)
                         .AssertLessOrEqual(4)
                    return NumGet(AddrWord, 4 - Octet, "UChar")
                }

                set {
                    static IPM_SETADDRESS := 0x0400 + 101
                    static IPM_GETADDRESS := 0x0400 + 102

                    if (!IsSet(Octet)) {
                        if (value is String) {
                            value := StrSplit(value, ".")
                        }
                        Bytes := value.AssertType(Array)
                        Bytes.Length.AssertEquals(4, "invalid IPv4 address")

                        IPAddr := 0
                        for b in Bytes {
                            b.AssertInteger().AssertGreaterOrEqual(0)
                             .AssertLessOrEqual(255)

                            IPAddr <<= 8
                            IPAddr += b
                        }
                        SendMessage(IPM_SETADDRESS, 0, IPAddr, this)
                        return value
                    }
                    
                    if (!IsInteger(value) || (value < 0) || (value > 255)) {
                        throw ValueError("invalid octet value",, value)
                    }

                    AddrWord := Buffer(4)
                    SendMessage(IPM_GETADDRESS, 0, AddrWord, this)

                    NumPut("UChar", value, AddrWord, 4 - Octet)
                    IPAddr := NumGet(AddrWord, 0, "UInt")
                    SendMessage(IPM_SETADDRESS, 0, IPAddr, this)
                    return value
                }
            }

            /**
             * Clears the contents of the IP address control.
             */
            Clear() => SendMessage(IPM_CLEARADDRESS := 0x0400 + 100, 0, 0, this)

            /**
             * Determines if all fields in the IP address control are blank.
             * 
             * @return  {Boolean}
             */
            IsBlank => !!SendMessage(IPM_ISBLANK := 0x0400 + 105, 0, 0, this)

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
             * @param  {Integer}  Index  index of the field to set
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
             * Registers a callback function to call when an event is raised.
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
    }
}
