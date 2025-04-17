#Requires AutoHotkey >=v2.1-alpha
#Include <AquaHotkey>

class SYSTEMTIME {
    wYear         : u16
    wMonth        : u16
    wDayOfWeek    : u16
    wDay          : u16
    wHour         : u16
    wMinute       : u16
    wSecond       : u16
    wMilliseconds : u16
}

class MonthCalExtension extends AquaHotkey {
    class Gui {
        class MonthCal {
            MCM_GETCURSEL      => 0x1001
            MCM_SETCURSEL      => 0x1002

            Selection {
                get {

                }
                set {

                }
            }

            MCM_GETMAXSELCOUNT => 0x1003
            MCM_SETMAXSELCOUNT => 0x1004

            MaxSelectedCount {
                get {

                }
                set {

                }
            }

            MCM_GETSELRANGE    => 0x1005
            MCM_SETSELRANGE    => 0x1006

            SelectedRange {
                get {

                }
                set {

                }
            }

            MCM_GETMONTHRANGE  => 0x1007

            MonthRange {
                get {

                }
            }

            MCM_SETDAYSTATE    => 0x1008

            DayState {
                set {

                }
            }

            MCM_GETMINREQRECT  => 0x1009

            MinRequiredRect {
                get {

                }
            }

            MCM_SETCOLOR       => 0x100A
            MCM_GETCOLOR       => 0x100B

            MCSC_BACKGROUND    => 0
            MCSC_TEXT          => 1
            MCSC_TITLEBK       => 2
            MCSC_TITLETEXT     => 3
            MCSC_MONTHBK       => 4
            MCSC_TRAILINGTEXT  => 5

            Color[Component := "Background"] {
                get {
                    switch (Component) {
                        case "Background":      iColor := 0
                        case "Text":            iColor := 1
                        case "TitleBackground": iColor := 2
                        case "TitleText":       iColor := 3
                        case "MonthBackground": iColor := 4
                        case "TrailingText":    iColor := 5
                        default: throw ValueError("invalid component")
                    }
                    return SendMessage(this.MCM_GETCOLOR, iColor, 0, this)
                }
                set {
                    value := value.AssertInteger()
                    switch (Component) {
                        case "Background":      iColor := 0
                        case "Text":            iColor := 1
                        case "TitleBackground": iColor := 2
                        case "TitleText":       iColor := 3
                        case "MonthBackground": iColor := 4
                        case "TrailingText":    iColor := 5
                        default: throw ValueError("invalid component")
                    }
                    return SendMessage(this.MCM_SETCOLOR, iColor, value, this)
                }
            }

            MCM_SETTODAY => 0x100C
            MCM_GETTODAY => 0x100D

            Today {
                get {

                }
                set {

                }
            }

            MCM_HITTEST => 0x100E

            HitTest() {

            }

            OnEvent(EventName, Callback, AddRemove?) {
                EventName.AssertEquals("Change")
                return this.OnCommand(0x0300, Callback, AddRemove?)
            }
        }
    }
}