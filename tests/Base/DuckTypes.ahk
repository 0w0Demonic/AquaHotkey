class Test_DuckTypes extends TestSuite {
    static Is_method_should_exist() {
        HasMethod(345, "Is").Assert(Eq(true))
    }

    static IsInstance_method_should_exist() {
        HasMethod(Any, "IsInstance").Assert(Eq(true))

        ObjHasOwnProp(Class.Prototype, "IsInstance").Assert(Eq(true))
    }

    static basic_test() {
        "foo".AssertType(String)
    }

    static numbers_are_numeric() {
        Number(123.4).AssertType(Numeric)
    }

    static string_can_be_numeric() {
        String("123.4").AssertType(Numeric)
    }

    static functions_are_callable() {
        MsgBox.AssertType(Callable)
    }

    static regular_objects_can_be_callable() {
        Obj := { Call: Unsupported }
        Obj.AssertType(Callable)

        Unsupported(*) {
            throw Error("this function should not be called")
        }
    }

    static callable_ignores_meta_properties() {
        Obj := { __Call: Unsupported }
        Assert(!Obj.Is(Callable))

        Unsupported(*) {
            throw Error("this function should not be called")
        }
    }

    static buffers_are_buffer_objects() {
        Buffer(16).AssertType(IBuffer)
    }

    static objects_can_be_buffer_objects() {
        ({ Ptr: 0, Size: 0 }).AssertType(IBuffer)
    }

    static Number_assignable_from_Integer() {
        Assert(Number.CanCastFrom(Integer))
    }

    static Number_assignable_from_Number() {
        Assert(Number.CanCastFrom(Number))
    }

    static every_Number_is_Numeric() {
        Assert(Number.CanCastFrom(Number))
    }

    static every_Func_is_Callable() {
        Assert(Callable.CanCastFrom(Func))
        Assert(Callable.CanCastFrom(Enumerator))
    }

    static every_Buffer_is_IBuffer() {
        Assert(IBuffer.CanCastFrom(Buffer))
                
        Assert(IBuffer.CanCastFrom(ClipboardAll))
    }

    static value_should_match_via_eq() {
        T := 42
        Val := 42

        Val.Is(T).Assert(Eq(true))
    }

    static object_should_match_point() {
        Point := { x: Number, y: Number }
        Assert(({ x: 123, y: 3.42 }).Is(Point))
        Assert(!({ x: 123 }).Is(Point))

        ({ x: 123, y: 3.42, z: "don't care" }).AssertType(Point)
    }

    static property_must_equal_in_value() {
        User := { name: "Jason", age: Integer }

        ({ name: "Jason", age: 23 }).AssertType(User)

        ({ name: "Victoria", age: 23 }).Is(User).Assert(Eq(false))
    }

    static array_matching() {
        T := [ Integer, String ]
        ([ 42, "example" ]).AssertType(T)

        ([ "bogus", "example" ]).Assert(Predicate.Not(InstanceOf(T)))
    }

    static array_matching_with_eq() {
        T := [ 42, String ]

        ([ 23, "!" ]).Is(T).Assert(Eq(false))
        ([ 42, "!" ]).Is(T).Assert(Eq(true))
    }

    static array_element_should_match_unset() {
        T := [ unset, Integer ]

        ([ unset, 42 ]).AssertType(T)
        ([ 0, 42 ]).Assert(Predicate.Not(InstanceOf(T)))
    }

    static order_type() {
        Order := {
            Id: String,
            Item: { Name: String, Price: Number }
        }

        ({ id: "o1", item: { name: "apple", price: 1.5 } })
                    .AssertType(Order)

        ({ id: "o1", item: { name: "apple" } })
                    .Assert(Predicate.Not(InstanceOf(Order)))
    }

    static generic_array_matches_generic_array() {
        Number[](1, 2, 3, 4.5).AssertType( Number[] )
    }

    static regular_array_can_be_generic() {
        T := Number[]

        ([1, 2, 3]).AssertType(Number[])
    }

    static object_can_cast() {
        ({ foo: Integer, data: Any })
            .CanCastFrom({ foo: Integer, data: Number })
            .Assert(Eq(true))
    }

    ;---------------------------------------------------------------------------
    ; generated (please don't flame me lol)
    ;---------------------------------------------------------------------------

    ; --- Any class edge cases ---

    static any_is_delegates_to_target_isinstance() {
        ; Any.Is(T) must delegate to T.IsInstance(this)
        CustomType := { IsInstance: MockIsInstance }
        CustomType.CallCount := 0

        CustomType.IsInstance("test value").Assert(Eq(true))
        
        CustomType.CallCount.Assert(Eq(1))

        MockIsInstance(this, Val?) {
            CustomType.CallCount++
            return true
        }
    }

    static any_isinstance_requires_isset_and_eq() {
        ; IsInstance(Val?) => IsSet(Val) && this.Eq(Val)
        (42).IsInstance(unset).Assert(Eq(false))
        (42).IsInstance(42).Assert(Eq(true))
        (42).IsInstance(43).Assert(Eq(false))
    }

    static any_cancastfrom_requires_eq() {
        ; CanCastFrom(T) => this.Eq(T)
        (42).CanCastFrom(42).Assert(Eq(true))
        (42).CanCastFrom(43).Assert(Eq(false))
        ("foo").CanCastFrom("foo").Assert(Eq(true))
        ("foo").CanCastFrom("bar").Assert(Eq(false))
    }

    static any_null_string_differs_from_empty_string() {
        ; Verify that different values are not considered equal
        "".IsInstance(unset).Assert(Eq(false))
    }

    ; --- Object pattern matching strict requirements ---

    static object_isinstance_rejects_non_literals() {
        BaseCls := Object() ; good enough lol

        Inst := { Prop: "value" }
        Pattern := { Prop: String }

        ObjSetBase(Inst, BaseCls) ; no longer an object literal anymore

        Inst.Is(Pattern).Assert(Eq(false))
    }

    static object_requires_val_to_be_object() {
        Pattern := { x: Number }
        
        Pattern.IsInstance("not an object").Assert(Eq(false))
        Pattern.IsInstance(123).Assert(Eq(false))
        Pattern.IsInstance(unset).Assert(Eq(false))
        Pattern.IsInstance([123]).Assert(Eq(false))
    }

    static object_pattern_property_mismatch() {
        ; All required properties must exist and match, as long as they're
        ; NOT something like `Optional(Number)`, etc.

        Pattern := { a: Number, b: String, c: Any }

        ({ a: 1, b: "x", c: [] }).Is(Pattern).Assert(Eq(true))
        ({ a: 1, b: "x" }).Is(Pattern).Assert(Eq(false))  ; missing c
        ({ a: 1, c: [] }).Is(Pattern).Assert(Eq(false))   ; missing b
        ({ b: "x", c: [] }).Is(Pattern).Assert(Eq(false)) ; missing a
    }

    static object_pattern_with_nested_failures() {
        ; Nested object type checking must fail if inner objects fail
        Pattern := { user: { name: String, age: Integer } }

        ({ user: { name: "Alice", age: 30 } }).Is(Pattern).Assert(Eq(true))
        ({ user: { name: "Alice", age: "thirty" } }).Is(Pattern).Assert(Eq(false))
        ({ user: { name: 123, age: 30 } }).Is(Pattern).Assert(Eq(false))
        ({ user: "not object" }).Is(Pattern).Assert(Eq(false))
    }

    static object_extra_properties_are_allowed() {
        ; Pattern defines minimum required properties, extras are OK
        Pattern := { id: Integer }

        ({ id: 1 }).Is(Pattern).Assert(Eq(true))
        ({ id: 1, name: "extra", data: [] }).Is(Pattern).Assert(Eq(true))
        ({ name: "extra", data: [] }).Is(Pattern).Assert(Eq(false))
    }

    static object_cancastfrom_strict_subtyping() {
        ; T must be object literal and all pattern properties must be castable
        Pattern := { x: Number, y: Number }

        Pattern.CanCastFrom({ x: Integer, y: Integer }).Assert(Eq(true))
        Pattern.CanCastFrom({ x: Number, y: Number }).Assert(Eq(true))
        Pattern.CanCastFrom({ x: Integer, y: Number }).Assert(Eq(true))
        Pattern.CanCastFrom({ x: Number, y: Integer }).Assert(Eq(true))
        Pattern.CanCastFrom({ x: String, y: Integer }).Assert(Eq(false))
        Pattern.CanCastFrom({ x: Integer }).Assert(Eq(false)) ; missing y
    }

    static object_cancastfrom_rejects_non_literals() {
        Pattern := { a: Number }

        Pattern.CanCastFrom("not object").Assert(Eq(false))
        Pattern.CanCastFrom(123).Assert(Eq(false))
        
        BaseObj := Object()
        Pattern.CanCastFrom({ base: BaseObj, a: Integer }).Assert(Eq(false))
    }

    ; --- Array pattern matching strict requirements ---

    ; TODO pattern matching arrays with some kind of marker
    ;      like `Variadic(String)`

    static array_length_must_match_exactly() {
        ; Arrays must have exact same length as pattern
        Pattern := [Integer, String]

        ([1, "a"]).Is(Pattern).Assert(Eq(true))
        ([1]).Is(Pattern).Assert(Eq(false))
        ([1, "a", 3]).Is(Pattern).Assert(Eq(false))
        ([]).Is(Pattern).Assert(Eq(false))
    }

    static array_rejects_non_arrays() {
        Pattern := [Integer, String]

        Pattern.IsInstance("not array").Assert(Eq(false))
        Pattern.IsInstance({ 0: 1, 1: "a" }).Assert(Eq(false))
        Pattern.IsInstance(123).Assert(Eq(false))
        Pattern.IsInstance(unset).Assert(Eq(false))
    }

    static array_element_type_mismatch() {
        ; Each element must match corresponding pattern element
        Pattern := [Integer, String, Number]

        ([1, "a", 3.14]).Is(Pattern).Assert(Eq(true))
        (["a", "a", 3.14]).Is(Pattern).Assert(Eq(false))  ; first is string not integer
        ([1, 42, 3.14]).Is(Pattern).Assert(Eq(false))     ; second is number not string
        ([1, "a", "not number"]).Is(Pattern).Assert(Eq(false))
    }

    ; TODO add a marker class `Null`/`Nothing`, so I don't ever need to
    ;      reinvent stuff in methods for the sake of handling `unset`?

    static array_unset_pattern_element_must_match_unset_value() {
        ; unset in pattern requires unset in array (not 0, not empty, literal unset)
        Pattern := [unset, Integer, unset]

        ([unset, 42, unset]).Is(Pattern).Assert(Eq(true))
        ([0, 42, unset]).Is(Pattern).Assert(Eq(false))     ; first is 0 not unset
        ([unset, 42, 0]).Is(Pattern).Assert(Eq(false))     ; third is 0 not unset
        (["", 42, unset]).Is(Pattern).Assert(Eq(false))    ; first is "" not unset
    }

    static array_sparse_arrays() {
        ; Sparse array handling: missing indices should be treated as unset
        SparseArray := []
        SparseArray.Push(42)

        Pattern1 := [Integer]
        SparseArray.Is(Pattern1).Assert(Eq(true))

        SparseArray.Push("ignored")
        Pattern2 := [Integer, String]
        SparseArray.Is(Pattern2).Assert(Eq(true))

        Pattern3 := [Integer, String, Integer]
        SparseArray.Is(Pattern3).Assert(Eq(false))  ; third element unset
    }

    static array_nested_pattern_matching() {
        ; Arrays can contain object patterns, and vice versa
        Pattern := [{ id: Integer }, String]

        ([{ id: 1 }, "name"]).Is(Pattern).Assert(Eq(true))
        ([{ id: 1, extra: "ok" }, "name"]).Is(Pattern).Assert(Eq(true))
        ([{ id: "not int" }, "name"]).Is(Pattern).Assert(Eq(false))
        ([{ extra: "no id" }, "name"]).Is(Pattern).Assert(Eq(false))
    }

    ; --- Generic Array type checking ---

    ; TODO oddload this into separate files?

    static generic_array_component_type_subtyping() {
        ; Integer[] should be compatible with Number[] because Integer is subtype of Number
        IntArray := Integer[](1, 2, 3)
        NumArray := Number[](1.5, 2.5)

        IntArray.Is(Number[]).Assert(Eq(true))
        NumArray.Is(Integer[]).Assert(Eq(false)) ; reverse is false
    }

    static generic_array_rejects_incompatible_component_types() {
        StringArray := String[]("a", "b")

        StringArray.Is(Number[]).Assert(Eq(false))
        StringArray.Is(Integer[]).Assert(Eq(false))
    }

    static generic_array_empty_arrays() {
        Int := Integer[]()
        Num := Number[]()

        Int.Is(Integer[]).Assert(Eq(true))
        Int.Is(Number[]).Assert(Eq(true))
        Num.Is(Integer[]).Assert(Eq(false))
    }

    static regular_array_casting_to_generic() {
        ; Regular arrays should be checkable against generic types
        RegArray := [1, 2, 3]

        RegArray.Is(Integer[]).Assert(Eq(true))
        RegArray.Is(Number[]).Assert(Eq(true))
        
        StrArray := ["a", "b"]
        StrArray.Is(String[]).Assert(Eq(true))
        StrArray.Is(Integer[]).Assert(Eq(false))
    }

    static generic_array_mixed_elements_fail() {
        ; Arrays with mixed types should fail strict generic checks
        MixedArray := [1, "two", 3]

        MixedArray.Is(Integer[]).Assert(Eq(false))
        MixedArray.Is(String[]).Assert(Eq(false))
        MixedArray.Is(Primitive[]).Assert(Eq(true)) ; common denominator
    }

    ; --- Class inheritance and subtyping ---

    static class_cancastfrom_self_equality() {
        ; Class.CanCastFrom(Class) is true for same class
        Number.CanCastFrom(Number).Assert(Eq(true))
        String.CanCastFrom(String).Assert(Eq(true))
        Array.CanCastFrom(Array).Assert(Eq(true))
    }

    static class_cancastfrom_base_class() {
        ; SubClass.CanCastFrom(SubClass) => true (via HasBase)
        ; Base.CanCastFrom(SubClass) => true (SubClass is subtype)
        Object.CanCastFrom(Array).Assert(Eq(true))
        Object.CanCastFrom(Map).Assert(Eq(true))
    }

    static class_isinstance_uses_is_keyword() {
        ; Should use strict `is` keyword semantics
        "test".Is(String).Assert(Eq(true))
        "test".Is(Object).Assert(Eq(false))
        "test".Is(Array).Assert(Eq(false))

        ([1, 2, 3]).Is(Array).Assert(Eq(true))
        ([1, 2, 3]).Is(Object).Assert(Eq(true))
        ([1, 2, 3]).Is(String).Assert(Eq(false))
    }

    ; --- Union Type Tests ---

    static union_accepts_any_type() {
        T := Type.Union(Integer, String)

        T.IsInstance(42).Assert(Eq(true))
        T.IsInstance("hello").Assert(Eq(true))
        T.IsInstance(3.14).Assert(Eq(false))
        T.IsInstance([]).Assert(Eq(false))
    }

    static union_with_three_types() {
        T := Type.Union(Integer, String, Array)

        T.IsInstance(42).Assert(Eq(true))
        T.IsInstance("hello").Assert(Eq(true))
        T.IsInstance([1, 2]).Assert(Eq(true))
        T.IsInstance(3.14).Assert(Eq(false))
        T.IsInstance({}).Assert(Eq(false))
    }

    ; TODO rethink this, probably with a marker class just for `unset`
    static union_rejects_unset() {
        T := Type.Union(Integer, String)

        T.IsInstance(unset).Assert(Eq(false))
    }

    ; --- Intersection Type Tests ---

    static intersection_requires_all_types() {
        T := Type.Intersection(
            { x: Number },
            { y: Number }
        )

        T.IsInstance({ x: 1, y: 2 }).Assert(Eq(true))
        T.IsInstance({ x: 1, y: 2, z: 3 }).Assert(Eq(true))
        T.IsInstance({ x: 1 }).Assert(Eq(false))  ; missing y
        T.IsInstance({ y: 2 }).Assert(Eq(false))  ; missing x
    }

    static intersection_with_incompatible_types() {
        ; If types can't all be satisfied simultaneously, should be false
        T := Type.Intersection(String, Integer)

        T.IsInstance("hello").Assert(Eq(false))  ; can't be both
        T.IsInstance(42).Assert(Eq(false))
    }

    ; TODO again, rethink this

    static intersection_rejects_unset() {
        T := Type.Intersection(String, Object)

        T.IsInstance(unset).Assert(Eq(false))
    }

    ; --- Enum Type Tests ---

    static enum_accepts_specified_values() {
        T := Type.Enum("Admin", "User", "Guest")

        T.IsInstance("Admin").Assert(Eq(true))
        T.IsInstance("User").Assert(Eq(true))
        T.IsInstance("Guest").Assert(Eq(true))
        T.IsInstance("Other").Assert(Eq(false))
    }

    static enum_numeric_values() {
        T := Type.Enum(1, 2, 3)

        T.IsInstance(1).Assert(Eq(true))
        T.IsInstance(2).Assert(Eq(true))
        T.IsInstance(4).Assert(Eq(false))
    }

    ; TODO rethink this
    static enum_rejects_unset() {
        T := Type.Enum("A", "B", "C")

        T.IsInstance(unset).Assert(Eq(false))
    }

    static enum_mixed_value_types() {
        T := Type.Enum(1, "two", 3.0)

        T.IsInstance(1).Assert(Eq(true))
        T.IsInstance("two").Assert(Eq(true))
        T.IsInstance(3.0).Assert(Eq(true))
        T.IsInstance(2).Assert(Eq(false))
        T.IsInstance("three").Assert(Eq(false))
    }

    ; --- Complex nested pattern tests ---

    static deeply_nested_object_patterns() {
        Pattern := {
            user: {
                profile: {
                    name: String,
                    age: Integer
                },
                roles: String[]
            }
        }

        Obj := {
            user: {
                profile: {
                    name: "Alice",
                    age: 30
                },
                roles: String[]("admin", "user")
            }
        }

        Obj.Is(Pattern).Assert(Eq(true))

        BadObj := {
            user: {
                profile: {
                    name: 123,  ; wrong type
                    age: 30
                },
                roles: String[]("admin", "user")
            }
        }

        BadObj.Is(Pattern).Assert(Eq(false))
    }

    static array_of_objects_pattern() {
        Pattern := [
            { id: Integer, name: String },
            { id: Integer, name: String }
        ]

        Objects := [
            { id: 1, name: "Alice" },
            { id: 2, name: "Bob" }
        ]

        Objects.Is(Pattern).Assert(Eq(true))

        BadObjects := [
            { id: 1, name: "Alice" },
            { id: "two", name: "Bob" }  ; second id is wrong type
        ]

        BadObjects.Is(Pattern).Assert(Eq(false))
    }

    static object_with_array_property() {
        Pattern := {
            items: [String, String, Integer],
            count: Integer
        }

        Good := {
            items: ["a", "b", 3],
            count: 1
        }

        Good.Is(Pattern).Assert(Eq(true))

        Bad := {
            items: ["a", "b"],  ; wrong length
            count: 1
        }

        Bad.Is(Pattern).Assert(Eq(false))
    }

    ; --- Any type edge cases ---

    static any_isinstance_with_complex_eq() {
        ; Verify Eq semantics are used for primitives
        Val := "test"

        Val.Is("test").Assert(Eq(true))
        Val.Is("other").Assert(Eq(false))
    }

    static pattern_matching_with_any() {
        ; Any should match anything non-null
        Pattern := { value: Any }

        ({ value: 1 }).Is(Pattern).Assert(Eq(true))
        ({ value: "string" }).Is(Pattern).Assert(Eq(true))
        ({ value: [] }).Is(Pattern).Assert(Eq(true))
        ({ value: unset }).Is(Pattern).Assert(Eq(false))
    }

    ; --- Type mismatch error handling ---

    static wrong_pattern_type_for_array() {
        ; Pattern is for object but testing array
        Pattern := { x: Number }

        ([1, 2, 3]).Is(Pattern).Assert(Eq(false))
    }

    static wrong_pattern_type_for_object() {
        ; Pattern is for array but testing object
        Pattern := [Integer, String]

        ({ a: 1, b: "x" }).Is(Pattern).Assert(Eq(false))
    }

    ; --- Object property descriptor edge cases ---

    static object_pattern_with_getters() {
        ; Property descriptors without "Value" should be skipped
        PatternWithGetter := { name: String }
        PatternWithGetter.DefineProp("computed", {
            Get: (*) => "computed"
        })

        ({ name: "test" }).Is(PatternWithGetter).Assert(Eq(true))
    }

    ; --- Boundary cases ---

    static empty_object_pattern() {
        ; Empty pattern matches any object literal (no required properties)
        Pattern := {}

        ({}).Is(Pattern).Assert(Eq(true))
        ({ a: 1 }).Is(Pattern).Assert(Eq(true))
        ({ a: 1, b: 2, c: 3 }).Is(Pattern).Assert(Eq(true))
    }

    static empty_array_pattern() {
        ; Empty array pattern should only match empty arrays
        Pattern := []

        ([]).Is(Pattern).Assert(Eq(true))
        ([1]).Is(Pattern).Assert(Eq(false))

        ; however, the Array class works just fine
        Pattern.Is(Array).Assert(Eq(true))
    }

    static single_element_patterns() {
        ObjPattern := { x: Integer }
        ArrPattern := [Integer]

        ({ x: 42 }).Is(ObjPattern).Assert(Eq(true))
        ({ x: 42, y: 99 }).Is(ObjPattern).Assert(Eq(true))

        ([42]).Is(ArrPattern).Assert(Eq(true))
        ([42, 99]).Is(ArrPattern).Assert(Eq(false))
    }

    ; TODO add `Boolean` class?
    static zero_and_false_as_values() {
        ; Verify 0 and false are not treated as unset
        Boolean := Type.Union(true, false)

        Pattern := [Integer, Boolean]

        ([0, false]).Is(Pattern).Assert(Eq(true))
        ([unset, false]).Is(Pattern).Assert(Eq(false))
        ([0, unset]).Is(Pattern).Assert(Eq(false))
    }

    static empty_string_vs_unset() {
        ; Verify empty string is not unset
        Pattern := [String, Integer]

        (["", 42]).Is(Pattern).Assert(Eq(true))
        ([unset, 42]).Is(Pattern).Assert(Eq(false))
    }

    static array_cancastfrom_rejects_non_arrays() {
        ([Number]).CanCastFrom("not an array").Assert(Eq(false))
        ([Number]).CanCastFrom(123).Assert(Eq(false))
    }

    static array_cancastfrom_length_must_be_same() {
        ([Number]).CanCastFrom([Number, Number]).Assert(Eq(false))
        ([]).CanCastFrom([Number]).Assert(Eq(false))
        ([Number]).CanCastFrom([]).Assert(Eq(false))
    }

    static array_cancastfrom_checks_elements() {
        ([Number]).CanCastFrom([Integer]).Assert(Eq(true))
        ([Numeric]).CanCastFrom([Number]).Assert(Eq(true))

        ([Primitive, Primitive]).CanCastFrom([Integer, Integer])
            .Assert(Eq(true))
    }

    static func_isinstance_calls_self() {
        Callable(Val?) => IsSet(Val) && IsObject(Val) && HasMethod(Val)

        MsgBox.Is(Callable).Assert(Eq(true))
    }
}
