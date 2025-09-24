/**
 * AquaHotkey - ComValue.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/ComValue.ahk
 */
class AquaHotkey_FileUtils extends AquaHotkey {
;@region String
class String {
    /**
     * Reads the contents of the file this string leads to.
     * 
     * @example
     * "message.txt".FileRead()
     * 
     * @param   {String?}  Options  additional `FileRead()` options
     * @returns {String}
     */ 
    FileRead(Options?) => FileRead(this, Options?)

    /**
     * Appends this string to the file `FileName`.
     * 
     * @example
     * "Hello, world!".FileAppend("message.txt")
     * 
     * @param   {String?}  FileName  name of the file
     * @param   {String?}  Options   additional `FileAppend()` options
     * @returns {this}
     */
    FileAppend(FileName?, Options?) {
        FileAppend(this, FileName?, Options?)
        return this
    }
    
    /**
     * Overwrites the file `FileName` with this string (Previous file contents
     * are lost!).
     * 
     * @example
     * "Hello, world!".FileOverwrite("message.txt")
     * 
     * @param   {String}  FileName  name of the file
     * @returns {this}
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
     * @example
     * FileObj := "message.txt".FileOpen("r")
     * 
     * @param   {Primitive?}  Flags     desired access mode
     * @param   {Primitive?}  Encoding  file encoding
     * @returns {File}
     */
    FileOpen(Flags := "r", Encoding?) => FileOpen(this, Flags, Encoding?)

    /**
     * Separates a file name or URL into its name, directory, extension,
     * and drive.
     * 
     * @example
     * ; {
     * ;     Name:      "Address List.txt",
     * ;     Dir:       "C:\My Documents",
     * ;     Ext:       "txt"
     * ;     NameNoExt: "Address List"
     * ;     Drive:     "C:"
     * ; }
     * "C:\My Documents\Address List.txt".SplitPath()
     * 
     * @returns {Object}
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
     * @example
     * "C:\*".FindFiles("D") ; ["C:\Users", "C:\Windows", ...]
     * 
     * @param   {String?}  Mode       file-loop mode
     * @param   {Func?}    Condition  the given condition
     * @param   {Func?}    Mapper     function that retrieves a value
     * @returns {Array}
     */
    FindFiles(Mode := "FR", Condition := FindAll, Mapper := GetFilePath) {
        static FindAll()     => true
        static GetFilePath() => A_LoopFilePath

        (GetMethod(Condition) && GetMethod(Mapper))
        Result := Array()
        Loop Files, this, Mode {
            (Condition() && Result.Push(Mapper()))
        }
        return Result
    }
} ; class String
;@endregion

;@region File
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
;@endregion
} ; class AquaHotkey_FileUtils extends AquaHotkey