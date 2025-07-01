/**
 * AquaHotkey - Kwargs.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Kwargs.ahk
 */
class AquaHotkey_Kwargs extends AquaHotkey {
    class Class {
        With(ArgObj) {
            if (Type(ArgObj) != "Object") {
                throw TypeError("Expected an Object literal",, Type(ArgObj))
            }
            if (!HasProp(this, "Signature")) {
                throw UnsetError("Missing signature")
            }
            Sig := this.Signature
            if (!(Sig is Map)) {
                this.Signature := Sig
                Sig := this.Signature
            }
            Args := Array()
            Args.Length := Sig.MaxParams
            for ArgName, Value in ObjOwnProps(ArgObj) {
                Index := Sig[ArgName]
                if (Args.Has(Index)) {
                    throw ValueError("Alias already set",, ArgName)
                }
                Args[Index] := Value
            }
            return this(Args*)
        }
    }

    class Any {
        /**
         * To support named parameters, the `.With()` method is introduced
         * to bridge the gap. It lets you pass an object with key-value
         * pairs, effectively simulating keyword arguments.
         * 
         * To make it work, the target function must define a `.Signature`
         * string, which lists accepted parameter names and aliases.
         * 
         * For now, variadic arguments (`Args*`) aren't supported.
         * 
         * @example
         * ControlSend.Signature := "Keys/K, Control/Ctrl/Ctl/C, ..."
         * ControlSend.With({
         *     WinTitle: "ahk_exe notepad.exe",
         *     Ctrl: "Edit1",
         *     Keys: "foo"
         * })
         * 
         * @param   {Object}  ArgObj  object containing all arguments
         * @return  {Any}
         */
        With(ArgObj) {
            GetMethod(this)
            if (Type(ArgObj) != "Object") {
                throw TypeError("Expected an Object literal",, Type(ArgObj))
            }
            if (!HasProp(this, "Signature")) {
                throw UnsetError("Missing signature")
            }
            Sig := this.Signature
            if (!(Sig is Map)) {
                this.Signature := Sig
                Sig := this.Signature
            }
            Args := Array()
            Args.Length := Sig.MaxParams
            for ArgName, Value in ObjOwnProps(ArgObj) {
                Index := Sig[ArgName]
                if (Args.Has(Index)) {
                    throw ValueError("Alias already set",, ArgName)
                }
                Args[Index] := Value
            }
            return this(Args*)
        }

        Signature {
            get {
                return ""
            }
            set {
                Sig := value
                if (!IsObject(Sig)) {
                    Sig := StrSplit(Sig, ",", " ")
                }
                if (!(Sig is Array)) {
                    throw TypeError("Expected an Array",, Type(Sig))
                }
                ArgMap := Map()
                ArgMap.CaseSense := false
                ArgMap.MaxParams := Sig.Length
                for ArgNameList in Sig {
                    ArgNameList := Trim(ArgNameList)
                    if (IsObject(ArgNameList)) {
                        throw TypeError("Expected a String",, Type(ArgNameList))
                    }
                    Index := A_Index
                    for ArgName in StrSplit(ArgNameList, "/") {
                        ArgName := Trim(ArgName)
                        ArgMap[ArgName] := Index
                    }
                }
                Sig := ArgMap
                this.DefineProp("Signature", { Get: (_) => Sig })
            }
        }
    }

    static __New() {
        static SimpleMath := "Number/Value/x"
        static WinTitle_1stHalf := "WinTitle/WTtl, WinText/WTxt"
        static WinTitle_2ndHalf := "ExcludeTitle/ETtl/NoTitle,"
                                 . "ExcludeText/ETxt/NoText"
        static WinTitle := WinTitle_1stHalf . ", " . WinTitle_2ndHalf

        static ComObj := "ComObj/ComObject"
        static Size := "Bytes/Size/Length"
        static Pointer := "Ptr/Addr/Address"
        static Options := "Options/Opt"
        static Control := "Control/Ctrl/Ctl"
        static ControlWinTitle := Control . ", " . WinTitle
        static ControlIndex := "N/Index/Idx"
        static IndexControlWinTitle := ControlIndex . ", " . ControlWinTitle
        static Coordinates := "X, Y, Width/W, Height/H"
        static Drive := "Drive/DriveName"
        static DriveOrFilePath := Drive . "/Path/FilePath"

        static FilePattern := "FilePattern/FileName/FilePath"
        static SingleFile := "Filename/FilePath/Path"

        ; TODO do I need these?
        static SourcePattern := "SourcePattern/Source/From"
        static DestPattern := "DestPattern/Dest/To"


        if (this != AquaHotkey_Kwargs) {
            return
        }

        super.__New()

        for Function, Signature in Map(
                Abs, SimpleMath,
                ASin, SimpleMath,
                ACos, SimpleMath,
                ATan, SimpleMath,
                ; Array
                BlockInput, "OnOff/SendMouse/MouseMove",
                Buffer, Size . ", FillByte",
                CallbackCreate, "Function/Func/f, " . Options . ", "
                              . "ParamCount/MaxParams/Params",
                CallbackFree, "Address/Addr",
                CaretGetPos, "X, Y",
                Ceil, SimpleMath,
                Chr, SimpleMath,
                Click, "Options/Opt",
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
                ControlAddItem, "Str/String/Item, " . ControlWinTitle,
                ControlChooseIndex, ControlIndex . ", " . ControlWinTitle,
                ControlChooseString, "Str/String/Item, " . ControlWinTitle,
                ControlClick, Control
                            . "/Position/Pos, " . WinTitle_1stHalf
                            . ", WhichButton/Button/Key/Type"
                            . ", ClickCount/Clicks/Repeat/Amount/Times"
                            . ", " . Options
                            . WinTitle_2ndHalf,
                ControlDeleteItem, ControlIndex . ", " . ControlWinTitle,
                ControlFindItem, "Str/String/Item, " . ControlWinTitle,
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
                ControlSendText, "Keys, " . ControlWinTitle,
                ControlSetChecked, "Value, " . ControlWinTitle,
                ControlSetEnabled, "Value, " . ControlWinTitle,
                ControlSetStyle, "Value/Style, " . ControlWinTitle,
                ControlSetExStyle, "Value/Style/ExStyle, " . ControlWinTitle,
                ControlSetText, "Value/NewText/Text, " . ControlWinTitle,
                ControlShow, ControlWinTitle,
                ControlShowDropDown, ControlWinTitle,
                CoordMode, "TargetType/Type/Mode, RelativeTo/Value",
                Cos, SimpleMath,
                Critical, "Value/OnOff/Setting/Mode",
                DateAdd, "DateTime/Timestamp,"
                       . "Time/Difference/Duration/TimeSpan,"
                       . "Unit/Units/TimeUnit/TimeUnits",
                DateDiff, "DateTime/Timestamp,"
                        . "Time/Difference/Duration/TimeSpan,"
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
                EditPaste, "Str/String/Text, " . ControlWinTitle,
                EnvGet, "EnvVar/Name",
                EnvSet, "EnvVar/Name, Value",
                Exit, "ExitCode/Code",
                ExitApp, "ExitCode/Code",
                Exp, SimpleMath,
                FileAppend, "Text/Str/String, Filename/FilePath/Path, "
                          . Options,
                FileCopy, "Source/SourcePattern/From,"
                        . "Dest/DestPattern/To,"
                        . "Overwrite",
                FileCreateShortcut, "Target, LinkFile, WorkingDir, Args,"
                                  . "Description, IconFile, ShortcutKey,"
                                  . "IconNumber, RunState",
                FileDelete, FilePattern,
                FileEncoding, "Encoding",
                FileExist, FilePattern,
                FileInstall, "Source/From, Dest/To, Overwrite",
                FileGetAttrib, "Filename/FilePath/Path",
                FileGetShortcut, "LinkFile, Target, Dir, Args, Description,"
                               . "Icon, IconNum, RunState",
                FileGetSize, SingleFile . ", Units/In",
                FileGetTime, SingleFile . ", WhichTime/Mode/Type",
                FileGetVersion, SingleFile,
                FileMove, SourcePattern . ", " . DestPattern ", Overwrite",
                FileOpen, SingleFile . ", /Mode/Flags/"
                        . Options . ", Encoding",
                FileRead, SingleFile . ", " . Options,
                FileRecycle, FilePattern,
                FileRecycleEmpty, FilePattern,
                FileSelect, Options . ", RootDir/From/" . SingleFile
                          . ", Title, Filter",
                          
                FileSetAttrib, "Attributes/NewValue/Flags/Value, "
                             . FilePattern . ", Mode",
                FileSetTime, "Timestamp/Time/Value, " . FilePattern
                           . ", WhichTime/Type, Mode", ; TODO this is bad
                Float, SimpleMath . "/Value",
                Floor, SimpleMath,
                ; Format
                FormatTime, "Timestamp/Time/Value, Format",
                GetKeyName, "KeyName/Name/Key",
                GetKeyVK, "KeyName/Name/Key",
                GetKeySC, "KeyName/Name/Key",
                GetKeyState, "KeyName/Name/Key, Mode/Type",
                GetMethod, "Value, Name/MethodName/Method,"
                         . "ParamCount/MaxParams",
                GroupActivate, "Group/GroupName/Name, Mode/Type",
                GroupAdd, "Group/GroupName/Name, " . WinTitle,
                GroupClose, "Group/GroupName/Name, Mode/Type",
                GroupDeactivate, "Group/GroupName/Name, Mode/Type",
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
            )
        {
            (Object.Prototype.DefineProp)(Function, "Signature", {
                Get: Getter(Signature)
            })
        }
        static Getter(Obj) => (_) => Obj
    }
}