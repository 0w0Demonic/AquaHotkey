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
    ;@region String

    class String {
        /**
         * Reads the contents of the file this string leads to.
         * 
         * @param   {String?}  Options  additional `FileRead()` options
         * @returns {String}
         * @example
         * "message.txt".FileRead()
         */ 
        FileRead(Options?) => FileRead(this, Options?)

        /**
         * Appends this string to the file `FileName`.
         * 
         * @param   {String?}  FileName  name of the file
         * @param   {String?}  Options   additional `FileAppend()` options
         * @returns {this}
         * @example
         * "Hello, world!".FileAppend("message.txt")
         */
        FileAppend(FileName?, Options?) {
            FileAppend(this, FileName?, Options?)
            return this
        }
        
        /**
         * Overwrites the file `FileName` with this string (Previous file contents
         * are lost!).
         * 
         * @param   {String}  FileName  name of the file
         * @returns {this}
         * @example
         * "Hello, world!".FileOverwrite("message.txt")
         */
        FileOverwrite(FileName) {
            OutputFile := FileOpen(FileName, "w")
            OutputFile.Write(this)
            OutputFile.Close()
            return this
        }

        /**
         * Opens a file with the string being treated as file path.
         * 
         * @param   {Primitive?}  Flags     desired access mode
         * @param   {Primitive?}  Encoding  file encoding
         * @returns {File}
         * @example
         * FileObj := "message.txt".FileOpen("r")
         */
        FileOpen(Flags := "r", Encoding?) => FileOpen(this, Flags, Encoding?)

        /**
         * Separates a file name or URL into its name, directory, extension,
         * and drive.
         * 
         * @returns {Object}
         * @example
         * ; {
         * ;     Name:      "Address List.txt",
         * ;     Dir:       "C:\My Documents",
         * ;     Ext:       "txt"
         * ;     NameNoExt: "Address List"
         * ;     Drive:     "C:"
         * ; }
         * "C:\My Documents\Address List.txt".SplitPath()
         */
        SplitPath() {
            SplitPath(this, &Name, &Dir, &Ext, &NameNoExt, &Drive)
            return {
                Name: Name,
                Dir: Dir,
                Ext: Ext,
                NameNoExt: NameNoExt,
                Drive: Drive
            }
        }

        ; TODO change return type into a Continuation?
        ;      (... or remove)

        /**
         * Enumerates contents of a file-loop using the string as file pattern,
         * collecting results into an array.
         * 
         * ---
         * 
         * `Condition` filters elements based on built-in file-loop variables.
         * 
         * ```ahk
         * () => InStr(A_LoopFileFullPath, "foo")
         * ```
         * 
         * ----
         * 
         * `Mapper` produces a final result to be collected into the array.
         * 
         * ```ahk
         * () => A_LoopFileFullPath
         * ```
         * 
         * ----
         * 
         * @param   {String?}  Mode       file-loop mode
         * @param   {Func?}    Condition  the given condition
         * @param   {Func?}    Mapper     function that retrieves a value
         * @returns {Array}
         * @example
         * "C:\*".FindFiles("D") ; ["C:\Users", "C:\Windows", ...]
         */
        FindFiles(Mode := "FR", Condition := FindAll, Mapper := GetFilePath) {
            static FindAll()     => true
            static GetFilePath() => A_LoopFilePath

            (GetMethod(Condition) && GetMethod(Mapper))
            Result := Array()
            loop files, this, Mode {
                (Condition() && Result.Push(Mapper()))
            }
            return Result
        }
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

