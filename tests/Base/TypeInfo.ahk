class Test_TypeInfo extends TestSuite
{
    static __Call_ShouldThrow() {
        this.AssertThrows(() => String.UnsetProperty())
    }

    static Class_ForName() {
        Class.ForName("String").Assert(Eq(String))
    }

    static Class_ForName_Nested() {
        Class.ForName("Gui.ActiveX").Assert(Eq(Gui.ActiveX))
    }

    static Type() {
        "Hello world".Type.Assert(Eq("String"))
    }

    static Class_ShouldResolve_String() {
        "Hello world!".Class.Assert(Eq(String))
    }

    static Class_PrototypeShouldResolve_String() {
        (String.Prototype).Class.Assert(Eq(String))
    }

    static Class_PrototypeShouldResolve_GuiButton() {
        (Gui.Button.Prototype).Class.Assert(Eq(Gui.Button))
    }

    static Class_Name_Should_Be_String() {
        (String.Name).AssertType(String).Assert(Eq("String"))
    }

    static Hierarchy() {
        (Object.Hierarchy).Eq([
                Object,
                Any,
                Class.Prototype,
                Object.Prototype,
                Any.Prototype ])
            .Assert(Eq(true))
    }

    static Hierarchy_with_plain_objects() {
        BaseObj := Object()
        Obj := Object()
        ObjSetBase(Obj, BaseObj)

        (Obj.Hierarchy).Eq([ Obj, BaseObj, Object.Prototype, Any.Prototype ])
                .Assert(Eq(true))
    }

    static Bases() {
        (Object.Bases).Eq([
                Any,
                Class.Prototype,
                Object.Prototype,
                Any.Prototype ])
            .Assert(Eq(true))
    }

    static Bases_with_plain_objects() {
        BaseObj := Object()
        Obj := Object()
        ObjSetBase(Obj, BaseObj)

        (Obj.Bases).Eq([ BaseObj, Object.Prototype, Any.Prototype ])
                .Assert(Eq(true))
    }
}