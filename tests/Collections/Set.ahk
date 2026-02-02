#Include <AquaHotkeyX>

class Test_Set extends TestSuite {
    static FromMap_works_with_any_IMap() {
        S := Set.FromMap(HashMap(1, 2, 3, 4))
    }

    static Call_uses_regular_map() {
        Set(1, 2, 3, 4).M.Is(Map).AssertEquals(true)
    }

    static Add_returns_boolean() {
        S := Set()
        S.Add(1).AssertEquals(true)
        S.Add(1).AssertEquals(false)
    }

    static Clear() {
        S := Set(1, 2, 3, 4)
        S.Clear()
        S.Size.AssertEquals(0)
    }

    static Clone() {
        S := Set(1, 2, 3, 4)
        Copy := S.Clone()
        S.Add(5)

        Copy.Contains(5).AssertEquals(false)
    }

    static Delete_returns_boolean() {
        Set(1).Delete(1).AssertEquals(true)
        Set().Delete(1).AssertEquals(false)
    }

    static Contains_on_HashSet() {
        HashSet({ foo: "bar" }).Contains({ foo: "bar" })
                .AssertEquals(true)
    }

    static AsMap_returns_backing_map() {
        S := Set(1)
        M := S.AsMap()
        M.Set(2, true)

        S.Contains(2).AssertEquals(true)
    }

    static AsMap_returns_backing_map_clone() {
        S := Set(1)
        M := S.ToMap()
        M.Set(2, true)

        S.Contains(2).AssertEquals(false)
    }
}
