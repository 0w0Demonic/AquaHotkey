#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%/../../AquaHotkey.ahk"

class Ext_FileOpen extends AquaHotkey {
    class FileOpen {
        static Read(FileName, Encoding?)      => this(FileName, "r",  Encoding?)
        static Write(FileName, Encoding?)     => this(FileName, "w",  Encoding?)
        static ReadWrite(FileName, Encoding?) => this(FileName, "rw", Encoding?)
        static Append(FileName, Encoding?)    => this(FileName, "a",  Encoding?)
    }
}

FileObj := FileOpen.Append(A_LineFile)
FileObj.Write("`r`n; Testing...")
FileObj.Close()
; Testing...
; Testing...