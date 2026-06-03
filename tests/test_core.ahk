#Requires AutoHotkey v2.0
#Include <AquaHotkey>

class A1 {
    class A2 {
        static PreviousMethod() {

        }
    }
}

class Test1 extends AquaHotkey {
    class A1 {
        class A2 {
            static Method() {

            }
        }
        class C1 {

        }
    }
}

(Test1)
if (!ObjHasOwnProp(A1.A2, "Method")) {
    throw Error("Test 1: did not transfer 'Method'")
}
if (!ObjHasOwnProp(A1.A2, "PreviousMethod")) {
    throw Error("Test 1: 'PreviousMethod' was overwritten")
}

MsgBox("success")
