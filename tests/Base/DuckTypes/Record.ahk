class Test_Record extends TestSuite {
    static InstancesAreClasses() {
        Record(String, String).AssertType(Class)
    }

    static Equality() {
        Record(String, String).Assert(Eq(Record(String, String)))
    }

    static IsHashable() {
        Hash() => Record(String, String).HashCode()
        Hash().Assert(Eq(Hash()))
    }

    static OnlyAcceptsPlainObjects() {
        Assert(!Record(String, String).IsInstance({ base: { base: {} } }))
    }

    static InstanceChecks() {
        Obj := { foo: "bar" }
        T := Record("foo", String)

        Assert(Obj.Is(T))
    }

    static NonValuePropsAreIgnored() {
        Obj := { foo: "bar" }
        DefineProp(Obj, "baz", { Get: (_) => "qux" })

        T := Record("foo", "bar")
        Assert(Obj.Is(T))
    }

    static Subtypes() {
        A := Record(String, Number)
        B := Record(String, Integer)

        Assert(A.CanCastFrom(B))
    }
}