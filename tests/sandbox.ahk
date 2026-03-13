; << for quick one-off tests >>
#Requires AutoHotkey v2.0
#Include <AquaHotkey\src\Base\Primitives>
#Include <AquaHotkey\src\Base\Buffer>
#Include <AquaHotkey\src\Collections\BitSet>
#Include <AquaHotkey\src\Collections\ByteArray>
#DllLoad "sandbox.dll"

B   := Buffer(16, 0)
All := B.AsBitSet()
EAX := B.Slice(0,  4).AsBitSet()
EBX := B.Slice(4,  4).AsBitSet()
ECX := B.Slice(8,  4).AsBitSet()
EDX := B.Slice(12, 4).AsBitSet()

DllCall("sandbox\cpuid", "Ptr", B, "Int", 7, "Int", 0)
EBX.Join(", ").MsgBox()