
class Test_Eq extends TestSuite {
    static UnsetEqualsUnset() {
        Any.Eq(unset, unset).AssertEquals(true)
    }

    static Any() {
        Num := 42
        Num.Eq(Num).AssertEquals(true)
    }

    static Array() {
        Arr := Array(1, 2, 3)
        Arr.Eq(Array(1, 2, 3)).AssertEquals(true)

        Arr.Eq(Array(3, 2, 1)).AssertEquals(false)
    }

    static Array_supports_unset() {
        Arr := () => Array(unset, unset, 1)

        Arr().Eq(Arr()).AssertEquals(true)
    }

    static Object() {
        ({ foo: "bar" }).Eq({ foo: "bar" }).AssertEquals(true)
    }

    static Object_must_share_same_base() {
        BaseObj := Object()
        Obj := Object()
        ObjSetBase(Obj, BaseObj)

        Other := Object()
        Obj.Eq(Other).AssertEquals(false)
    }

    static Object_props_are_case_insensitive() {
        ({ foo: "bar" }).Eq({ FOO: "bar" }).AssertEquals(true)
    }

    static Object_ignores_0_param_getter() {
        Obj := Object().DefineProp("foo", { Get: (_) => "bar" })

        Obj.Eq({ foo: "bar" }).AssertEquals(false)
    }

    static Object_must_share_entire_prop_set() {
        BaseObj := { foo: "bar" }
        Obj := { baz: "qux" }

        ObjSetBase(Obj, BaseObj)
        Obj.Eq({ baz: "qux" }).AssertEquals(false)
    }

    static Object_propset_shares_inheritance() {
        BaseObj := { foo: "bar" }
        Obj := { baz: "qux" }

        ObjSetBase(Obj, BaseObj)

        Obj.Eq({ foo: "bar", baz: "qux" }).AssertEquals(false)
    }

    static String_is_case_insensitive() {
        "bar".Eq("BAR").AssertEquals(true)
    }

    static Class_eq_class() {
        String.Eq(String).AssertEquals(true)
    }

    static Class_eq_a_b() {
        String.Eq("", "").AssertEquals(true)
    }

    static Class_eq_a_b_supports_unset() {
        String.Eq(unset, unset).AssertEquals(true)
    }

    static Class_eq_a_b_type_checking() {
        this.AssertThrows(() => String.Eq([1, 2], [1, 2]))
    }

    static Class_eq_prop_is_2_param() {
        Eq := String.Eq

        GetMethod(Eq)
        Eq.MaxParams.AssertEquals(2)
    }

    static Class_eq_throws_on_too_many_params() {
        this.AssertThrows(() => String.Eq("a", "b", "c"))
    }

    static ByReference_should_exist() {
        Buffer.Prototype.AssertHasOwnProp("Eq")
    }

    static Map() {
        M() => Map(1, 2)
        M().Eq(M()).AssertEquals(true)
    }

    static VarRef_based_on_inner_value() {
        Val := "foo"

        Ref1 := &Val
        Ref2 := &Val

        Ref1.Eq(Ref2).AssertEquals(true)
    }

    static ComValue() {
        C() => ComValue(0x14, 1324)
        C().Eq(C()).AssertEquals(true)
    }

    static ComObjArray_is_by_reference() {
        Arr() => ComObjArray(0x08, 8)

        A := Arr()
        A.Eq(A).AssertEquals(true)

        Arr().Eq(Arr()).AssertEquals(false)
    }
}