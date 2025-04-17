#Requires AutoHotkey >=v2.0.5
#Include %A_LineFile%/../../../AquaHotkey.ahk

class RECT {
    left: i32
    top: i32
    right: i32
    bottom: i32
}

class NMHDR {
    hwndFrom: uptr
    idFrom  : uptr
    code    : i32
}

class NMCUSTOMDRAW {
    hdr        : NMHDR
    dwDrawStage: u32
    hdc        : uptr
    rc         : RECT
    dwItemSpec : uptr
    uItemState : u32
    lItemlParam: iptr
}

class dwmapi extends DLL {
    static FilePath       => "dwmapi.dll"
    static TypeSignatures => {
        DwmSetWindowAttribute: "Ptr, Int, Int*, Int"
    }
}

class UXTheme extends DLL {
    static FilePath       => "uxtheme.dll"
    static TypeSignatures => {
        SetPreferredAppMode: "135, Int",
        FlushMenuThemes:     "136",
        SetWindowTheme:      "Ptr, Str, Ptr"
    }
}

class User32 extends DLL {
    static FilePath       => "user32.dll"
    static TypeSignatures => {
        InvalidateRect: "Ptr, Ptr, Int",
        GetWindow:      "Ptr, UInt, Ptr",
        FillRect:       "Ptr, Ptr, Ptr",
        FindWindowEx:   "Ptr, Ptr, Ptr, Ptr, Ptr",
        GetParent:      "Ptr, Ptr"
    }
}

class Gdi32 extends DLL {
    static FilePath       => "gdi32.dll"
    static TypeSignatures => {
        SetBkColor:       "Ptr, UInt",
        SetTextColor:     "Ptr, UInt",
        CreateSolidBrush: "UInt, Ptr",
        DeleteObject:     "Ptr"
    }
}

class Extension_DarkModeGui extends AquaHotkey
{
; >>>>>>>>>>>>
class Backup_Gui extends PropertyBackup
{
    static Class => Gui
}
; ------------
class Gui
{
    __New(Args*) {
        (Extension_DarkModeGui.Backup_Gui.Prototype.__New)(this, Args*)

        ; TODO
        this.BackColor := 0x202020

        if (VerCompare(A_OSVersion, "10.0.17763") >= 0) {
            DWMWA_USE_IMMERSIVE_DARK_MODE := 19
            if (VerCompare(A_OSVersion, "10.0.18985") >= 0) {
                DWMWA_USE_IMMERSIVE_DARK_MODE := 20
            }

            dwmapi.DwmSetWindowAttribute(this.Hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, 4)
            UXTheme.SetPreferredAppMode(2)
            UXTheme.FlushMenuThemes()
        }
    }

    Add(ControlType, Args*) {
        Ctl := (Extension_DarkModeGui.Backup_Gui.Prototype.Add)(this, ControlType, Args*)
        Ctl.ApplyDarkMode()
        return Ctl
    }

    AddButton(Args*)       => this.Add("Button", Args*)
    AddCheckBox(Args*)     => this.Add("CheckBox", Args*)
    AddDateTime(Args*)     => this.Add("DateTime", Args*)
    AddDropDownList(Args*) => this.Add("DropDownList", Args*)

    AddEdit(Args*)         => this.Add("Edit", Args*)
    AddGroupBox(Args*)     => this.Add("GroupBox", Args*)

    AddListBox(Args*)      => this.Add("ListBox", Args*)

    AddTab(Args*)          => this.Add("Tab", Args*)
    AddTab2(Args*)         => this.Add("Tab2", Args*)
    AddTab3(Args*)         => this.Add("Tab3", Args*)
    AddText(Args*)         => this.Add("Text", Args*)
    AddUpDown(Args*)       => this.Add("UpDown", Args*)
    
    class Button {
        ApplyDarkMode() {
            UXTheme.SetWindowTheme(this.Hwnd, "DarkMode_Explorer", 0)
            this.SetFont("cFFFFFF")

            this.Opt("Background202020")
            User32.InvalidateRect(this.Hwnd, 0, true)
        }
    }

    class CheckBox {
        ApplyDarkMode() {
            static WM_CTLCOLORBTN    := 0x0135
            static WM_CTLCOLORSTATIC := 0x0138

            UXTheme.SetWindowTheme(this.Hwnd, "DarkMode_Explorer", 0)
            this.SetFont("cFFFFFF")
            User32.InvalidateRect(this.Hwnd, 0, true)

            this.OnMessage(WM_CTLCOLORSTATIC, (Btn, wParam, lParam, Msg) {
                MsgBox("rendering...")
                Gdi32.SetTextColor(wParam, 0xE0E0E0)
                Gdi32.SetBkColor(wParam, 0x202020)
                return Gdi32.CreateSolidBrush(0x202020)
            })
        }
    }

    class ComboBox {
        ApplyDarkMode() {
            static WM_CTLCOLOREDIT    := 0x0133
            static WM_CTLCOLORLISTBOX := 0x0134

            UXTheme.SetWindowTheme(this.Hwnd, "DarkMode_CFD", 0)
            this.SetFont("cFFFFFF")
            User32.InvalidateRect(this.Hwnd, 0, true)

            this.OnMessage(WM_CTLCOLORLISTBOX, (CB, wParam, lParam, Msg) {
                Gdi32.SetTextColor(wParam, 0xE0E0E0)
                return Gdi32.CreateSolidBrush(0x202020)
            })

            this.OnMessage(WM_CTLCOLOREDIT, (Edit, wParam, lParam, Msg) {
                Gdi32.SetTextColor(wParam, 0xE0E0E0)
                Gdi32.SetBkColor(wParam, 0x202020)
                return Gdi32.CreateSolidBrush(0x202020)
            })
        }
    }

    class DateTime {
        ApplyDarkMode() {
            UXTheme.SetWindowTheme(this.Hwnd, "DarkMode_Explorer", 0)
            this.SetFont("cFFFFFF")
            User32.InvalidateRect(this.Hwnd, 0, true)

            ; TODO
            SendMessage(0x1006, 0, 0x202020, this.Hwnd)
            SendMessage(0x1006, 1, 0xE0E0E0, this.Hwnd)
            SendMessage(0x1006, 2, 0x303030, this.Hwnd)
            SendMessage(0x1006, 3, 0xE0E0E0, this.Hwnd)
            SendMessage(0x1006, 4, 0x202020, this.Hwnd)
            SendMessage(0x1006, 5, 0x202020, this.Hwnd)
        }
    }

    class DDL {
        ApplyDarkMode() {
            UXTheme.SetWindowTheme(this.Hwnd, "DarkMode_CFD", 0)
            this.SetFont("cFFFFFF")
            User32.InvalidateRect(this.Hwnd, 0, true)

            this.OnMessage(0x134, (CB, wParam, lParam, Msg) {
                Gdi32.SetTextColor(wParam, 0xE0E0E0)

                return Gdi32.CreateSolidBrush(0x202020)
            })
        }
        ; works without scrollbar
    }

    class Edit {
        ApplyDarkMode() {
            uxtheme.SetWindowTheme(this.Hwnd, "DarkMode_Explorer", 0)
            this.SetFont("cFFFFFF")
            User32.InvalidateRect(this.Hwnd, 0, true)

            this.Opt("Background202020")
        }
        ; works; fix outline?
    }

    class GroupBox {
        ApplyDarkMode() {
            UXTheme.SetWindowTheme(this.Hwnd, "", 0)
            this.SetFont("cFFFFFF")
            User32.InvalidateRect(this.Hwnd, 0, true)
        }
        ; TODO: text is still black
    }

    class ListBox {
        ApplyDarkMode() {
            static WM_CTLCOLORLISTBOX := 0x0134

            UXTheme.SetWindowTheme(this.Hwnd, "DarkMode_Explorer", 0)
            this.SetFont("cFFFFFF")
            User32.InvalidateRect(this.Hwnd, 0, true)

            this.Opt("Background202020")

            this.OnMessage(WM_CTLCOLORLISTBOX, (CB, wParam, lParam, Msg) {
                Gdi32.SetTextColor(wParam, 0xE0E0E0)
                return Gdi32.CreateSolidBrush(0x202020)
            })

            ; works; fix outline?
        }
    }

    class ListView {
        ApplyDarkMode() {
            static LVS_EX_DOUBLEBUFFER := 0x00010000
            static NM_CUSTOMDRAW := -12
            static UIS_SET := 1
            static UISF_HIDEFOCUS := 0x1
            static WM_CHANGEUISTATE := 0x0127
            static WM_NOTIFY := 0x4E
            static WM_THEMECHANGED := 0x031A

            SendMessage(0x1001, 0, 0x202020, this)
            SendMessage(0x1024, 0, 0xD0D0D0, this)
            SendMessage(0x1026, 0, 0x303030, this)

            UXTheme.SetWindowTheme(this.Hwnd, "", 0)
            this.OnMessage(WM_THEMECHANGED, (*) => 0)

            HeaderHwnd := SendMessage(0x101F, 0, 0, this)

            this.Opt("Background202020")

            this.OnMessage(WM_NOTIFY, (Hwnd, wParam, lParam, Msg) {
                static CDDS_ITEMPREPAINT := 0x10001
                static CDDS_PREPAINT := 0x1
                static CDRF_DODEFAULT := 0x0
                static CDRF_NOTIFYITEMDRAW := 0x20

                if (StructFromPtr(NMHDR, lParam).Code != NM_CUSTOMDRAW) {
                    return
                }
                nmcd := StructFromPtr(NMCUSTOMDRAW, lParam)
                if (nmcd.hdr.HwndFrom != HeaderHwnd) {
                    return
                }
                if (nmcd.dwDrawStage == CDDS_PREPAINT) {
                    return CDRF_NOTIFYITEMDRAW
                }
                if (nmcd.dwDrawStage == CDDS_ITEMPREPAINT) {
                    ; TODO also move color 0xFFFFFF into a variable somewhere
                    DllCall("SetTextColor", "Ptr", nmcd.hdc, "UInt", 0xFFFFFF)
                }

                return CDRF_DODEFAULT
            })

            this.Opt("+LV" . LVS_EX_DOUBLEBUFFER)
            SendMessage(WM_CHANGEUISTATE, (UIS_SET << 8) | UISF_HIDEFOCUS, 0, this)
            UXTheme.SetWindowTheme(HeaderHwnd, "DarkMode_ItemsView", 0)
        }

        ; works - without scrollbar
    }

    class Tab {
        ApplyDarkMode() {
            this.SetFont("cE0E0E0")
        }
    }

    class Text {
        ApplyDarkMode() {
            this.Opt("cE0E0E0")
        }
        ; works
    }

    class UpDown {
        ApplyDarkMode() {
            UXTheme.SetWindowTheme(this.Hwnd, "DarkMode_Explorer", 0)
            User32.InvalidateRect(this.Hwnd, 0, true)
        }

        ; works - except for scrollbar
    }
}
; <<<<<<<<<<<<
}

GuiObj  := Gui()
GuiObj.AddDropDownList(, Array("Why", "tho"))

GuiObj.AddCheckBox(, "Ship to billing address?")

GuiObj.AddEdit("r5 w150")
GuiObj.AddUpDown("Range1-10", 5)
GuiObj.Show()
