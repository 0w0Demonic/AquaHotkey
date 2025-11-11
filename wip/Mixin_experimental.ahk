#Requires AutoHotkey v2.0
#Include <AquaHotkey>

class Enumerable1 {
    ForEach1(Action, Args*) {
        for V in this {
            Action(V?, Args*)
        }
        return this
    }
} 

class Enumerable2 {
    ForEach2(Value, Args*) {
        for A, B in this {
            Action(A?, B?, Args*)
        }
        return this
    }
}

class Widget {
    /**
     * @example
     * class Object
     * `- class (unnamed)
     *    |- ForEach1(Action, Args*) ; Enumerable1
     *    |- ForEach2(Action, Args*) ; Enumerable2
     *    `- class Widget
     */
    static __New() => AquaHotkey
        .CreateClass()
        .Backup(Enumerable1, Enumerable2)
        .Extend(this)
}

MsgBox(Widget().HasProp("ForEach1")) ; 1
MsgBox(Widget().HasProp("ForEach2")) ; 1
