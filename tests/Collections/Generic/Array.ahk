#Include <AquaHotkey\src\Collections\Generic\Array>

class Test_GenericArray extends TestSuite {
    static __Item_should_create_generic_array() {
        StrClass := String[]
        ( String[] ).AssertType(Class)

        StrClass().AssertType(GenericArray)
    }

    static __New_should_do_type_checking() {
        Str := String[]()
        this.AssertThrows(  () => Str.__New( [] )  )
    }

    static Is_keyword_should_return_true() {
        (String[]() is String[]).AssertEquals(true)

        (String[NonNull]() is String[NonNull]).AssertEquals(true)
    }

    static type_checking_should_throw() {
        Str := String[]()
        this.AssertThrows(() => Str.Push( [] ))
        this.AssertThrows(() => Str.InsertAt( 1, {} ))
        this.AssertThrows(() => Str[1] := {} )
    }

    static constraint_should_throw() {
        this.AssertThrows(() => String[NonNull](unset))
    }

    static delete_method_should_check_constraint() {
        Str := String[NonNull]("foo")
        this.AssertThrows(() => Str.Delete(1))
        this.AssertThrows(() => Str[1] := unset)
    }

    static OfType_should_create_generic_array() {
        Array.OfType(String, NonNull).AssertEquals(  String[NonNull]  )
    }

    static ComponentType_should_be_StringArr() {
        (String[].ComponentType).AssertEquals(String)
    }

    static Constraint_should_be_NonNull() {
        (String[NonNull].Constraint).AssertEquals(NonNull)
    }

    static Constraint_should_be_false() {
        (String[].Constraint).AssertEquals(false)
    }

    static Should_support_traits() {
        Callable[](MsgBox, { Call: (*) => MsgBox() }, String)
    }
}

NonNull(Val?) => IsSet(Val)