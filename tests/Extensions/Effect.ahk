/**
 * AquaHotkey - Effect.ahk - TESTS
 *
 * Author: 0w0Demonic
 *
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Extensions/Effect.ahk
 */

;@region Cont Tests
class Cont {
    static Of_LiftsPureValue() {
        result := Cont.Of(42).Await()
        result.AssertEquals(42)
    }

    static Then_ChainsComputations() {
        result := Cont.Of(5)
            .Then(x => Cont.Of(x * 2))
            .Then(x => Cont.Of(x + 1))
            .Await()
        result.AssertEquals(11)
    }

    static Map_TransformsValue() {
        result := Cont.Of(10)
            .Map(x => x * 3)
            .Await()
        result.AssertEquals(30)
    }

    static AndThen_SequencesComputations() {
        first := false
        second := false

        Cont.Of(1)
            .Map(x => (first := true, x))
            .AndThen(Cont.Of(2).Map(x => (second := true, x)))
            .Await()

        first.AssertEquals(true)
        second.AssertEquals(true)
    }

    static Await_ThrowsOnAsync() {
        ; This should throw because the computation is async
        TestSuite.AssertThrows(() => (
            Cont((k) => SetTimer(() => k(1), -100)).Await()
        ))
    }
}
;@endregion

;@region Result Tests
class Result {
    static Ok_CreatesSuccessResult() {
        r := Result.Ok(42)
        r.IsOk.AssertEquals(true)
        r.IsErr.AssertEquals(false)
        r.Value.AssertEquals(42)
    }

    static Err_CreatesErrorResult() {
        r := Result.Err("oops")
        r.IsOk.AssertEquals(false)
        r.IsErr.AssertEquals(true)
        r.Error.AssertEquals("oops")
    }

    static Try_CatchesErrors() {
        r := Result.Try(() => {
            throw Error("test error")
        })
        r.IsErr.AssertEquals(true)
        (r.Error is Error).AssertEquals(true)
    }

    static Try_ReturnsOkOnSuccess() {
        r := Result.Try(() => 42)
        r.IsOk.AssertEquals(true)
        r.Value.AssertEquals(42)
    }

    static Map_TransformsOk() {
        r := Result.Ok(5).Map(x => x * 2)
        r.IsOk.AssertEquals(true)
        r.Value.AssertEquals(10)
    }

    static Map_PropagatesErr() {
        r := Result.Err("error").Map(x => x * 2)
        r.IsErr.AssertEquals(true)
        r.Error.AssertEquals("error")
    }

    static FlatMap_ChainsResults() {
        r := Result.Ok(5)
            .FlatMap(x => Result.Ok(x * 2))
            .FlatMap(x => Result.Ok(x + 1))
        r.Value.AssertEquals(11)
    }

    static FlatMap_PropagatesErr() {
        r := Result.Ok(5)
            .FlatMap(x => Result.Err("failed"))
            .FlatMap(x => Result.Ok(x + 1))
        r.IsErr.AssertEquals(true)
        r.Error.AssertEquals("failed")
    }

    static OrElse_ReturnsValueOnOk() {
        Result.Ok(42).OrElse(0).AssertEquals(42)
    }

    static OrElse_ReturnsDefaultOnErr() {
        Result.Err("error").OrElse(0).AssertEquals(0)
    }

    static OrElseGet_CallsSupplierOnErr() {
        called := false
        Result.Err("x").OrElseGet(() => (called := true, 99))
        called.AssertEquals(true)
    }

    static OrThrow_ReturnsValueOnOk() {
        Result.Ok(42).OrThrow().AssertEquals(42)
    }

    static OrThrow_ThrowsOnErr() {
        TestSuite.AssertThrows(() => Result.Err("error").OrThrow())
    }

    static MapErr_TransformsError() {
        r := Result.Err("small")
            .MapErr(e => e . " -> big")
        r.Error.AssertEquals("small -> big")
    }

    static MapErr_IgnoresOk() {
        r := Result.Ok(42).MapErr(e => "transformed")
        r.Value.AssertEquals(42)
    }

    static Match_CallsCorrectBranch() {
        okResult := Result.Ok(10).Match(v => v * 2, e => 0)
        okResult.AssertEquals(20)

        errResult := Result.Err("x").Match(v => v * 2, e => -1)
        errResult.AssertEquals(-1)
    }
}
;@endregion

;@region Effect Tests
class Effect {
    static Pure_CreatesEffect() {
        e := Effect.Pure(42)
        e.Tag.AssertEquals("Pure")
        e.Payload.AssertEquals(42)
    }

    static Delay_ValidatesInput() {
        TestSuite.AssertThrows(() => Effect.Delay(-1))
        TestSuite.AssertThrows(() => Effect.Delay("string"))
    }

    static Delay_CreatesEffect() {
        e := Effect.Delay(100)
        e.Tag.AssertEquals("Delay")
        e.Payload.AssertEquals(100)
    }

    static Try_RequiresCallable() {
        TestSuite.AssertThrows(() => Effect.Try("not a function"))
    }

    static Try_CreatesEffect() {
        e := Effect.Try(() => 42)
        e.Tag.AssertEquals("Try")
    }

    static Fetch_AddsProtocol() {
        e := Effect.Fetch("example.com")
        e.Payload.AssertEquals("https://example.com")
    }

    static Fetch_PreservesProtocol() {
        e := Effect.Fetch("http://example.com")
        e.Payload.AssertEquals("http://example.com")
    }

    static ReadFile_CreatesEffect() {
        e := Effect.ReadFile("test.txt")
        e.Tag.AssertEquals("ReadFile")
        e.Payload.AssertEquals("test.txt")
    }

    static WriteFile_CreatesEffect() {
        e := Effect.WriteFile("out.txt", "content")
        e.Tag.AssertEquals("WriteFile")
        e.Payload.Path.AssertEquals("out.txt")
        e.Payload.Content.AssertEquals("content")
    }

    static Log_CreatesEffect() {
        e := Effect.Log("test message")
        e.Tag.AssertEquals("Log")
    }

    static Unit_CreatesEmptyEffect() {
        e := Effect.Unit()
        e.Tag.AssertEquals("Pure")
    }
}
;@endregion

;@region Do Tests
class Do {
    static EmptyDo_ReturnsEmptyContext() {
        result := Do().Compile().Await()
        (result is Map).AssertEquals(true)
        result.Count.AssertEquals(0)
    }

    static Let_BindsValue() {
        result := Do()
            .Let("x", Effect.Pure(42))
            .Compile()
            .Await()

        result["x"].AssertEquals(42)
    }

    static Let_ChainsBindings() {
        result := Do()
            .Let("a", Effect.Pure(1))
            .Let("b", Effect.Pure(2))
            .Let("c", Effect.Pure(3))
            .Compile()
            .Await()

        result["a"].AssertEquals(1)
        result["b"].AssertEquals(2)
        result["c"].AssertEquals(3)
    }

    static Let_AcceptsContextFunction() {
        result := Do()
            .Let("x", Effect.Pure(10))
            .Let("y", ctx => Effect.Pure(ctx["x"] * 2))
            .Compile()
            .Await()

        result["y"].AssertEquals(20)
    }

    static Then_ExecutesWithoutBinding() {
        executed := false
        Do()
            .Then(Effect.Pure(() => executed := true))
            .Compile()
            .Await()

        executed.AssertEquals(true)
    }

    static Return_ProducesValue() {
        result := Do()
            .Let("x", Effect.Pure(5))
            .Let("y", Effect.Pure(10))
            .Return(ctx => ctx["x"] + ctx["y"])
            .Compile()
            .Await()

        result.AssertEquals(15)
    }

    static When_TakesTrueBranch() {
        result := Do()
            .Let("x", Effect.Pure(10))
            .When(
                ctx => ctx["x"] > 5,
                Do().Let("branch", Effect.Pure("then")),
                Do().Let("branch", Effect.Pure("else"))
            )
            .Return(ctx => ctx["branch"])
            .Compile()
            .Await()

        result.AssertEquals("then")
    }

    static When_TakesFalseBranch() {
        result := Do()
            .Let("x", Effect.Pure(3))
            .When(
                ctx => ctx["x"] > 5,
                Do().Let("branch", Effect.Pure("then")),
                Do().Let("branch", Effect.Pure("else"))
            )
            .Return(ctx => ctx["branch"])
            .Compile()
            .Await()

        result.AssertEquals("else")
    }

    static Run_WithCallback() {
        received := ""
        Do()
            .Let("msg", Effect.Pure("hello"))
            .Return(ctx => ctx["msg"])
            .Run(v => received := v)

        ; Note: Pure effects are sync so this works
        received.AssertEquals("hello")
    }
}
;@endregion

;@region EffectRunner Tests
class EffectRunner {
    static Interpret_Pure_ReturnsValue() {
        result := EffectRunner.Interpret(Effect.Pure(42)).Await()
        result.AssertEquals(42)
    }

    static Interpret_Pure_CallsThunk() {
        result := EffectRunner.Interpret(Effect.Pure(() => 42)).Await()
        result.AssertEquals(42)
    }

    static Interpret_Try_Success() {
        result := EffectRunner.Interpret(Effect.Try(() => 42)).Await()
        result.IsOk.AssertEquals(true)
        result.Value.AssertEquals(42)
    }

    static Interpret_Try_Failure() {
        result := EffectRunner.Interpret(Effect.Try(() => {
            throw Error("test")
        })).Await()
        result.IsErr.AssertEquals(true)
    }

    static Interpret_Log_Succeeds() {
        ; Log should complete without error
        result := EffectRunner.Interpret(Effect.Log("test")).Await()
        result.AssertEquals(true)
    }

    static Interpret_UnknownTag_Throws() {
        TestSuite.AssertThrows(() => (
            EffectRunner.Interpret(Effect("UnknownTag", "")).Await()
        ))
    }
}
;@endregion
