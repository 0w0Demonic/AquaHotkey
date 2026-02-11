class Test_HashSet extends TestSuite {
    static ISet_can_cast_from_HashSap() {
        HasBase(HashSet, ISet).Assert(Eq(true))
        ISet.CanCastFrom(HashSet).Assert(Eq(true))
    }

    static ISet_can_create_HashSet_instances() {
        S := ISet.Create(HashSet())
    }

    static ISet_create_works_from_HashSet_class() {
        S := HashSet.Create()
    }

    static relies_on_hashcode_and_eq() {
        S := HashSet()
        S.Add({ name: "Sasha" }).Assert(Eq(true))
        S.Add({ name: "Sasha" }).Assert(Eq(false))

        ; test is good enough; HashSet is merely a wrapper over HashMap
    }

    static is_enumerable() {
        HasMethod(HashSet(), "__Enum").Assert(Eq(true))
    }

    static asMap_returns_HashMap() {
        HashSet().AsMap().Is(HashMap).Assert(Eq(true))
    }
}