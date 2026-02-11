
class Test_GenericArray extends TestSuite {
    static Class__Item_should_create_generic_array() {
        StrClass := String[]
        (StrClass).AssertType(Class)

        StrClass().Assert(DerivesFrom(GenericArray))
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

    static delete_method_restricts_unset() {
        Str := String[]("foo")
        this.AssertThrows(() => Str.Delete(1))
        this.AssertThrows(() => Str[1] := unset)
    }

    static ComponentType_should_be_StringArr() {
        (String[].ComponentType).Assert(Eq(String))
    }

    static Constraint_must_be_class_subtype() {
        Cls := String[Nullable]
        Cls.ComponentType.Eq(Nullable(String)).Assert(Eq(true))
    }

    static Should_support_traits() {
        Callable[](MsgBox, { Call: (*) => MsgBox() }, String)
    }

    static object_should_work_as_pattern() {
        T := { foo: Integer, bar: String }
        Cls := Array.OfType(T)
        Cls.ComponentType.Assert(Eq(T))

        Arr := Cls( { foo: 42, bar: "AHK!" } )

    }

    static array_should_work_as_pattern() {
        Cls := Array.OfType({ foo: Integer, bar: String })

        Arr := Cls( { foo: 42, bar: "AHK!" } )
    }

    static generic_eq_generic() {
        Number[](1, 2, 3).Eq(Number[](1, 2, 3))
                    .Assert(Eq(true))
    }

    static generic_eq_regular() {
        Number[](1, 2, 3).Eq([1, 2, 3]).Assert(Eq(true))
    }

    ; =========================================================================
    ; DUCK TYPING TESTS - IsInstance()
    ; =========================================================================

    static regular_array_isinstance_generic_array_simple() {
        ; Regular array should match generic array if all elements match type
        ([1, 2, 3]).Is(Integer[]).Assert(Eq(true))
        (["a", "b", "c"]).Is(String[]).Assert(Eq(true))
        ([1.5, 2.5, 3.5]).Is(Number[]).Assert(Eq(true))
    }

    static regular_array_isinstance_generic_array_type_mismatch() {
        ; Regular array should not match if any element doesn't match type
        (["a", "b", 3]).Is(String[]).Assert(Eq(false))
        ([1, 2, "three"]).Is(Integer[]).Assert(Eq(false))
        (["a", 2, 3.5]).Is(Number[]).Assert(Eq(false))
    }

    static generic_array_isinstance_generic_array_same_type() {
        ; Generic array should match same generic array type
        (Integer[](1, 2, 3)).Is(Integer[]).Assert(Eq(true))
    }

    static generic_array_isinstance_generic_array_subtype() {
        ; Generic array with subtype component should match supertype
        IntArr := Integer[](1, 2, 3)
        
        IntArr.Is(Number[]).Assert(Eq(true))  ; Integer is subtype of Number
        IntArr.Is(String[]).Assert(Eq(false)) ; Integer is not subtype of String
    }

    static generic_array_isinstance_generic_array_exact_match_required() {
        ; Generic array should match exact component type
        NumArr := Number[](1.5, 2.5)
        
        NumArr.Is(Number[]).Assert(Eq(true))
        NumArr.Is(Integer[]).Assert(Eq(false)) ; Number is not subtype of Integer
    }

    static generic_array_with_nullable_constraint() {
        ; Generic array with constraint should check constraint compatibility
        NullStr := String[Nullable](unset, "test", unset)
        
        NullStr.Is(String[Nullable]).Assert(Eq(true))
        NullStr.Is(String[]).Assert(Eq(false))  ; Nullable(String) != String
    }

    static regular_array_with_unset_vs_nullable_constraint() {
        ; Regular array with unset should match nullable constraint
        WithNull := [unset, "test", "data"]
        
        WithNull.Is(String[Nullable]).Assert(Eq(true))
        WithNull.Is(String[]).Assert(Eq(false))
    }

    static regular_array_no_unset_vs_nullable_constraint() {
        ; Regular array without unset should not match nullable when checking strict
        NoNull := ["test", "data"]
        
        ; Should match because all elements are valid for Nullable(String)
        NoNull.Is(String[Nullable]).Assert(Eq(true))
    }

    static nested_object_pattern_in_generic_array() {
        ; Generic array of object patterns
        UserPattern := { name: String, age: Integer }
        UserArr := Array.OfType(UserPattern)
        
        Users := [
            { name: "Alice", age: 30 },
            { name: "Bob", age: 25 }
        ]
        
        Users.Is(UserArr).Assert(Eq(true))
        
        BadUsers := [
            { name: "Alice", age: "thirty" },
            { name: "Bob", age: 25 }
        ]
        
        BadUsers.Is(UserArr).Assert(Eq(false))
    }

    static nested_array_pattern_in_generic_array() {
        ; Generic array of array patterns
        PairPattern := [String, Integer]
        PairArr := Array.OfType(PairPattern)
        
        Pairs := [
            ["Alice", 30],
            ["Bob", 25]
        ]
        
        Pairs.Is(PairArr).Assert(Eq(true))
        
        BadPairs := [
            ["Alice", 30],
            [25, "Bob"]  ; wrong order
        ]
        
        BadPairs.Is(PairArr).Assert(Eq(false))
    }

    static generic_array_of_object_with_nested_generic_array() {
        ; Complex nesting: object with generic array property
        UserWithTags := {
            name: String,
            tags: String[]
        }
        UserArr := Array.OfType(UserWithTags)
        
        Users := [
            { name: "Alice", tags: String[]("admin", "user") },
            { name: "Bob", tags: String[]("user") },
            { name: "Charlie", tags: ["foo", "bar"] }
        ]
        
        Users.Is(UserArr).Assert(Eq(true))
        
        BadUsers := [
            { name: "Alice", tags: [1, 2] },  ; not strings
            { name: "Bob", tags: String[]("user") }
        ]
        
        BadUsers.Is(UserArr).Assert(Eq(false))
    }

    static generic_array_with_any_component() {
        ; Generic array with Any should match anything
        ([1, "test", [], {}]).Is(Any[]).Assert(Eq(true))
        Any[](1, "test", [], {}).Is(Any[]).Assert(Eq(true))
    }

    ; =========================================================================
    ; DUCK TYPING TESTS - CanCastFrom()
    ; =========================================================================

    static cancastfrom_same_generic_array_type() {
        ; Same generic array types should cast from each other
        String[].CanCastFrom(String[]).Assert(Eq(true))
        Number[].CanCastFrom(Number[]).Assert(Eq(true))
        Integer[].CanCastFrom(Integer[]).Assert(Eq(true))
    }

    static cancastfrom_subtype_component() {
        ; Supertype component should cast from subtype component
        Number[].CanCastFrom(Integer[]).Assert(Eq(true))  ; Number accepts Integer[]
    }

    static cancastfrom_supertype_component_rejects() {
        ; Subtype component should not cast from supertype component
        Integer[].CanCastFrom(Number[]).Assert(Eq(false))
        String[].CanCastFrom(Object[]).Assert(Eq(false))
    }

    static cancastfrom_unrelated_component_types() {
        ; Unrelated types should not cast from each other
        String[].CanCastFrom(Integer[]).Assert(Eq(false))
        Array[].CanCastFrom(String[]).Assert(Eq(false))
    }

    static cancastfrom_with_nullable_constraint() {
        ; Nullable constraint should properly handle subtyping
        String[Nullable].CanCastFrom(String[]).Assert(Eq(true))
        String[].CanCastFrom(String[Nullable]).Assert(Eq(false))
    }

    static cancastfrom_nullable_supertype_accepts_nullable_subtype() {
        ; Nullable(Supertype) should accept Nullable(Subtype)
        Number[Nullable].CanCastFrom(Integer[Nullable]).Assert(Eq(true))
        Integer[Nullable].CanCastFrom(Number[Nullable]).Assert(Eq(false))
    }

    static cancastfrom_multiple_constraint_variants() {
        ; Various constraint combinations
        T1 := String[Nullable]
        T2 := Number[Nullable]
        T3 := Integer[Nullable]
        
        T1.CanCastFrom(T1).Assert(Eq(true))
        T2.CanCastFrom(T3).Assert(Eq(true))  ; Number[Nullable] accepts Integer[Nullable]
        T3.CanCastFrom(T2).Assert(Eq(false))
    }

    ; =========================================================================
    ; DIFFERENT ARRAY SUBCLASSES
    ; =========================================================================

    static iarray_oftype_creates_correct_arraytype() {
        ; IArray.OfType should create generic array with correct ArrayType
        LinkedListClass := LinkedList.OfType(String)
        
        LinkedListClass.ArrayType.Assert(Eq(LinkedList))
        LinkedListClass.ComponentType.Assert(Eq(String))
    }

    static linked_list_generic_array_creation() {
        ; Create and use generic LinkedList
        LinkedListClass := LinkedList.OfType(Integer)
        LL := LinkedListClass(1, 2, 3)
        
        LL.Push(4)
        LL.Push(5)
        
        LL.Is(LinkedListClass).Assert(Eq(true))
    }

    static linked_list_type_checking() {
        ; LinkedList generic array should enforce type checking
        LinkedListClass := LinkedList.OfType(String)
        LL := LinkedListClass("a", "b")
        
        this.AssertThrows(() => LL.Push(123))
        this.AssertThrows(() => LL.Push({}))
    }

    static array_vs_linkedlist_genericarray_isinstance() {
        ; Array and LinkedList generic arrays are different types
        ArrayInt := Array.OfType(Integer)
        ListInt := LinkedList.OfType(Integer)
        
        ArrInst := ArrayInt(1, 2, 3)
        ListInst := ListInt(1, 2, 3)
        
        ArrInst.Is(ArrayInt).Assert(Eq(true))
        ListInst.Is(ListInt).Assert(Eq(true))
        
        ArrInst.Is(ListInt).Assert(Eq(false))
        ListInst.Is(ArrayInt).Assert(Eq(false))
    }

    static different_array_subclasses_cannot_cast() {
        ; Different array subclass generics don't cast to each other
        Array.OfType(Integer).CanCastFrom(LinkedList.OfType(Integer))
                .Assert(Eq(false))
        LinkedList.OfType(Integer).CanCastFrom(Array.OfType(Integer))
                .Assert(Eq(false))
    }

    static regular_array_matched_by_array_type() {
        Arr := Array(1, 2, 3)
        List := LinkedList(1, 2, 3)

        ArrT := Array.OfType(Integer)
        ListT := LinkedList.OfType(Integer)

        Arr.Is(ArrT).Assert(Eq(true))
        List.Is(ArrT).Assert(Eq(false))

        Arr.Is(ListT).Assert(Eq(false))
        List.Is(ListT).Assert(Eq(true))
    }

    static different_array_subclasses_instanceof_regular_array() {
        ([1, 2, 3]).Is(Array.OfType(Integer)).Assert(Eq(true))

        ([1, 2, 3]).Is(LinkedList.OfType(Integer)).Assert(Eq(false))
    }

    ; =========================================================================
    ; DEEPLY NESTED GENERIC ARRAYS
    ; =========================================================================

    static generic_array_of_generic_array_of_integers() {
        ; Array of Integer arrays
        InnerArr := Integer[]
        OuterArr := InnerArr[]  ; Array of Array of Integer
        
        Inner1 := Integer[](1, 2, 3)
        Inner2 := Integer[](4, 5, 6)
        Outer := OuterArr(Inner1, Inner2)
        
        Outer.Is(OuterArr).Assert(Eq(true))
    }

    static generic_array_of_generic_array_type_validation() {
        ; Nested array type checking
        OuterArr := Integer[][]
        
        ([[1, 2], [3, 4]]).Is(OuterArr).Assert(Eq(true))
        ([[1, 2], ["three", 4]]).Is(OuterArr).Assert(Eq(false))
    }

    static generic_array_of_object_with_generic_array_property() {
        ; Object containing generic array property
        Person := {
            name: String,
            hobbies: String[]
        }
        PersonArr := Array.OfType(Person)
        
        People := [
            { name: "Alice", hobbies: String[]("reading", "coding") },
            { name: "Bob", hobbies: String[]("gaming") }
        ]
        
        People.Is(PersonArr).Assert(Eq(true))
    }

    static generic_map_component_in_generic_array() {
        ; Generic array of objects with map properties (if applicable)
        Config := {
            settings: Map.OfType(String, Any)
        }
        ConfigArr := Array.OfType(Config)
        
        ; Create instances that would match
        Obj1 := {
            settings: Map.OfType(String, Any)("key1", "value1", "key2", 42)
        }
        
        Obj1.Is(Config).Assert(Eq(true))
    }

    ; =========================================================================
    ; DUCK TYPE CONSTRAINT COMBINATIONS
    ; =========================================================================

    static array_with_multiple_constraint_check() {
        ; Verify different constraint applications
        T1 := String[]
        T2 := String[Nullable]
        T3 := String[Nullable]
        
        T1.ComponentType.Assert(Ne(T2.ComponentType))
        T2.ComponentType.Eq(T3.ComponentType).Assert(Eq(true))
    }

    static cancastfrom_between_different_constraints() {
        ; Constraint affects subtyping rules
        Required := String[]
        Optional := String[Nullable]
        
        Optional.CanCastFrom(Required).Assert(Eq(true))   ; Optional accepts Required
        Required.CanCastFrom(Optional).Assert(Eq(false))  ; Required doesn't accept Optional
    }

    static union_type_in_generic_array() {
        ; Generic array with union type component
        StringOrInt := Type.Union(String, Integer)
        UnionArr := Array.OfType(StringOrInt)
        
        ([1, "two", 3, "four"]).Is(UnionArr).Assert(Eq(true))
        ([1, "two", 3.5]).Is(UnionArr).Assert(Eq(false))
    }

    static intersection_type_in_generic_array() {
        ; Generic array with intersection type
        T := Type.Intersection(
            { x: Number },
            { y: Number }
        )
        TArr := Array.OfType(T)
        
        ([{ x: 1, y: 2 }, { x: 3, y: 4 }]).Is(TArr).Assert(Eq(true))
        ([{ x: 1 }, { x: 3, y: 4 }]).Is(TArr).Assert(Eq(false))
    }

    static enum_type_in_generic_array() {
        ; Generic array with enum component
        Role := Type.Enum("Admin", "User", "Guest")
        RoleArr := Array.OfType(Role)
        
        (["Admin", "User", "Guest"]).Is(RoleArr).Assert(Eq(true))
        (["Admin", "Hacker"]).Is(RoleArr).Assert(Eq(false))
    }

    ; =========================================================================
    ; EDGE CASES AND BOUNDARY CONDITIONS
    ; =========================================================================

    static generic_array_of_any_accepts_anything() {
        ; Any[] should accept any values
        AnyArr := Any[]()
        
        AnyArr.Push(1)
        AnyArr.Push("string")
        AnyArr.Push([])
        AnyArr.Push({})
        
        AnyArr.Length.Assert(Eq(4))
    }

    static generic_array_single_element() {
        ; Single element arrays
        ([42]).Is(Integer[]).Assert(Eq(true))
        (["test"]).Is(String[]).Assert(Eq(true))
    }

    static cancastfrom_with_self() {
        ; Type should cast from itself
        Integer[].CanCastFrom(Integer[]).Assert(Eq(true))
        String[].CanCastFrom(String[]).Assert(Eq(true))
        Array.OfType(Any).CanCastFrom(Array.OfType(Any)).Assert(Eq(true))
    }

    static generic_array_component_type_property() {
        ; ComponentType property should be accessible
        T := String[]
        
        (T.ComponentType).Assert(Eq(String))
        
        T2 := Integer[]
        (T2.ComponentType).Assert(Eq(Integer))
    }

    static generic_array_arraytype_property() {
        ; ArrayType property should return correct array type
        T := LinkedList.OfType(String)
        
        (T.ArrayType).Assert(Eq(LinkedList))
    }

    static generic_array_nested_constraint_type() {
        ; Nested constraint handling
        T := String[Nullable]
        
        T.ComponentType.IsInstance(unset).Assert(Eq(true))
        T.ComponentType.IsInstance("test").Assert(Eq(true))
        T.ComponentType.IsInstance(123).Assert(Eq(false))
    }

    ;---- EQUALITY CHECKS

    static static_eq_based_on_fields() {
        A := String[]
        B := String[]

        A.Eq(B).Assert(Eq(true))
    }

    static static_eq_wrong_array_type() {
        A := Array.OfType(String)
        B := LinkedList.OfType(String)
        A.Eq(B).Assert(Eq(false))
    }

    static static_eq_supports_object_patterns() {
        A := Array.OfType({ name: String })
        B := Array.OfType({ name: String })

        ; this here should call `Array.Eq(Array)` and `{...}.Eq({...})`
        ; --> true

        A.Eq(B).Assert(Eq(true))
    }

    static static_hashcode_same_when_equal() {
        A := String[]
        B := String[]

        ; since A.Eq(B)
        (A.HashCode()).Assert(Eq(B.HashCode()))
    }
}
