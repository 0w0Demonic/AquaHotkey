class Test_HashSet extends TestSuite {
    static ISet_can_cast_from_HashSap() {
        HasBase(HashSet, ISet).AssertEquals(true)
        ISet.CanCastFrom(HashSet).AssertEquals(true)
    }

    static ISet_can_create_HashSet_instances() {
        S := ISet.Create(HashSet())
    }

    static ISet_create_works_from_HashSet_class() {
        S := HashSet.Create()
    }

    static relies_on_hashcode_and_eq() {
        S := HashSet()
        S.Add({ name: "Sasha" }).AssertEquals(true)
        S.Add({ name: "Sasha" }).AssertEquals(false)

        ; test is good enough; HashSet is merely a wrapper over HashMap
    }

    static is_sizeable() {
        HashSet().Is(Sizeable).AssertEquals(true)
    }

    static is_enumerable() {
        HasMethod(HashSet(), "__Enum").AssertEquals(true)
    }

    static asMap_returns_HashMap() {
        HashSet().AsMap().Is(HashMap).AssertEquals(true)
    }
}