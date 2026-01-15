#Include <AquaHotkey\src\Collections\Generic\Array>

class Test_GenericArray extends TestSuite {
    static Class__Item_should_create_generic_array() {
        StrClass := String[]
        ( String[] ).AssertType(Class)

        StrClass().AssertType(GenericArray)
    }

    static Class__New_should_do_type_checking() {
        Str := String[]()
        this.AssertThrows(  () => Str.__New( [] )  )
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

    static object_should_work_as_pattern() {
        T := { foo: Integer, bar: String }
        Cls := T.ArrayType
        Cls.ComponentType.AssertEquals(T)

        Arr := Cls( { foo: 42, bar: "AHK!" } )

    }

    static array_should_work_as_pattern() {
        Cls := Array.OfType({ foo: Integer, bar: String })

        Arr := Cls( { foo: 42, bar: "AHK!" } )
    }

    static generic_eq_generic() {
        Number[](1, 2, 3).Eq(Number[](1, 2, 3))
                    .AssertEquals(true)
    }

    static generic_eq_regular() {
        Number[](1, 2, 3).Eq([1, 2, 3]).AssertEquals(true)
    }
}

class NonNull {
    static IsInstance(Val?) => IsSet(Val)
}

class NonNullNonEmpty extends NonNull {
    static IsInstance(Val?) => super(Val?) && (Val != "")
}

;ApiResponse := Type.Union(
;    { status: 200, data:  Any    },
;    { status: 301, to:    String },
;    { status: 400, error: Error  },
;)