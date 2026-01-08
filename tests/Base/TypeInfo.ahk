
class Test_TypeInfo extends TestSuite
{
    static __Call_ShouldThrow() {
        this.AssertThrows(() => String.UnsetProperty())
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

    static Class_Name_Should_Be_String() {
        (String.Name).AssertEquals("String")
    }
}