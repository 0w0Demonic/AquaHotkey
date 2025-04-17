#Requires AutoHotkey >=v2.0.5

#Include <GuiIPv4>
#Include <GuiAnimation>
#Include <GuiMonthCal>

class Extension_DarkListView extends AquaHotkey {
    class Gui {
        class ListView {
            LVM_FIRST => 0x1000

            
            Header {
                get {
                    Hwnd := SendMessage(this.LVM_FIRST + 31, 0, 0, this)
                    Header := { Hwnd: Hwnd }
                    ObjSetBase(Header, Gui.ListView.Header.Prototype)
                    return Header
                }
            }

            class Header {
                RemoveTheme() {
                    DllCall("uxtheme.dll\SetWindowTheme", "Ptr", this.Hwnd,
                            "Str", "", "Str", "")
                }
            }
        }
    }
}
MyGui := Gui()

; Create the ListView with two columns, Name and Size:
LV := MyGui.Add("ListView", "r20 w700", ["Name", "Size (KB)"])

; Gather a list of file names from a folder and put them into the ListView:
Loop Files, A_MyDocuments "\*.*"
    LV.Add(, A_LoopFileName, A_LoopFileSizeKB)

LV.ModifyCol()  ; Auto-size each column to fit its contents.
LV.ModifyCol(2, "Integer")  ; For sorting purposes, indicate that column 2 is an integer.

; Display the window:
MyGui.Show("Autosize")

Header := LV.Header

; remove the theme for header
Header.RemoveTheme()

ProcessWindow(Hwnd, Msg, wParam, lParam) {

}

pCallback := CallbackCreate(ProcessWindow)
DllCall("SetWindowLong", "Ptr", Header.Hwnd, "Int", -4, pCallback)

CallbackFree(pCallback)





/*
;coded by rover 2k11
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <FontConstants.au3>
#include <GuiListView.au3>
#include <Constants.au3>

Opt('MustDeclareVars', 1)

Global $hGUI, $cListView, $hListView
Global $iDllGDI = DllOpen("gdi32.dll")
Global $iDllUSER32 = DllOpen("user32.dll")

;Three column colours
Global $aCol[3][2] = [[0xFFFF00, 0x494E49],[0xFFFF00, 0x0000FF],[0xFFFFFF, 0x0D0E0F]]

;One colour to rule them all
;blow off array and just set SetTextColor() / SetBkColor() with one colour
;Global $aCol[3][2] = [[0xFFFF00, 0x0000FF], [0xFFFF00, 0x0000FF], [0xFFFF00, 0x0000FF]]


;Convert RBG to BGR for SetText/BkColor()
For $i = 0 To UBound($aCol)-1
    $aCol[$i][0] = _BGR2RGB($aCol[$i][0])
    $aCol[$i][1] = _BGR2RGB($aCol[$i][1])
Next

$hGUI = GUICreate("Set Listview Header Colour ", 500, 300)
GUISetBkColor(0xFFFFFF)


$cListView = GUICtrlCreateListView("Items List|SubItems1|SubItems2", 10, 10, 480, 280)
;get ListView handle from control ID
$hListView = GUICtrlGetHandle($cListView)
_GUICtrlListView_SetExtendedListViewStyle($hListView, BitOR($LVS_EX_DOUBLEBUFFER, $LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))

GUICtrlSetFont(-1, 9, 800, 0, "Comic Sans MS", $ANTIALIASED_QUALITY)

;get handle to child SysHeader32 control of ListView
Global $hHeader = HWnd(GUICtrlSendMsg($cListView, $LVM_GETHEADER, 0, 0))
;Turn off theme for header
DllCall("uxtheme.dll", "int", "SetWindowTheme", "hwnd", $hHeader, "wstr", "", "wstr", "")
;subclass ListView to get at NM_CUSTOMDRAW notification sent to ListView
Global $wProcNew = DllCallbackRegister("_LVWndProc", "ptr", "hwnd;uint;wparam;lparam")
Global $wProcOld = _WinAPI_SetWindowLong($hListView, $GWL_WNDPROC, DllCallbackGetPtr($wProcNew))

;Optional: Flat Header - remove header 3D button effect
Global $iStyle = _WinAPI_GetWindowLong($hHeader, $GWL_STYLE)
_WinAPI_SetWindowLong($hHeader, $GWL_STYLE, BitOR($iStyle, $HDS_FLAT))


For $i = 1 To 15
    _GUICtrlListView_AddItem($hListView, "Item" & $i)
    _GUICtrlListView_AddSubItem($hListView, $i - 1, "SubItem" & $i, 1)
    _GUICtrlListView_AddSubItem($hListView, $i - 1, "SubItem" & $i, 2)
Next

_GUICtrlListView_SetColumnWidth($hListView, 0, $LVSCW_AUTOSIZE_USEHEADER)
_GUICtrlListView_SetColumnWidth($hListView, 1, $LVSCW_AUTOSIZE_USEHEADER)
_GUICtrlListView_SetColumnWidth($hListView, 2, $LVSCW_AUTOSIZE_USEHEADER)

GUISetState()

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE
If $wProcOld Then _WinAPI_SetWindowLong($hListView, $GWL_WNDPROC, $wProcOld)
; Delete callback function
If $wProcNew Then DllCallbackFree($wProcNew)
GUIDelete()
Exit

Func _LVWndProc($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $wParam
    If $iMsg = $WM_NOTIFY Then
        Local $tNMHDR, $hWndFrom, $iCode, $iItem, $hDC
        $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
        $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
        $iCode = DllStructGetData($tNMHDR, "Code")
        ;Local $IDFrom = DllStructGetData($tNMHDR, "IDFrom")

        Switch $hWndFrom
            Case $hHeader
                Switch $iCode
                    Case $NM_CUSTOMDRAW
                        Local $tCustDraw = DllStructCreate($tagNMLVCUSTOMDRAW, $lParam)
                        Switch DllStructGetData($tCustDraw, "dwDrawStage")
                            Case $CDDS_PREPAINT
                                Return $CDRF_NOTIFYITEMDRAW
                            Case $CDDS_ITEMPREPAINT
                                $hDC = DllStructGetData($tCustDraw, "hDC")
                                $iItem = DllStructGetData($tCustDraw, "dwItemSpec")
                                DllCall($iDllGDI, "int", "SetTextColor", "handle", $hDC, "dword", $aCol[$iItem][0])
                                DllCall($iDllGDI, "int", "SetBkColor", "handle", $hDC, "dword", $aCol[$iItem][1])
                                Return $CDRF_NEWFONT
                                Return $CDRF_SKIPDEFAULT
                        EndSwitch
                EndSwitch
        EndSwitch
    EndIf
    ;pass the unhandled messages to default WindowProc
    Local $aResult = DllCall($iDllUSER32, "lresult", "CallWindowProcW", "ptr", $wProcOld, _
            "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam)
    If @error Then Return -1
    Return $aResult[0]
EndFunc   ;==>_LVWndProc

Func _BGR2RGB($iColor)
    ;Author: Wraithdu
    Return BitOR(BitShift(BitAND($iColor, 0x0000FF), -16), BitAND($iColor, 0x00FF00), BitShift(BitAND($iColor, 0xFF0000), 16))
EndFunc   ;==>_BGR2RGB
 */