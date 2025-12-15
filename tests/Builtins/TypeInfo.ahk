class TypeInfo {
    static __Call_ShouldThrow() {
        TestSuite.AssertThrows(() => String.UnsetProperty())
    }

    static Class_ForName() {
        Class.ForName("String").AssertEquals(String)
    }

    static Class_ForName_Nested() {
        Class.ForName("Gui.ActiveX").AssertEquals(Gui.ActiveX)
    }

    static __Call_ShouldResolve_Chr() {
        ; good enough
        65.Chr().AssertCsEquals("A")
    }

    static Type() {
        "Hello world".Type.AssertEquals("String")
    }

    static Class_ShouldResolve_String() {
        "Hello world!".Class.AssertEquals(String)
    }

    static Class_PrototypeShouldResolve_String() {
        (String.Prototype).Class.AssertEquals(String)
    }

    static Class_PrototypeShouldResolve_GuiButton() {
        (Gui.Button.Prototype).Class.AssertEquals(Gui.Button)
    }
}