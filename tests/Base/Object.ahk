class Test_Object extends TestSuite
{
    static BindMethod() {
        Arr      := Array()
        ArrPush1 := Arr.BindMethod("Push", 1)
        Loop 5 {
            ArrPush1()
        }
        Arr.Join(" ").Assert(Eq("1 1 1 1 1"))
    }

    static SetBase() {
        BaseObj := Object
        Obj := Object().SetBase(BaseObj)
        HasBase(Obj, BaseObj).Assert(Eq(true))
    }

    static DefineConstant() {
        Obj := Object()
        Obj.DefineProp("Value", Property.Constant(42))
        Obj.Value.Assert(Eq(42))
    }

    static DefineGetter() {
        (Obj := Object()).Value := 2
        Obj.DefineProp("TwoTimesValue", Property.Getter((this) => (2 * this.Value)))
        Obj.TwoTimesValue.Assert(Eq(4))
    }

    static DefineGetterSetter() {
        static Getter(Instance) {
            return Instance.Value
        }
        static Setter(Instance, NewValue) {
            return Instance.Value := NewValue
        }
        (Obj := Object()).Value := 42
        Obj.DefineProp("Prop", Property.GetterSetter(Getter, Setter))
        Obj.Prop.Assert(Eq(42))
        Obj.Prop := 65
        Obj.Prop.Assert(Eq(65))
    }

    static DefineSetter() {
        static Set(Instance, Value) {
            Instance.Value := Value
        }

        Obj := Object()
        Obj.DefineProp("Prop", Property.Setter(Set))
        Obj.Prop := 54
        Obj.Value.Assert(Eq(54))
    }

    static DefineMethod() {
        static DoSomething(Instance) {
            return 42
        }

        Obj := Object()
        Obj.DefineProp("DoSomething", Property.Method(DoSomething))
        Obj.DoSomething().Assert(Eq(42))
    }

    static Method_OwnProps_equal_to_ObjOwnProps() {
        ({}.GetOwnPropDesc)(Any.Prototype, "OwnProps").Call
            .Assert(Eq(ObjOwnProps))
    }

    static Any_DefineProp_equal_to_Object_DefineProp() {
        GetProp := {}.GetOwnPropDesc
        GetProp(Any.Prototype, "DefineProp").Call
            .Assert(Eq(GetProp(Object.Prototype, "DefineProp").Call))
    }
}

