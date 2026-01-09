
#Include <AquaHotkeyX>
#Include <AquaHotkey\src\Collections\Generic\Map>
#Include <AquaHotkey\tests\TestSuite>

class Test_GenericMap extends TestSuite {
    static Class_MappedTo_should_throw() {
        this.AssertThrows(() => String.MappedTo("example"))
    }

    static Class_MappedTo_should_create_generic_map() {
        MapCls := String.MappedTo(String)
        MapCls.AssertType(Class)
        HasBase(MapCls, GenericMap).AssertEquals(true)
    }

    static Map_OfType_should_create_generic_map() {
        MapCls := Map.OfType(String, Array)
        MapCls.AssertType(Class)
        HasBase(MapCls, GenericMap).AssertEquals(true)
    }

    static Check_method_should_be_overridden() {
        MapCls := Map.OfType(String, String)
        (MapCls.Prototype.Check).AssertNotEquals(GenericMap.Prototype.Check)
    }

    static Is_keyword_should_work() {
        (Map.OfType(String, String)() is Map.OfType(String, String))
                .AssertEquals(true)
    }

    static Is_keyword_should_work_with_traits() {
        (Map.OfType(Email, Email)() is Map.OfType(Email, Email))
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
}

/**
 * An email string.
 */
class Email extends String {
    static IsInstance(Val) => (Val is String)
        && (Val ~= "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
}