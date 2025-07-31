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
     * @return  {Enumerator}
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
     * Returns a string representation of this file, consisting of file name,
     * position of file pointer, encoding and the system file handle.
     * @example
     * 
     * ; "File { Name: C:\...\foo.txt, Pos: 0, Encoding: UTF-8, Handle: 362 }"
     * MyFile.ToString()
     * 
     * @return  {String}
     */
    ToString() {
        Pattern := "File{{} Name: {}, Pos: {}, Encoding: {}, Handle: {} {}}"
        return Format(Pattern, this.Name, this.Pos, this.Encoding, this.Handle)
    }

    /**
     * Returns the file name of this file object.
     * 
     * @example
     * FileObj.Name ; "C:\...\hello.txt"
     * 
     * @return  {String}
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