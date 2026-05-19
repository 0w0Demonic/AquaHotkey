class Test_Primitives extends TestSuite
{
    static MathFunctionsAreEqual() {
        static GetProp := {}.GetOwnPropDesc

        GetProp(Primitive.Prototype, "ToFloat").Call.Assert(Eq(Float))
        GetProp(Primitive.Prototype, "Mod").Call.Assert(Eq(Mod))
    }
}