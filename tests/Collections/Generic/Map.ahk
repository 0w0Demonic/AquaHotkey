
#Include <AquaHotkeyX>
#Include <AquaHotkey\src\Collections\Generic\Map>
#Include <AquaHotkey\tests\TestSuite>

class Test_GenericMap extends TestSuite {
    static Map_OfType_should_create_generic_map() {
        MapCls := Map.OfType(String, Array)
        MapCls.AssertType(Class)
        HasBase(MapCls, GenericMap).AssertEquals(true)
    }

    static Check_method_should_be_overridden() {
        MapCls := Map.OfType(String, String)
        (MapCls.Prototype.Check).AssertNotEquals(GenericMap.Prototype.Check)
    }

    ; TODO

    static Is_keyword_should_work() {
        MCls := Map.OfType(String, String)
        M := MCls()

        M.Is(Map.OfType(String, String)).AssertEquals(true)
    }

    static Is_keyword_should_work_with_traits() {
        MCls := Map.OfType(EMail, EMail)
        M := MCls()

        M.Is(Map.OfType(Email, Email))
            .AssertEquals(true)
    }

    static staticKeyType_should_return_class() {
        (Map.OfType(Buffer, Buffer)).KeyType
            .AssertEquals(Buffer)
    }

    static KeyType_should_return_class() {
        MapCls := (Map.OfType(Number, Number))
        M := MapCls()
        M.KeyType.AssertEquals(Number)
    }

    static staticValueType_should_return_class() {
        (Map.OfType(Integer, Integer)).ValueType
            .AssertEquals(Integer)
    }

    static ValueType_should_return_class() {
        MapCls := Map.OfType(Email, Any)
        M := MapCls()
        M.ValueType.AssertEquals(Any)
    }

    static generic_array_should_do_type_checking() {
        MapCls := Map.OfType(Number, String)
        M := MapCls()

        M[34] := "foo"
        M.Set(23, "bar")

        this.AssertThrows(() => M[12.4] := [1, 2, 3])
        this.AssertThrows(() => M.Set(12.4, [1, 2, 3]))
    }

    static __new_throws_on_bad_param_length() {
        this.AssertThrows(() => Map.OfType(Any, Any)(1))
    }

    ; TODO
    static should_support_traits() {
        M := (Map.OfType(Email, Callable))("ben.dover@gmail.com", MsgBox)
    }

    static should_throw_with_traits_contained() {
        this.AssertThrows(() => Map.OfType(Email, String)("boom!", "bar"))
    }

    static can_be_created_from_any_IMap() {
        Person := { name: String, age: Integer }

        MCls := HashMap.OfType(Person, Integer)
        M := MCls()

        M.Set({ name: "Jacob", age: 21 }, 34)
        M.Has({ name: "Jacob", age: 21 }).AssertEquals(true)
        this.AssertThrows(() => M.Set({ name: [1, 2], age: "invalid" }))
    }
}

/**
 * An email string.
 */
class Email extends String {
    static IsInstance(Val) => (Val is String)
        && (Val ~= "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
}