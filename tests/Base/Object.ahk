class Object {
    static BindMethod() {
        Arr      := Array()
        ArrPush1 := Arr.BindMethod("Push", 1)
        Loop 5 {
            ArrPush1()
        }
        Arr.Join(" ").AssertEquals("1 1 1 1 1")
    }

    static SetBase() {
        BaseObj := Object
        Obj := Object().SetBase(BaseObj)
        HasBase(Obj, BaseObj).AssertEquals(true)
    }

    static DefineConstant() {
        Obj := Object()
        Obj.DefineConstant("Value", 42)
        Obj.Value.AssertEquals(42)
    }

    static DefineGetter() {
        (Obj := Object()).Value := 2
        Obj.DefineGetter("TwoTimesValue", (Instance) => 2 * Instance.Value)
        Obj.TwoTimesValue.AssertEquals(4)
    }

    static DefineGetterSetter() {
        static Getter(Instance) {
            return Instance.Value
        }
        static Setter(Instance, NewValue) {
            return Instance.Value := NewValue
        }
        (Obj := Object()).Value := 42
        Obj.DefineGetterSetter("Prop", Getter, Setter)
        Obj.Prop.AssertEquals(42)
        Obj.Prop := 65
        Obj.Prop.AssertEquals(65)
    }

    static DefineSetter() {
        static Setter(Instance, Value) {
            Instance.Value := Value
        }

        (Obj := Object()).DefineSetter("Prop", Setter)
        Obj.Prop := 54
        Obj.Value.AssertEquals(54)
    }

    static DefineMethod() {
        static DoSomething(Instance) {
            return 42
        }

        (Obj := Object()).DefineMethod("DoSomething", DoSomething)
        Obj.DoSomething().AssertEquals(42)
    }
}

