class Test_TryOp extends TestSuite {
    static Succeeded1() {
        TryOp.Value(123).Succeeded.AssertEquals(true)
    }

    static Succeeded2() {
        TryOp(FileRead).Succeeded.AssertEquals(false)
    }

    static Failed1() {
        TryOp.Value(123).Failed.AssertEquals(false)
    }

    static Failed2() {
        TryOp(FileRead).Failed.AssertEquals(true)
    }

    static Finally() {
        Result := unset
        TryOp.Value(123).Finally(() => (Result := "example"))

        IsSet(Result).AssertEquals(true)
    }

    static Then() {
        Result := unset
        TryOp.Value(123).Then((x) => (Result := x))

        IsSet(Result).AssertEquals(true)
        Result.AssertEquals(123)
    }

    static OnSuccess() {
        Result := unset
        TryOp.Value("example").OnSuccess((Str) => (Result := Str))
        IsSet(Result).AssertEquals(true)
    }

    static OnFailure() {
        Result := unset
        TryOp.Value(2)
            .Map((x) => (x / 0))    
            .OnFailure(Error, (Err) => (Result := Err.Message))
        
        IsSet(Result).AssertEquals(true)
    }
    
    static RetainIf() {
        TryOp.Value(42).RetainIf((x) => (x > 20)).Get()
             .AssertEquals(42)
    }

    static RemoveIf() {
        TryOp.Value(42).RemoveIf((x) => (x > 20))
            .OrElse("failed")
            .AssertEquals("failed")
    }

    static Map1() {
        TryOp.Value(2).Map((x) => (x * 2))
            .OrElse(0).AssertEquals(4)
    }

    static Map2() {
        static Mapper(Str) {
            throw MethodError()
        }

        TryOp.Value("example").Map(Mapper)
            .OrElse("failed")
            .AssertEquals("failed")
    }

    static FlatMap1() {
        TryOp.Value("example")
            .FlatMap((Str) => TryOp.Success("(" . Str . ")"))
            .OrElse("")
            .AssertEquals("(example)")
    }

    static FlatMap2() {
        Mapper(Str) {
            throw MethodError()
        }
        TryOp.Value("example").FlatMap(Mapper)
            .OrElse("failed")
            .AssertEquals("failed")
    }

    static Get1() {
        TryOp.Value(42).Get().AssertEquals(42)
    }

    static Get2() {
        TestSuite.AssertThrows(() => (
            TryOp.Failure(Error()).Get()
        ))
    }

    static OrElse() {
        TryOp.Value(42).Map((x) => (x / 0))
            .OrElse("failed")
            .AssertEquals("failed")
    }

    static OrElseGet() {
        TryOp.Value(42)
            .Map((x) => (x / 0))
            .OrElseGet(Err => Err.Message)
            .AssertType(String)
    }

    static OrElseRun() {
        Result := unset

        TryOp.Failure(Error())
            .OrElseRun(() => Result := "failed")

        IsSet(Result).AssertEquals(true)
    }

    static OrElseThrow() {
        TestSuite.AssertThrows(() => (
            TryOp.Failure(Error()).OrElseThrow()
        ))
    }

    static Recover1() {
        TryOp.Failure(MethodError("failed"))
            .Recover(MethodError, (Err) => Err.Message)
            .OrElse("")
            .AssertEquals("failed")
    }

    static Recover2() {
        TryOp.Failure(MethodError("failed"))
            .Recover((Err) => (Err is Error),
                     (Err) => (Err.Message))
            .OrElse("")
            .AssertEquals("failed")
    }
}
