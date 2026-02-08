
SimpleMath := "Number/Value/x"
SimpleString := "String/Str"

SimpleStringItem := SimpleString . "/Item"
SimpleStringText := SimpleString . "/Text"

WinTitle_1stHalf := "WinTitle/WTtl, WinText/WTxt"
WinTitle_2ndHalf := "ExcludeTitle/ETtl/NoTitle,"
                     . "ExcludeText/ETxt/NoText"

WinTitle := WinTitle_1stHalf . ", " . WinTitle_2ndHalf
WinTitleTimeout := WinTitle_1stHalf . ", Timeout, " . WinTitle_2ndHalf
SetWinTitle := "Value, " . WinTitle

Capacity := "Capacity/Cap/Size"

Style := "Value/Style"
ExStyle := "Value/Style/ExStyle"

ComObj := "ComObj/ComObject"
Size := "Bytes/Size/Length"
Pointer := "Ptr/Addr/Address"
Options := "Options/Opt"
Control := "Control/Ctrl/Ctl"
ControlWinTitle := Control . ", " . WinTitle
ControlIndex := "N/Index"
IndexControlWinTitle := ControlIndex . ", " . ControlWinTitle

Coordinates := "X, Y, Width/W, Height/H"
CoordinatesWinTitle := Coordinates . ", " . WinTitle
WorkArea := "X, Y, X1, Y1, X2, Y2"

Drive := "Drive/DriveName"
DriveOrFilePath := Drive . "/Path/FilePath"

Key := "KeyName/Name/Key"
Group := "GroupName/Group/Name"

LTRB := "Left/L, Top/T, Right/R, Bottom/B"
FilePattern := "FilePattern/FileName/FilePath"
SingleFile := "Filename/FilePath/Path"

SourcePattern := "SourcePattern/Source/From"
DestPattern := "DestPattern/Dest/To"
ParamCount := "ParamCount/MaxParams/Params"

Callback := "Callback, AddRemove"
Message := "Msg/Message/MsgNumber/MessageNumber"

Process := "Proc/Process/Name/ProcessName/PID"

return Array(
    Abs, SimpleMath,
    ASin, SimpleMath,
    ACos, SimpleMath,
    ATan, SimpleMath,
    Array, Array_With,
    BlockInput, "OnOff/SendMouse/MouseMove",
    Buffer, Size . ", FillByte",
    CallbackCreate, "Callback, " . Options . ", " . ParamCount,
    CallbackFree, Pointer,
    CaretGetPos, "X, Y",
    Ceil, SimpleMath,
    Chr, SimpleMath,
    Click, Options,
    ClipboardAll, Pointer . ", " . Size,
    ClipWait, "Timeout, WaitFor/Type",
    ; ComCall
    ComObjActive, "CLSID",
    ; ComObjArray
    ComObjConnect, ComObj . ", Prefix/Namespace/Sink",
    ComObject, "CLSID, IID",
    ComObjFlags, ComObj . ", NewFlags/Flags/Value, Mask",
    ComObjFromPtr, "DispPtr/" . Pointer,
    ComObjGet, "Name",
    ; ComObjQuery
    ComObjType, ComObj . ", InfoType/Name/IID/Class/CLSID",
    ComObjValue, ComObj,
    ComObject, "VarType/Type, Value, Flags",
    ControlAddItem, SimpleStringItem . ControlWinTitle,
    ControlChooseIndex, ControlIndex . ", " . ControlWinTitle,
    ControlChooseString, SimpleStringItem . "/Choice, " . ControlWinTitle,
    ControlClick, Control . "/Position/Pos, " . WinTitle_1stHalf
                . ", WhichButton/Button/Key/Type"
                . ", ClickCount/Clicks/Repeat/Amount/Times/Count"
                . ", " . Options . ", "
                . WinTitle_2ndHalf,
    ControlDeleteItem, ControlIndex . ", " . ControlWinTitle,
    ControlFindItem, SimpleStringItem . ControlWinTitle,
    ControlFocus, ControlWinTitle,
    ControlGetChecked, ControlWinTitle,
    ControlGetChoice, ControlWinTitle,
    ControlGetClassNN, ControlWinTitle,
    ControlGetEnabled, ControlWinTitle,
    ControlGetFocus, WinTitle,
    ControlGetHwnd, ControlWinTitle,
    ControlGetIndex, ControlWinTitle,
    ControlGetItems, ControlWinTitle,
    ControlGetPos, Coordinates . ", " . ControlWinTitle,
    ControlGetStyle, ControlWinTitle,
    ControlGetExStyle, ControlWinTitle,
    ControlGetText, ControlWinTitle,
    ControlGetVisible, ControlWinTitle,
    ControlHide, ControlWinTitle,
    ControlHideDropDown, ControlWinTitle,
    ControlMove, Coordinates . ", " . ControlWinTitle,
    ControlSend, "Keys, " . ControlWinTitle,
    ControlSendText, "Keys/Text, " . ControlWinTitle,
    ControlSetChecked, "Value/Checked, " . ControlWinTitle,
    ControlSetEnabled, "Value/Enabled, " . ControlWinTitle,
    ControlSetStyle, "Value/Style, " . ControlWinTitle,
    ControlSetExStyle, "Value/Style/ExStyle, " . ControlWinTitle,
    ControlSetText, "Value/NewText/Text, " . ControlWinTitle,
    ControlShow, ControlWinTitle,
    ControlShowDropDown, ControlWinTitle,
    CoordMode, "TargetType/Type/Mode, RelativeTo/Value",
    Cos, SimpleMath,
    Critical, "Value/OnOff/Setting/Mode",
    DateAdd, "DateTime/Timestamp,"
            . "Time/Difference/Duration/TimeSpan/Span,"
            . "Unit/Units/TimeUnit/TimeUnits",
    DateDiff, "DateTime/Timestamp,"
            . "Time/Difference/Duration/TimeSpan/Span,"
            . "Unit/Units/TimeUnit/TimeUnits",
    DetectHiddenText, "Mode/OnOff",
    DetectHiddenWindows, "Mode/OnOff",
    DirCopy, "Source/SourceDir,"
           . "Destination/Dest/DestDir,"
           . "Overwrite",
    DirCreate, "DirName/FilePath/Path",
    DirDelete, "DirName/FilePath/Path, Recurse",
    DirExist, "FilePattern/DirName/FilePath/Path",
    DirMove, "Source/SourceDir,"
           . "Destination/Dest/DestDir,"
           . "Overwrite/Rename",
    DirSelect, "StartingFolder/DirName/FilePath/Path, " . Options
             . ", Prompt/Title/Text/DisplayedText",
    ; DllCall
    Download, "URL, Filename/Path/Dest/Destination",
    DriveEject, Drive,
    DriveRetract, Drive,
    DriveGetCapacity, DriveOrFilePath,
    DriveGetFileSystem, Drive,
    DriveGetLabel, Drive,
    DriveGetList, "DriveType/Type",
    DriveGetSerial, Drive,
    DriveGetSpaceFree, DriveOrFilePath,
    DriveGetStatus, Drive,
    DriveGetStatusCD, Drive,
    DriveGetType, DriveOrFilePath,
    DriveLock, Drive,
    DriveEject, Drive,
    DriveRetract, Drive,
    DriveSetLabel, Drive . ", NewLabel/Label",
    DriveUnlock, Drive,
    EditGetCurrentCol, ControlWinTitle,
    EditGetCurrentLine, ControlWinTitle,
    EditGetLine, IndexControlWinTitle,
    EditGetLineCount, ControlWinTitle,
    EditGetSelectedText, ControlWinTitle,
    EditPaste, SimpleStringText . ", " . ControlWinTitle,
    EnvGet, "EnvVar/Name",
    EnvSet, "EnvVar/Name, Value",
    Exit, "ExitCode/Code",
    ExitApp, "ExitCode/Code",
    Exp, SimpleMath,
    FileAppend, SimpleStringText . ", " . SingleFile . ", " . Options,
    FileCopy, "Source/SourcePattern/From,"
            . "Dest/DestPattern/To,"
            . "Overwrite",
    FileCreateShortcut, "Target, LinkFile, WorkingDir, Args,"
                      . "Description, IconFile, ShortcutKey,"
                      . "IconNumber, RunState",
    FileDelete, FilePattern,
    FileEncoding, "Encoding",
    FileExist, FilePattern,
    %"FileInstall"%, "Source/Src/From, Dest/To, Overwrite",
    FileGetAttrib, SingleFile,
    FileGetShortcut, "LinkFile, Target, Dir, Args, Description,"
                    . "Icon, IconNum, RunState",
    FileGetSize, SingleFile . ", Units/In",
    FileGetTime, SingleFile . ", WhichTime/Mode/Type",
    FileGetVersion, SingleFile,
    FileMove, SourcePattern . ", " . DestPattern ", Overwrite",
    FileOpen, SingleFile . ", /Mode/Flags/" . Options . ", Encoding",
    FileRead, SingleFile . ", " . Options,
    FileRecycle, FilePattern,
    FileRecycleEmpty, FilePattern,
    FileSelect, Options . ", RootDir/From/" . SingleFile . ", Title, Filter",
    FileSetAttrib, "Attributes/NewValue/Flags/Value, " . FilePattern . ", Mode",
    FileSetTime, "Timestamp/Time/Value, " . FilePattern
               . ", WhichTime/Type, Mode",
    Float, SimpleMath . "/Value",
    Floor, SimpleMath,
    Format, Format_With,
    FormatTime, "Timestamp/Time/Value, Format",
    GetKeyName, Key,
    GetKeyVK, Key,
    GetKeySC, Key,
    GetKeyState, Key . ", Mode/Type",
    GetMethod, "Value, Name/MethodName/Method, ParamCount/MaxParams",
    GroupActivate, Group . ", Mode/Type",
    GroupAdd, Group . ", " . WinTitle,
    GroupClose, Group . ", Mode/Type",
    GroupDeactivate, Group . ", Mode/Type",
    Gui, Options . ", Title, EventObj/EventSink",
    GuiCtrlFromHwnd, "Hwnd",
    GuiFromHwnd, "Hwnd, Recurse/RecurseParent",
    HasBase, "Value, BaseObj",
    HasMethod, "Value, Name/MethodName/Method"
             . "ParamCount/MaxParams",
    HasProp, "Value, Name/Prop/Property/PropName/PropertyName",
    HotIf, "Condition/Callback",
    Hotkey, "Hotkey/Keys/Key/KeyName, Action/Callback, " . Options,
    ; Hotstring
    IL_Create, "InitialCount, GrowCount, LargeIcons",
    IL_Add, "ImageListID, IconFileName, IconNumber/MaskColor, Resize",
    IL_Destroy, "ImageListID",
    ImageSearch, WorkArea . ", ImageFile/File/Image/" . SingleFile,
    IniDelete, SingleFile . ", Section, Key",
    IniRead, SingleFile . ", Section, Key, Default",
    IniWrite, "Value/Pairs, " . SingleFile . ", Section, Key",
    InputBox, "Prompt, Title, " . Options . ", Default",
    InputHook, Options . ", EndKeys, MatchList",
    InstallKeybdHook, "Install, Force",
    InstallMouseHook, "Install, Force",
    InStr, "Haystack, Needle/Pattern, CaseSense,"
         . "StartingPos/Start/StartIndex, Occurrence",
    Integer, SimpleMath . "/Value",
    IsLabel, "LabelName/Name/Label",
    IsObject, "Value",
    IsSetRef, "Ref/Value",
    KeyHistory, "MaxEvents/Value",
    KeyWait, "Key/KeyName/Name, " . Options,
    ListLines, "Mode/Type",
    ListViewGetContent, Options . ", " . ControlWinTitle,
    LoadPicture, SingleFile . ", " . Options . ", ImageType",
    Log, SimpleMath,
    Ln, SimpleMath,
    Map, Map_With,
    Max, Max_With,
    MenuFromHandle, "Handle/Hwnd",
    MenuSelect, WinTitle_1stHalf
              . ", Menu,"
              . "SubMenu1/Sub1/Menu1,"
              . "SubMenu2/Sub2/Menu2,"
              . "SubMenu3/Sub3/Menu3,"
              . "SubMenu4/Sub4/Menu4,"
              . "SubMenu5/Sub5/Menu5,"
              . "SubMenu6/Sub6/Menu6,"
              . WinTitle_2ndHalf,
    Min, Min_With,
    Mod, "Dividend, Divisor",
    MonitorGet, "N/Index, " . LTRB,
    Round, SimpleMath . ", Digits/N",
    MonitorGetName, "N/Index",
    MonitorGetWorkArea, "N/Index, " . LTRB,
    MouseClick, "WhichButton/Button, X, Y, Clicks/ClickCount/Times,"
              . "Speed, Direction/DownOrUp, Relative",
    MouseClickDrag, "WhichButton/Button, " . WorkArea . ", Speed, Relative",
    MouseGetPos, "X, Y, Window/Hwnd, " . Control . "/ClassNN, Flag",
    MouseMove, "X, Y, Speed, Relative",
    MsgBox, "Text, Title, Options",
    Number, SimpleMath,
    NumGet, NumGet_With,
    ; NumPut
    ObjAddRef, Pointer,
    ObjRelease, Pointer,
    ObjBindMethod, ObjBindMethod_With,
    ObjHasOwnProp, "Obj, Prop/Name/PropName/Property/PropertyName",
    ObjOwnProps, "Obj",
    ObjGetBase, "Obj",
    ObjGetCapacity, "Obj",
    ObjGetDataPtr?, "Obj",
    ObjGetDataSize?, "Obj",
    ObjOwnPropCount, "Obj",
    ObjSetBase, "Obj, BaseObj/Base",
    ObjSetCapacity, "Obj, " . Capacity,
    ObjSetDataPtr?, "Obj, " . Pointer,
    OnClipboardChange, Callback,
    OnError, Callback,
    OnExit, Callback,
    OnMessage, Message . ", Callback, MaxThreads",
    Ord, "Str/String/Char/Character",
    OutputDebug, "Text",
    Pause, "ThreadState",
    Persistent, "Persist",
    PixelGetColor, "X, Y, Mode/Type",
    PixelSearch, WorkArea . ", ColorID/Color, Variation",
    PostMessage, Message . ", wParam, wParam, " . ControlWinTitle,
    ProcessClose, Process,
    ProcessWaitClose, Process . ", Timeout",
    Random, "A, B",
	RegExMatch, SimpleString . ", RegEx/Pattern, MatchObj/Match/Output/Out,"
			  . "Start/StartingPos/Index",
	RegExReplace, SimpleString . ", RegEx/Pattern, Rep/Replacement, "
			    . "MatchObj/Match/Output/Out, Start/StartingPos/Index",
    RegCreateKey, "Key/Name/KeyName",
    RegDelete, "KeyName, ValueName",
    RegDeleteKey, "KeyName",
    RegRead, "Key/KeyName, Value/ValueName, Default",
    RegWrite, "Value, ValueType/Type, KeyName, ValueName",
    Round, SimpleMath . "N/Digits",
    Run, "Target/Command, WorkingDir, " . Options . ", " . Process,
    RunWait, "Target/Command, WorkingDir, " . Options . ", " . Process,
    Send, "Keys/Text/Str/String",
    SendText, "Keys/Text/Str/String",
    SendInput, "Keys/Text/Str/String",
    SendPlay, "Keys/Text/Str/String",
    SendEvent, "Keys/Text/Str/String",
    SendLevel, "Level/Value",
    SendMessage, Message . ", wParam, lParam, " . ControlWinTitle . ", Timeout",
    SendMode, "Mode/Type",
    SetCapsLockState, "State",
    SetControlDelay, "Delay",
    SetDefaultMouseSpeed, "Speed",
    SetKeyDelay, "Delay, PressDuration/Duration, Play",
    SetMouseDelay, "Delay, Play",
    SetNumLockState, "State/OnOff",
    SetScrollLockState, "State/OnOff",
    SetRegView, "Mode/RegView",
    SetStoreCapsLockMode, "OnOff/Mode",
    SetTimer, "Callback, Period/Interval, Priority",
    SetTitleMatchMode, "Speed/MatchMode/Mode",
    SetWinDelay, "Delay",
    SetWorkingDir, "DirName/Dir/WorkingDir",
    Shutdown, "Flag/Type/Mode",
    Sin, SimpleMath,
    Sleep, "Delay/Duration/Time",
    Sort, SimpleString . ", " . Options . ", Callback",
    SoundBeep, "Frequency, Duration",
    SoundGetInterface, "IID, Component, Device",
    SoundGetMute, "Component, Device",
    SoundGetName, "Component, Device",
    SoundGetVolume, "Component, Device",
    SoundPlay, SingleFile . ", Wait",
    SoundSetMute, "Value/OnOff/Setting, Component, Device",
    SoundSetVolume, "Value/OnOff/Setting, Component, Device",
    SplitPath, "Path, FileName, Dir, Extension, NameNoExt, Drive",
    Sqrt, SimpleMath,
    StatusBarGetText, "Part/N/Index, " . WinTitle,
    StatusBarWait, "BarText/Text, Timeout, Part/N/Index, " . WinTitle_1stHalf
                 . ", Interval, " . WinTitle_2ndHalf,
    StrCompare, "Str1/String1/A/First, Str2/String2/B/Second, CaseSense",
    StrGet, StrGet_With,
    String, "Value",
    StrLen, SimpleString,
    StrLower, SimpleString,
    StrPtr, SimpleString,
    ; StrPut
    StrReplace, SimpleString . ", Pattern, Rep/Replacement, CaseSense,"
			  . "Count, Limit",
    StrSplit, SimpleString . ", Delimiters/Delim, OmitChars/Omit/Remove/Trim,"
            . "MaxParts/Limit",
    StrTitle, SimpleString,
    StrUpper, SimpleString,
    SubStr, SimpleString . ", Index/Start/StartingPos, Length/Len",
    Suspend, "State",
    SysGet, "Value/Property/Prop",
    Tan, SimpleMath,
    ; Thread
    ToolTip, SimpleStringText . ", X, Y, Index/N/WhichToolTip",
    TraySetIcon, SingleFile . ", Icon, Freeze",
    TrayTip, "Text, Title, " . Options,
    Trim, SimpleString . ", OmitChars/Omit/Remove/Trim",
    RTrim, SimpleString . ", OmitChars/Omit/Remove/Trim",
    LTrim, SimpleString . ", OmitChars/Omit/Remove/Trim",
    Type, "Value",
    VarSetStrCapacity, SimpleString . ", " . Capacity,
    VerCompare, "VersionA/A, VersionB/B",
    WinActivate, WinTitle,
    WinActivateBottom, WinTitle,
    WinActive, WinTitle,
    WinClose, WinTitleTimeout,
    WinExist, WinTitle,
    WinGetAlwaysOnTop?, WinTitle,
    WinGetClass, WinTitle,
    WinGetClientPos, CoordinatesWinTitle,
    WinGetControls, WinTitle,
    WinGetControlsHwnd, WinTitle,
    WinGetCount, WinTitle,
    WinGetEnabled?, WinTitle,
    WinGetID, WinTitle,
    WinGetIDLast, WinTitle,
    WinGetList, WinTitle,
    WinGetMinMax, WinTitle,
    WinGetPID, WinTitle,
    WinGetPos, CoordinatesWinTitle,
    WinGetProcessName, WinTitle,
    WinGetProcessPath, WinTitle,
    WinGetStyle, WinTitle,
    WinGetExStyle, WinTitle,
    WinGetText, WinTitle,
    WinGetTitle, WinTitle,
    WinGetTransColor, WinTitle,
    WinGetTransparent, WinTitle,
    WinHide, WinTitle,
    WinKill, WinTitle,
    WinMaximize, WinTitle,
    WinMinimize, WinTitle,
    WinMove, CoordinatesWinTitle,
    WinMoveBottom, WinTitle,
    WinMoveTop, WinTitle,
    WinRedraw, WinTitle,
    WinRestore, WinTitle,
    WinSetAlwaysOnTop, SetWinTitle,
    WinSetEnabled, SetWinTitle,
    WinSetRegion, Options . ", " . WinTitle,
    WinSetStyle, Style . ", " . WinTitle,
    WinSetExStyle, ExStyle . ", " . WinTitle,
    WinSetTitle, "Title/Value, " . WinTitle,
    WinSetTransColor, "Color/" . SetWinTitle,
    WinSetTransparent, "N/OnOff/" . SetWinTitle,
    WinShow, WinTitle,
    WinWait, WinTitleTimeout,
    WinWaitActive, WinTitleTimeout,
    WinWaitNotActive, WinTitleTimeout,
    WinWaitClose, WinTitleTimeout
)

Array_With(_, ArgObj) => Array(ArgObj.Values*)

Format_With(_, ArgObj) {
    if (!HasProp(ArgObj, "Format")) {
        throw UnsetError("Requires .Format")
    }
    if (HasProp(ArgObj, "Values")) {
        return Format(ArgObj.Format, ArgObj.Values*)
    }
    return Format(ArgObj.Format)
}

Min_With(_, ArgObj) => Min(ArgObj.Values*)

Max_With(_, ArgObj) => Max(ArgObj.Values*)

ObjBindMethod_With(_, ArgObj) {
    Args := Array(unset, unset)
    if (!HasProp(ArgObj, "Obj")) {
        throw UnsetError("Requires .Obj")
    }
    if (HasProp(ArgObj, "Params")) {
        if (HasProp(ArgObj, "Values")) {
            return ObjBindMethod(ArgObj.Obj, ArgObj.Params, ArgObj.Values*)
        }
        return ObjBindMethod(ArgObj.Obj, ArgObj.Params)
    }
    if (HasProp(ArgObj, "Values")) {
        return ObjBindMethod(ArgObj.Obj, unset, ArgObj.Values*)
    }
    return ObjBindMethod(ArgObj.Obj)
}

NumGet_With(_, ArgObj) {
    if (HasProp(ArgObj, "Offset")) {
        return NumGet(ArgObj.Source, ArgObj.Offset, ArgObj.Type)
    }
    return NumGet(ArgObj.Source, ArgObj.Type)
}

StrGet_With(_, ArgObj) {
    if (HasProp(ArgObj, "Length")) {
        if (HasProp(ArgObj, "Encoding")) {
            return StrGet(ArgObj.Source, ArgObj.Length, ArgObj.Encoding)
        }
        return StrGet(ArgObj.Source, ArgObj.Length)
    }
    if (HasProp(ArgObj, "Encoding")) {
        return StrGet(ArgObj.Source, unset, ArgObj.Encoding)
    }
    return StrGet(ArgObj.Source)
}

Map_With(_, ArgObj) {
    return Map(ArgObj.Values*)
}

ComObjQuery_With(_, ArgObj) {
    if (HasProp(ArgObj, "SID")) {
        return ComObjQuery(ArgObj.ComObj, ArgObj.SID, ArgObj.IID)
    }
    return ComObjQuery(ArgObj.ComObj, ArgObj.IID)
}