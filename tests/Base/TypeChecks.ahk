class Test_TypeChecks extends TestSuite {
    static Is_method_should_exist() {
        HasMethod(345, "Is").AssertEquals(true)
    }

    static IsInstance_method_should_exist() {
        HasMethod(Any, "IsInstance").AssertEquals(true)

        ObjHasOwnProp(Class.Prototype, "IsInstance").AssertEquals(true)
    }

    static basic_test() {
        "foo".Is(String).AssertEquals(true)
    }

    static numbers_are_numeric() {
        Number(123.4).Is(Numeric).AssertEquals(true)
    }

    static string_can_be_numeric() {
        String("123.4").Is(Numeric).AssertEquals(true)
    }

    static functions_are_callable() {
        MsgBox.Is(Callable).AssertEquals(true)
    }

    static regular_objects_can_be_callable() {
        Obj := { Call: Unsupported }
        Obj.Is(Callable).AssertEquals(true)

        Unsupported(*) {
            throw Error("does function should not be called")
        }
    }

    static callable_ignores_meta_properties() {
        Obj := { __Call: Unsupported }
        Obj.Is(Callable).AssertEquals(false)

        Unsupported(*) {
            throw Error("does function should not be called")
        }
    }

    static buffers_are_buffer_objects() {
        Buffer(16).Is(BufferObject).AssertEquals(true)
    }

    static objects_can_be_buffer_objects() {
        ({ Ptr: 0, Size: 0 }).Is(BufferObject).AssertEquals(true)
    }

    static Number_assignable_from_Integer() {
        Number.CanCastFrom(Integer)
                .AssertEquals(true)
    }

    static Number_assignable_from_Number() {
        Number.CanCastFrom(Number)
                .AssertEquals(true)
    }

    static every_Number_is_Numeric() {
        Numeric.CanCastFrom(Number)
                .AssertEquals(true)
    }

    static every_Func_is_Callable() {
        Callable.CanCastFrom(Func)
                .AssertEquals(true)

        Callable.CanCastFrom(Enumerator)
                .AssertEquals(true)
    }

    static every_Buffer_is_BufferObject() {
        BufferObject.CanCastFrom(Buffer)
                .AssertEquals(true)
                
        BufferObject.CanCastFrom(ClipboardAll)
                .AssertEquals(true)
    }

    static value_should_match_via_eq() {
        T := 42
        Val := 42

        Val.Is(T).AssertEquals(true)
    }

    static object_should_match_point() {
        Point := { x: Number, y: Number }
        ({ x: 123, y: 3.42 }).Is(Point).AssertEquals(true)

        ({ x: 123 }).Is(Point).AssertEquals(false)

        ({ x: 123, y: 3.42, z: "don't care" }).Is(Point).AssertEquals(true)
    }

    static property_must_equal_in_value() {
        User := { name: "Jason", age: Integer }

        ({ name: "Jason", age: 23 }).Is(User).AssertEquals(true)

        ({ name: "Victoria", age: 23 }).Is(User).AssertEquals(false)
    }

    static array_matching() {
        T := [ Integer, String ]
        ([ 42, "example" ]).Is(T).AssertEquals(true)

        ([ "bogus", "example" ]).Is(T).AssertEquals(false)
    }

    static array_matching_with_eq() {
        T := [ 42, String ]

        ([ 23, "!" ]).Is(T).AssertEquals(false)
        ([ 42, "!" ]).Is(T).AssertEquals(true)
    }

    static array_element_should_match_unset() {
        T := [ unset, Integer ]

        ([ unset, 42 ]).Is(T).AssertEquals(true)
        ([ 0, 42 ]).Is(T).AssertEquals(false)
    }

    static matching_optional_type() {
        T := Optional(String)

        T.IsInstance(unset).AssertEquals(true)
        T.IsInstance("foo").AssertEquals(true)
        T.IsInstance([1, 2]).AssertEquals(false)
    }

    static order_type() {
        Order := {
            Id: String,
            Item: {
                Name: String,
                Price: Number
            }
        }

        ({ id: "o1", item: { name: "apple", price: 1.5 } })
            .Is(Order).AssertEquals(true)

        ({ id: "o1", item: { name: "apple" } })
            .Is(Order).AssertEquals(false)
    }

    static generic_array_matches_generic_array() {
        Number[](1, 2, 3, 4.5).Is( Number[] ).AssertEquals(true)
    }

    static regular_array_is_not_generic() {
        T := Number[]

        ([1, 2, 3]).Is(Number[]).AssertEquals(false)
    }

    static object_can_cast() {
        ({ foo: Integer, data: Any })
            .CanCastFrom({ foo: Integer, data: Number })
            .AssertEquals(true)
    }
}
