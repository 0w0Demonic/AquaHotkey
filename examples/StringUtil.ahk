#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%/../../AquaHotkey.ahk"

class StringUtil extends AquaHotkey {
    class String {
        Length => StrLen(this)

        __Item[n] => SubStr(this, n, 1)

        StartsWith(Prefix, CaseSense?) {
            return InStr(SubStr(this, 1, StrLen(Prefix)),
                         Prefix,
                         CaseSense?)
        }

        EndsWith(Suffix, CaseSense?) {
            return InStr(SubStr(this, -StrLen(Suffix)),
                         Suffix,
                         CaseSense?)
        }
    }
}

MsgBox(Format("
    (
    "foo".Length == {1}
    ("bar")[1] == {2}
    "Hello, world!".StartsWith("Hell") == {3}
    "Example".EndsWith("te") == {4}
    )",

    "foo".Length,
    ("bar")[1],
    "Hello, world!".StartsWith("Hell"),
    "Example".EndsWith("te")
))