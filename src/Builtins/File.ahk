class AquaHotkey_File extends AquaHotkey {
/**
 * AquaHotkey - File.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/File.ahk
 */
class File {
    /**
     * Enumerates the lines of the file.
     * 
     * The file object is closed after all elements have been enumerated.
     * 
     * @example
     * for LineNumber, Line in FileOpen("message.txt", "r") {
     *     MsgBox("Line " . LineNumber ": " . Line)
     * }
     * 
     * FileOpen("message.txt", "r").Stream().ForEach(MsgBox)
     * 
     * @param   {Integer}  n  argument size of the enumerator
     * @returns {Enumerator}
     */
    __Enum(n) {
        if (n == 1) {
            return Enumer1
        }
        LineNumber := 0
        return Enumer2

        Enumer1(&Line) {
            if (this.AtEOF) {
                this.Close()
                return false
            }
            Line := this.ReadLine()
            return true
        }

        Enumer2(&OutLineNumber, &Line) {
            if (this.AtEOF) {
                this.Close()
                return false
            }
            OutLineNumber := ++LineNumber
            Line := this.ReadLine()
            return true
        }
    }

    /**
     * Returns the file name of this file object.
     * 
     * @example
     * FileObj.Name ; "C:\...\hello.txt"
     * 
     * @returns {String}
     */
    Name {
        Get {
            static BUFSIZE := 520 ; 2 * MAX_PATH
            static Buf := Buffer(BUFSIZE, 0)

            DllCall("GetFinalPathNameByHandle",
                "Ptr", this.Handle,
                "Ptr", Buf,
                "UInt", Buf.Size,
                "UInt", 0)
            
            FileName := SubStr(StrGet(Buf), 5) ; remove "\\?\"-prefix

            ; memoize result, because it is immutable
            this.DefineProp("Name", { Get: (Instance) => FileName })
            return FileName
        }
    }
} ; class File
} ; class AquaHotkey_File extends AquaHotkey