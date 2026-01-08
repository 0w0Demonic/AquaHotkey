#Requires AutoHotkey v2.0
#Include "%A_LineFile%\..\..\Stream\Stream.ahk"

/**
 * Combines multiple enumerable objects (arrays, maps, etc.) into a single
 * enumerator of tuples.
 * 
 * The returned enumerator stops as soon as any of the enumerators has no
 * more values.
 * 
 * @param   {Any*}  Args  one or more enumerable values
 * @returns {Enumerator}
 */
Zip(Args*) {
    Enumers := Array()
    Enumers.Capacity := Args.Length
    for Arg in Args {
        if (HasProp(Arg, "__Enum")) {
            GetMethod(Arg, "__Enum")
            Enumers.Push(Arg.__Enum(1))
        } else {
            Enumers.Push(GetMethod(Arg))
        }
    }
    return ZipEnumer

    ZipEnumer(&Args*) {
        loop Args.Length {
            ; quit at the first enumerator that returns `false`
            if (!Enumers[A_Index](&Elem)) {
                return false
            }
            ; set value of output VarRef
            %Args[A_Index]% := (Elem?)
        }
        return true
    }
}

#Include <AquaHotkey>

class Test extends AquaHotkey {
    class Integer {
        Times(Fn) {
            GetMethod(Fn)
            loop this {
                Fn()
            }
            return this
        }
    }
    class String {
        Shout() => StrUpper(this) . "!!!"
    }
}

5.Times(() => MsgBox("Counting: #" . A_Index))
"ahk".Shout() ; "AHK!!!"

for A, B, C, D in Zip([1, 2], [3, 4], [5, 6], [7, 8]) {
    MsgBox(Format("{} {} {} {}", A, B, C, D))
}
