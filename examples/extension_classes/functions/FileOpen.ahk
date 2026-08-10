#Requires AutoHotkey v2
#Include <AquaHotkey\src\Core\AquaHotkey>

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
class Ext_FileOpen extends AquaHotkey
{
    ; extension: Ext_FileOpen.FileOpen >> FileOpen
    class FileOpen
    {
        static Read(FileName, Encoding?)      => this(FileName, "r", Encoding?)
        static Write(FileName, Encoding?)     => this(FileName, "w", Encoding?)
        static ReadWrite(FileName, Encoding?) => this(FileName, "rw", Encoding?)
        static Append(FileName, Encoding?)    => this(FileName, "a", Encoding?)
        static Handle(Handle, Encoding?)      => this(Handle, "h", Encoding?)

        static StdIn() => this("*", "r")
        static StdOut() => this("*", "w")
        static StdErr() => this("**", "w")
    }
}
