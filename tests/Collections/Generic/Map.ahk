
#Include <AquaHotkeyX>
#Include <AquaHotkey\tests\TestSuite>

class Test_GenericMap extends TestSuite {
    static Map_OfType_should_create_generic_map() {
        MapCls := Map.OfType(String, Array)
        MapCls.AssertType(Class)
        HasBase(MapCls, GenericMap).Assert(Eq(true))
    }

    static Is_keyword_should_work() {
        MCls := Map.OfType(String, String)
        M := MCls()

        M.Is(Map.OfType(String, String)).Assert(Eq(true))
    }

    static Is_keyword_should_work_with_traits() {
        MCls := Map.OfType(EMail, EMail)
        M := MCls()

        M.Is(Map.OfType(Email, Email))
            .Assert(Eq(true))
    }

    static staticKeyType_should_return_class() {
        (Map.OfType(Buffer, Buffer)).KeyType
            .Assert(Eq(Buffer))
    }

    static KeyType_should_return_class() {
        MapCls := (Map.OfType(Number, Number))
        M := MapCls()
        M.KeyType.Assert(Eq(Number))
    }

    static staticValueType_should_return_class() {
        (Map.OfType(Integer, Integer)).ValueType
            .Assert(Eq(Integer))
    }

    static ValueType_should_return_class() {
        MapCls := Map.OfType(Email, Any)
        M := MapCls()
        M.ValueType.Assert(Eq(Any))
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
        M.Has({ name: "Jacob", age: 21 }).Assert(Eq(true))
        this.AssertThrows(() => M.Set({ name: [1, 2], age: "invalid" }))
    }

    static static_eq_based_on_fields() {
        A := Map.OfType(String, Integer)
        B := Map.OfType(String, Integer)

        A.Eq(B).Assert(Eq(true))
    }

    static static_eq_wrong_map_type() {
        A := HashMap.OfType(String, Integer)
        B := Map.OfType(String, Integer) ; HashMap != Map

        A.Eq(B).Assert(Eq(false))
    }

    static static_eq_supports_object_patterns() {
        A := Map.OfType(Integer, { name: String })
        B := Map.OfType(Integer, { name: String })

        A.Eq(B).Assert(Eq(true)) ; because ({ ... }).Eq({ ... })
    }
    
    static static_hashcode_same_when_equal() {
        A := Map.OfType(String, Integer)
        B := Map.OfType(String, Integer)

        (A.HashCode()).Assert(Eq(B.HashCode()))
    }
}

/**
 * An email string.
 */
class Email extends String {
    static IsInstance(Val) => (Val is String)
        && (Val ~= "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
}