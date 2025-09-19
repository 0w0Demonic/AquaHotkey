#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%/../../AquaHotkey.ahk"

/**
 * @file
 * @name FileOpen
 * @description
 * Adds descriptive helper methods to the built-in `FileOpen()`.
 * 
 * @example
 * FileObj := FileOpen.Append("example.txt")
 * StdOut  := FileOpen.StdOut()
 */
class Ext_FileOpen extends AquaHotkey {
    class FileOpen {
        static Read(FileName, Encoding?) {
            return this(FileName, "r", Encoding?)
        }

        static Write(FileName, Encoding?) {
            return this(FileName, "w", Encoding?)
        }

        static ReadWrite(FileName, Encoding?) {
            return this(FileName, "rw", Encoding?)
        }

        static Append(FileName, Encoding?) {
            return this(FileName, "a", Encoding?)
        }

        static Handle(FileHandle, Encoding?) {
            return this(FileHandle, "h", Encoding?)
        }

        static StdIn() {
            return this("*", "r")
        }

        static StdOut() {
            return this("*", "w")
        }

        static StdErr() {
            return this("**", "w")
        }
    }
}