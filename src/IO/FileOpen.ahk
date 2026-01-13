
class AquaHotkey_FileOpen extends AquaHotkey {
    class FileOpen {
        static StdIn() => this("*", "r")
        static StdOut() => this("*", "w")
        static StdErr() => this("**", "w")
    }
}
