#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * File utilities.
 * 
 * @module  <IO/FileUtils>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_FileUtils extends AquaHotkey
{
    ;@region FileOpen
    class FileOpen {
        /**
         * Opens the standard input stream.
         * 
         * @returns {File}
         */
        static StdIn => this("*", "r")

        /**
         * Opens the standard output stream.
         * 
         * @returns {File}
         */
        static StdOut => this("*", "w")

        /**
         * Opens the standard error stream.
         * 
         * @returns {File}
         */
        static StdErr => this("**", "r")
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region File

    class File {
        /**
         * Enumerates the lines of the file.
         * 
         * The file object is closed after all elements have been enumerated.
         * 
         * @param   {Integer}  n  argument size of the enumerator
         * @returns {Enumerator}
         * @example
         * for LineNumber, Line in FileOpen("message.txt", "r") {
         *     MsgBox("Line " . LineNumber ": " . Line)
         * }
         * 
         * FileOpen("message.txt", "r").Stream().ForEach(MsgBox)
         */
        __Enum(n) {
            if (n > 1) {
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
         * @returns {String}
         * @example
         * FileObj.Name ; "C:\...\hello.txt"
         */
        Name {
            get {
                static BUFSIZE := 520 ; 2 * MAX_PATH
                static Buf := Buffer(BUFSIZE, 0)

                DllCall("GetFinalPathNameByHandle",
                    "Ptr", this.Handle,
                    "Ptr", Buf,
                    "UInt", Buf.Size,
                    "UInt", 0)
                
                FileName := SubStr(StrGet(Buf), 5) ; remove "\\?\"-prefix

                ; memoize result, because it is immutable
                this.DefineProp("Name", { Get: (_) => FileName })
                return FileName
            }
        }
    }
    ;@endregion
}

/**
 * Creates a new file stream.
 * 
 * @param   {String}   Pattern  file pattern
 * @param   {String?}  Mode     loop-files mode
 * @returns {Continuation}
 */
LoopFiles(Pattern, Mode := "F") {
    return Continuation.Cast(LoopFiles)

    LoopFiles(Downstream) {
        loop files Pattern, Mode {
            if (!Downstream(A_LoopFilePath)) {
                return
            }
        }
    }
}


/**
 * Separates a file name or URL into its name, directory, extension,
 * and drive.
 * 
 * @param   {String}  Str  a file name or URL
 * @returns {Object}
 * @example
 * ; {
 * ;     Name:      "Address List.txt",
 * ;     Dir:       "C:\My Documents",
 * ;     Ext:       "txt"
 * ;     NameNoExt: "Address List"
 * ;     Drive:     "C:"
 * ; }
 * Path("C:\My Documents\Address List.txt")
 */
Path(Str) {
    SplitPath(Str, &Name, &Dir, &Ext, &NameNoExt, &Drive)
    return {
        Name: Name,
        Dir: Dir,
        Ext: Ext,
        NameNoExt: NameNoExt,
        Drive: Drive
    }
}