class AquaHotkey_FileOpen extends AquaHotkey {
/**
 * AquaHotkey - FileOpen.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Functions/FileOpen.ahk
 */
class FileOpen {
    static StdIn()        => this("*", "r")
    static StdOut()       => this("*", "w")
    static StdErr()       => this("**", "w")

    class AccessMode extends UninstantiableClass {
        static READ       => 0x0
        static WRITE      => 0x1
        static APPEND     => 0x2
        static READ_WRITE => 0x3
        static HANDLE     => "h"
    }

    class SharingMode extends UninstantiableClass {
        static READ       => 0x100
        static WRITE      => 0x200
        static DELETE     => 0x300
    }

    class EOLOption extends UninstantiableClass {
        static N          => "`n"
        static R          => "`r"
    }
} ; class FileOpen
} ; class AquaHotkey_FileOpen extends AquaHotkey