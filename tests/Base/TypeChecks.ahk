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
        Number.IsAssignableFrom(Integer)
                .AssertEquals(true)
    }

    static Number_assignable_from_Number() {
        Number.IsAssignableFrom(Number)
                .AssertEquals(true)
    }

    static every_Number_is_Numeric() {
        Numeric.IsAssignableFrom(Number)
                .AssertEquals(true)
    }

    static every_Func_is_Callable() {
        Callable.IsAssignableFrom(Func)
                .AssertEquals(true)

        Callable.IsAssignableFrom(Enumerator)
                .AssertEquals(true)
    }

    static every_Buffer_is_BufferObject() {
        BufferObject.IsAssignableFrom(Buffer)
                .AssertEquals(true)
                
        BufferObject.IsAssignableFrom(ClipboardAll)
                .AssertEquals(true)
    }
}
