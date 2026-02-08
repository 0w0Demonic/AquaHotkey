
class Test_Eq extends TestSuite {
    static UnsetEqualsUnset() {
        Any.Equals(unset, unset).Assert(Eq(true))
    }

    static Any() {
        Num := 42
        Num.Eq(Num).Assert(Eq(true))
    }

    static Array() {
        Arr := Array(1, 2, 3)
        Arr.Eq(Array(1, 2, 3)).Assert(Eq(true))

        Arr.Eq(Array(3, 2, 1)).Assert(Eq(false))
    }

    static Array_supports_unset() {
        Arr := () => Array(unset, unset, 1)

        Arr().Eq(Arr()).Assert(Eq(true))
    }

    static Object() {
        ({ foo: "bar" }).Eq({ foo: "bar" }).Assert(Eq(true))
    }

    static Object_must_share_same_base() {
        BaseObj := Object()
        Obj := Object()
        ObjSetBase(Obj, BaseObj)

        Other := Object()
        Obj.Eq(Other).Assert(Eq(false))
    }

    static Object_props_are_case_insensitive() {
        ({ foo: "bar" }).Eq({ FOO: "bar" }).Assert(Eq(true))
    }

    static Object_ignores_0_param_getter() {
        Obj := Object().DefineProp("foo", { Get: (_) => "bar" })

        Obj.Eq({ foo: "bar" }).Assert(Eq(false))
    }

    static Object_must_share_entire_prop_set() {
        BaseObj := { foo: "bar" }
        Obj := { baz: "qux" }

        ObjSetBase(Obj, BaseObj)
        Obj.Eq({ baz: "qux" }).Assert(Eq(false))
    }

    static Object_propset_shares_inheritance() {
        BaseObj := { foo: "bar" }
        Obj := { baz: "qux" }

        ObjSetBase(Obj, BaseObj)

        Obj.Eq({ foo: "bar", baz: "qux" }).Assert(Eq(false))
    }

    static String_is_case_sensitive() {
        "bar".Eq("BAR").Assert(Eq(false))
    }

    static Class_eq_class() {
        String.Eq(String).Assert(Eq(true))
    }

    static Class_eq_a_b() {
        String.Equals("", "")
    }

    static Class_eq_a_b_supports_unset() {
        String.Equals(unset, unset).Assert(Eq(true))
    }

    static Class_eq_a_b_type_checking() {
        this.AssertThrows(() => String.Equals([1, 2], [1, 2]))
    }

    static Class_eq_prop_is_2_param() {
        Fn := String.Eq

        GetMethod(Eq)
        Fn.MaxParams.Assert(Eq(2))
    }

    static Class_eq_throws_on_too_many_params() {
        this.AssertThrows(() => String.Equals("a", "b", "c"))
    }

    static ByReference_should_exist() {
        Buffer.Prototype.Assert(ObjHasOwnProp, "Eq")
    }

    static Map() {
        M() => Map(1, 2)
        M().Eq(M()).Assert(Eq(true))
    }

    static VarRef_based_on_inner_value() {
        Val := "foo"

        Ref1 := &Val
        Ref2 := &Val

        Ref1.Eq(Ref2).Assert(Eq(true))
    }

    static ComValue() {
        C() => ComValue(0x14, 1324)
        C().Eq(C()).Assert(Eq(true))
    }

    static ComObjArray_is_by_reference() {
        Arr() => ComObjArray(0x08, 8)

        A := Arr()
        A.Eq(A).Assert(Eq(true))
    }
}
