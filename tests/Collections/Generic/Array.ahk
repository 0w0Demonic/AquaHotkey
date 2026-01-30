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

    static delete_method_restricts_unset() {
        Str := String[]("foo")
        this.AssertThrows(() => Str.Delete(1))
        this.AssertThrows(() => Str[1] := unset)
    }

    static ComponentType_should_be_StringArr() {
        (String[].ComponentType).AssertEquals(String)
    }

    static Constraint_must_be_class_subtype() {
        Cls := String[Nullable]
        Cls.ComponentType.Eq(Nullable(String)).AssertEquals(true)
    }

    static Should_support_traits() {
        Callable[](MsgBox, { Call: (*) => MsgBox() }, String)
    }

    static object_should_work_as_pattern() {
        T := { foo: Integer, bar: String }
        Cls := Array.OfType(T)
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

    ; =========================================================================
    ; DUCK TYPING TESTS - IsInstance()
    ; =========================================================================

    static regular_array_isinstance_generic_array_simple() {
        ; Regular array should match generic array if all elements match type
        ([1, 2, 3]).Is(Integer[]).AssertEquals(true)
        (["a", "b", "c"]).Is(String[]).AssertEquals(true)
        ([1.5, 2.5, 3.5]).Is(Number[]).AssertEquals(true)
    }

    static regular_array_isinstance_generic_array_type_mismatch() {
        ; Regular array should not match if any element doesn't match type
        (["a", "b", 3]).Is(String[]).AssertEquals(false)
        ([1, 2, "three"]).Is(Integer[]).AssertEquals(false)
        (["a", 2, 3.5]).Is(Number[]).AssertEquals(false)
    }

    static generic_array_isinstance_generic_array_same_type() {
        ; Generic array should match same generic array type
        (Integer[](1, 2, 3)).Is(Integer[]).AssertEquals(true)
    }

    static generic_array_isinstance_generic_array_subtype() {
        ; Generic array with subtype component should match supertype
        IntArr := Integer[](1, 2, 3)
        
        IntArr.Is(Number[]).AssertEquals(true)  ; Integer is subtype of Number
        IntArr.Is(String[]).AssertEquals(false) ; Integer is not subtype of String
    }

    static generic_array_isinstance_generic_array_exact_match_required() {
        ; Generic array should match exact component type
        NumArr := Number[](1.5, 2.5)
        
        NumArr.Is(Number[]).AssertEquals(true)
        NumArr.Is(Integer[]).AssertEquals(false) ; Number is not subtype of Integer
    }

    static generic_array_with_nullable_constraint() {
        ; Generic array with constraint should check constraint compatibility
        NullStr := String[Nullable](unset, "test", unset)
        
        NullStr.Is(String[Nullable]).AssertEquals(true)
        NullStr.Is(String[]).AssertEquals(false)  ; Nullable(String) != String
    }

    static regular_array_with_unset_vs_nullable_constraint() {
        ; Regular array with unset should match nullable constraint
        WithNull := [unset, "test", "data"]
        
        WithNull.Is(String[Nullable]).AssertEquals(true)
        WithNull.Is(String[]).AssertEquals(false)
    }

    static regular_array_no_unset_vs_nullable_constraint() {
        ; Regular array without unset should not match nullable when checking strict
        NoNull := ["test", "data"]
        
        ; Should match because all elements are valid for Nullable(String)
        NoNull.Is(String[Nullable]).AssertEquals(true)
    }

    static nested_object_pattern_in_generic_array() {
        ; Generic array of object patterns
        UserPattern := { name: String, age: Integer }
        UserArr := Array.OfType(UserPattern)
        
        Users := [
            { name: "Alice", age: 30 },
            { name: "Bob", age: 25 }
        ]
        
        Users.Is(UserArr).AssertEquals(true)
        
        BadUsers := [
            { name: "Alice", age: "thirty" },
            { name: "Bob", age: 25 }
        ]
        
        BadUsers.Is(UserArr).AssertEquals(false)
    }

    static nested_array_pattern_in_generic_array() {
        ; Generic array of array patterns
        PairPattern := [String, Integer]
        PairArr := Array.OfType(PairPattern)
        
        Pairs := [
            ["Alice", 30],
            ["Bob", 25]
        ]
        
        Pairs.Is(PairArr).AssertEquals(true)
        
        BadPairs := [
            ["Alice", 30],
            [25, "Bob"]  ; wrong order
        ]
        
        BadPairs.Is(PairArr).AssertEquals(false)
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
        
        Users.Is(UserArr).AssertEquals(true)
        
        BadUsers := [
            { name: "Alice", tags: [1, 2] },  ; not strings
            { name: "Bob", tags: String[]("user") }
        ]
        
        BadUsers.Is(UserArr).AssertEquals(false)
    }

    static generic_array_with_any_component() {
        ; Generic array with Any should match anything
        ([1, "test", [], {}]).Is(Any[]).AssertEquals(true)
        Any[](1, "test", [], {}).Is(Any[]).AssertEquals(true)
    }

    ; =========================================================================
    ; DUCK TYPING TESTS - CanCastFrom()
    ; =========================================================================

    static cancastfrom_same_generic_array_type() {
        ; Same generic array types should cast from each other
        String[].CanCastFrom(String[]).AssertEquals(true)
        Number[].CanCastFrom(Number[]).AssertEquals(true)
        Integer[].CanCastFrom(Integer[]).AssertEquals(true)
    }

    static cancastfrom_subtype_component() {
        ; Supertype component should cast from subtype component
        Number[].CanCastFrom(Integer[]).AssertEquals(true)  ; Number accepts Integer[]
    }

    static cancastfrom_supertype_component_rejects() {
        ; Subtype component should not cast from supertype component
        Integer[].CanCastFrom(Number[]).AssertEquals(false)
        String[].CanCastFrom(Object[]).AssertEquals(false)
    }

    static cancastfrom_unrelated_component_types() {
        ; Unrelated types should not cast from each other
        String[].CanCastFrom(Integer[]).AssertEquals(false)
        Array[].CanCastFrom(String[]).AssertEquals(false)
    }

    static cancastfrom_with_nullable_constraint() {
        ; Nullable constraint should properly handle subtyping
        String[Nullable].CanCastFrom(String[]).AssertEquals(true)
        String[].CanCastFrom(String[Nullable]).AssertEquals(false)
    }

    static cancastfrom_nullable_supertype_accepts_nullable_subtype() {
        ; Nullable(Supertype) should accept Nullable(Subtype)
        Number[Nullable].CanCastFrom(Integer[Nullable]).AssertEquals(true)
        Integer[Nullable].CanCastFrom(Number[Nullable]).AssertEquals(false)
    }

    static cancastfrom_multiple_constraint_variants() {
        ; Various constraint combinations
        T1 := String[Nullable]
        T2 := Number[Nullable]
        T3 := Integer[Nullable]
        
        T1.CanCastFrom(T1).AssertEquals(true)
        T2.CanCastFrom(T3).AssertEquals(true)  ; Number[Nullable] accepts Integer[Nullable]
        T3.CanCastFrom(T2).AssertEquals(false)
    }

    ; =========================================================================
    ; DIFFERENT ARRAY SUBCLASSES
    ; =========================================================================

    static iarray_oftype_creates_correct_arraytype() {
        ; IArray.OfType should create generic array with correct ArrayType
        LinkedListClass := LinkedList.OfType(String)
        
        LinkedListClass.ArrayType.AssertEquals(LinkedList)
        LinkedListClass.ComponentType.AssertEquals(String)
    }

    static linked_list_generic_array_creation() {
        ; Create and use generic LinkedList
        LinkedListClass := LinkedList.OfType(Integer)
        LL := LinkedListClass(1, 2, 3)
        
        LL.Push(4)
        LL.Push(5)
        
        LL.Is(LinkedListClass).AssertEquals(true)
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
        
        ArrInst.Is(ArrayInt).AssertEquals(true)
        ListInst.Is(ListInt).AssertEquals(true)
        
        ArrInst.Is(ListInt).AssertEquals(false)
        ListInst.Is(ArrayInt).AssertEquals(false)
    }

    static different_array_subclasses_cannot_cast() {
        ; Different array subclass generics don't cast to each other
        Array.OfType(Integer).CanCastFrom(LinkedList.OfType(Integer))
                .AssertEquals(false)
        LinkedList.OfType(Integer).CanCastFrom(Array.OfType(Integer))
                .AssertEquals(false)
    }

    static different_array_subclasses_instanceof_regular_array() {
        ; Regular arrays should match different array type generics by component
        ([1, 2, 3]).Is(Array.OfType(Integer)).AssertEquals(true)
        ([1, 2, 3]).Is(LinkedList.OfType(Integer)).AssertEquals(true)
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
        
        Outer.Is(OuterArr).AssertEquals(true)
    }

    static generic_array_of_generic_array_type_validation() {
        ; Nested array type checking
        OuterArr := Integer[][]
        
        ([[1, 2], [3, 4]]).Is(OuterArr).AssertEquals(true)
        ([[1, 2], ["three", 4]]).Is(OuterArr).AssertEquals(false)
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
        
        People.Is(PersonArr).AssertEquals(true)
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
        
        Obj1.Is(Config).AssertEquals(true)
    }

    ; =========================================================================
    ; DUCK TYPE CONSTRAINT COMBINATIONS
    ; =========================================================================

    static array_with_multiple_constraint_check() {
        ; Verify different constraint applications
        T1 := String[]
        T2 := String[Nullable]
        T3 := String[Nullable]
        
        T1.ComponentType.AssertNotEquals(T2.ComponentType)
        T2.ComponentType.Eq(T3.ComponentType).AssertEquals(true)
    }

    static cancastfrom_between_different_constraints() {
        ; Constraint affects subtyping rules
        Required := String[]
        Optional := String[Nullable]
        
        Optional.CanCastFrom(Required).AssertEquals(true)   ; Optional accepts Required
        Required.CanCastFrom(Optional).AssertEquals(false)  ; Required doesn't accept Optional
    }

    static union_type_in_generic_array() {
        ; Generic array with union type component
        StringOrInt := Type.Union(String, Integer)
        UnionArr := Array.OfType(StringOrInt)
        
        ([1, "two", 3, "four"]).Is(UnionArr).AssertEquals(true)
        ([1, "two", 3.5]).Is(UnionArr).AssertEquals(false)
    }

    static intersection_type_in_generic_array() {
        ; Generic array with intersection type
        T := Type.Intersection(
            { x: Number },
            { y: Number }
        )
        TArr := Array.OfType(T)
        
        ([{ x: 1, y: 2 }, { x: 3, y: 4 }]).Is(TArr).AssertEquals(true)
        ([{ x: 1 }, { x: 3, y: 4 }]).Is(TArr).AssertEquals(false)
    }

    static enum_type_in_generic_array() {
        ; Generic array with enum component
        Role := Type.Enum("Admin", "User", "Guest")
        RoleArr := Array.OfType(Role)
        
        (["Admin", "User", "Guest"]).Is(RoleArr).AssertEquals(true)
        (["Admin", "Hacker"]).Is(RoleArr).AssertEquals(false)
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
        
        AnyArr.Length.AssertEquals(4)
    }

    static generic_array_single_element() {
        ; Single element arrays
        ([42]).Is(Integer[]).AssertEquals(true)
        (["test"]).Is(String[]).AssertEquals(true)
    }

    static cancastfrom_with_self() {
        ; Type should cast from itself
        Integer[].CanCastFrom(Integer[]).AssertEquals(true)
        String[].CanCastFrom(String[]).AssertEquals(true)
        Array.OfType(Any).CanCastFrom(Array.OfType(Any)).AssertEquals(true)
    }

    static generic_array_component_type_property() {
        ; ComponentType property should be accessible
        T := String[]
        
        (T.ComponentType).AssertEquals(String)
        
        T2 := Integer[]
        (T2.ComponentType).AssertEquals(Integer)
    }

    static generic_array_arraytype_property() {
        ; ArrayType property should return correct array type
        T := LinkedList.OfType(String)
        
        (T.ArrayType).AssertEquals(LinkedList)
    }

    static generic_array_nested_constraint_type() {
        ; Nested constraint handling
        T := String[Nullable]
        
        T.ComponentType.IsInstance(unset).AssertEquals(true)
        T.ComponentType.IsInstance("test").AssertEquals(true)
        T.ComponentType.IsInstance(123).AssertEquals(false)
    }
}
