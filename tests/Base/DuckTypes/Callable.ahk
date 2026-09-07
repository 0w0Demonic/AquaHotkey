class Test_Callable extends TestSuite {
    static MsgBox_Is_Callable() {
        MsgBox.Is(Callable).Assert(Eq(true))
    }

    static Anything_Can_Be_Callable() {
        if (ObjHasOwnProp(Integer.Prototype, "Call")) {
            return ; skip
        }
        DefineProp(Integer.Prototype, "Call", { Call: (x) => x })
        (1).Is(Callable).Assert(Eq(true))
        DeleteProp(Integer.Prototype, "Call")
    }

    static UnsetIsNotCallable() {
        Callable.IsInstance(unset).Assert(Eq(false))
    }

    static FuncIsSubtypeOfCallable() {
        ; because every instance (Func.Prototype) is callable (Func.Prototype.Call)
        Callable.CanCastFrom(Func).Assert(Eq(true))
    }

    static ClassWithPrototypeCallIsSubtype() {
        Callable.CanCastFrom({
            base: Object,
            Prototype: {
                base: Object.Prototype,
                __Class: "Custom",
                Call: Type
            }
        }).Assert(Eq(true))
    }
}
