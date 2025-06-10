#Requires AutoHotkey >=v2.0.5
#Include %A_LineFile%/../../AquaHotkeyX.ahk

class InternetExplorer extends COM {
    static CLSID => "InternetExplorer.Application"

    ; static IID => ""

    __New(URL?) {
        this.Visible := true
        this.Navigate(URL ?? "https://www.autohotkey.com")
    }

    class EventSink extends COM.EventSink {
        DocumentComplete(pDisp, &URL) {
            if (InStr(URL, "youtube")) {
                return
            }

            if (this.ReadyState == 4) {
                MsgBox("finished loading page. Redirect to YouTube.")
                this.Navigate("https://www.youtube.com")
            }
        }

        ShowEvents => true
    }

    static MethodSignatures => {
        DoSomething: [1, "UInt", "Ptr"]
    }
}

ie := InternetExplorer()

Sleep(20000)
MsgBox("quitting test now...")
try ie.Quit()
ExitApp()
