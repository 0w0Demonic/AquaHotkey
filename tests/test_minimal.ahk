; << for quick one-off tests >>
#Requires AutoHotkey v2.0
#Include <AquaHotkeyX>

class Version {
    __New(Major, Minor, Patch) {
        this.Major := Major
        this.Minor := Minor
        this.Patch := Patch
    }

    Serialize(Output, Refs) {
        super.Serialize(Output, Refs)
        Output.WriteInt64(this.Major)
        Output.WriteInt64(this.Minor)
        Output.WriteInt64(this.Patch)
    }

    Deserialize(Input, Refs) {
        this.Major := Input.ReadInt64()
        this.Minor := Input.ReadInt64()
        this.Patch := Input.ReadInt64()
    }
}

/*
DllCall("QueryPerformanceFrequency", "Int64*", &Freq := 0)
DllCall("QueryPerformanceCounter", "Int64*", &t1 := 0)

F := FileOpen("result.txt", "w")
V := Version(5, 2, 12)
loop 10000 {
    F.WriteObject(V)
}
F := FileOpen("result.txt", "r")
loop 10000 {
    F.ReadObject(&Output)
}
DllCall("QueryPerformanceCounter", "Int64*", &t2 := 0)
Delta := (t2 - t1)
TimeMs := Delta / Freq * 1000
MsgBox(TimeMs)
*/

A := Object()
B := Object()
A.Value := B
B.Value := A

FileOpen("result.txt", "w").WriteObject(Uri("https://www.github.com"))
FileOpen("result.txt", "r").ReadObject(&Obj)

MsgBox(Type(Obj))
