#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Base\Primitives>

#Include <AquaHotkey\src\Func\Cast>
#Include <AquaHotkey\src\Monads\Optional>
#Include "%A_LineFile%\..\MatchResult.ahk"

/**
 * A simple parser combinator intended to parse grammers such as regex,
 * csv format string patterns etc.
 * 
 * Parsers and related object are intended to have the following
 * shape:
 * 
 * ```ahk
 * ParseResult := Type.Union(ParseSuccess(Any), ParseFailure)
 * 
 * ParseSuccess(T) => { Ok: true, Value: T, Pos: Integer }
 * ParseFailure    := { Ok: false, Err: String }
 * 
 * Psr(&Input: VarRef<String>, Pos: Integer := 1) => ParseResult
 * ```
 * 
 * @module  <Parse/Parser>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Parser extends Func {
    /**
     * Creates a parser that matches if any of the given parsers match.
     * 
     * @param   {Parser*}  Parsers  zero or more parsers
     * @returns {Parser}
     * @example
     * Choice(Args*) => Parser.AnyOf(Args*)
     * Once(Condition) => Parser.One(Condition)
     * 
     * Backslash_W := Choice(
     *     Once(IsAlpha),
     *     Once(IsDigit),
     *     Once(Eq("c")) ; Eq() as defined in `<Func/Predicate>`
     * )
     */
    static AnyOf(Parsers*) {
        if (!Parsers.Length) {
            throw ValueError("no parsers specified")
        }
        for Psr in Parsers {
            if (!(Psr is Parser)) {
                throw TypeError("Expected a Parser",, Type(Psr))
            }
        }
        return this.Cast(AnyOf)

        AnyOf(&Input, Pos := 1) {
            if (Pos > StrLen(Input)) {
                return Parser.OutOfBounds
            }
            for Psr in Parsers {
                Result := Psr(&Input, Pos)
                if (Result.Ok) {
                    return Result
                }
            }
            return MatchResult.Failure("Any of", Pos)
        }
    }

    static Unnamed => "(unnamed)"

    static One(Condition, Name := this.Unnamed) {
        GetMethod(Condition)
        if (!(Name is Primitive)) {
            throw TypeError("Expected a String",, Type(Name))
        }
        return this.Cast(One)

        One(&Input, Pos := 1) {
            if (Pos > StrLen(Input)) {
                return Parser.OutOfBounds
            }
            Char := SubStr(Input, Pos, 1)
            return Condition(Char)
                ? MatchResult.Success(Char, Pos + 1)
                : MatchResult.Failure("One of " . Name, Pos)
        }
    }

    static Consecutive(Condition, Name := this.Unnamed) {
        GetMethod(Condition)
        if (!(Name is Primitive)) {
            throw TypeError("Expected a String",, Type(Name))
        }
        return this.Cast(Consecutive)

        Consecutive(&Input, Pos := 1) {
            if (Pos > StrLen(Input)) {
                return Parser.OutOfBounds
            }
            Value := ""
            loop (StrLen(Input) - Pos + 1) {
                Char := SubStr(Input, Pos, 1)
                if (!Condition(Char)) {
                    break
                }
                Value .= Char
                Pos++
            }

            return (Value != "")
                ? MatchResult.Success(Value, Pos)
                : MatchResult.Failure("One or more of " . Name, Pos)
        }
    }

    static Chars(NumChars) {
        if (!IsInteger(NumChars)) {
            throw TypeError("Expected an Integer",, Type(NumChars))
        }
        if (NumChars <= 0) {
            throw ValueError("Must be > 0",, NumChars)
        }
        return Chars

        Chars(&Input, Pos := 1) {
            if ((Pos + NumChars - 1) > StrLen(Input)) {
                return MatchResult.Failure(
                    NumChars . " characters",
                    Pos)
            }
            return MatchResult.Success(
                    SubStr(Input, Pos, NumChars),
                    Pos + NumChars)
        }
    }

    static Word(Str?, CaseSense?) {
        ; TODO improve this
        static IsWord(s) => (s ~= "^\w$")

        if (IsSet(Str)) {
            if (!(Str is Primitive)) {
                throw TypeError("Expected a String",, Type(Str))
            }
            throw ValueError("not yet implemented")
            ; TODO
        }
        static DefaultWord := this.Consecutive(IsWord, "word")
        return DefaultWord
    }

    static Digits() => this.Consecutive(IsDigit, "digit")

    static First(Pattern, CaseSense?) {
        InStr("", Pattern)
        Len := StrLen(Pattern)
        return this.Cast(First)

        First(&Input, Pos := 1) {
            Index := InStr(Input, Pattern, CaseSense?, Pos)
            return (Index)
                ? MatchResult.Success(
                    SubStr(Input, Index, Len),
                    Index + Len)
                : MatchResult.Failure(
                    Pattern,
                    Pos)
        }
    }

    static FirstRegex(Pattern, Mapper := DefaultMapper) {
        static DefaultMapper(MatchObj) => MatchObj[0]

        RegExMatch("", Pattern)
        return this.Cast(FirstRegex)

        FirstRegex(&Input, Pos := 1) {
            Index := RegExMatch(Input, Pattern, &MatchObj, Pos)
            return (Index)
                ? MatchResult.Success(
                    Mapper(MatchObj),
                    Index + MatchObj.Len[0])
                : MatchResult.Failure(
                    Pattern,
                    Pos)
        }
    }

    static String(Str, CaseSense?) {
        if (!(Str is Primitive)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        if (Str == "") {
            throw ValueError("Cannot be empty",, "(empty string)")
        }
        Len := StrLen(Str)
        return this.Cast(String)

        String(&Input, Pos := 1) {
            Current := SubStr(Input, Pos, Len)
            return (!StrCompare(Current, Str, CaseSense?))
                ? MatchResult.Success(Current, Pos + Len)
                : MatchResult.Failure(Str, Pos)
        }
    }

    QuotedBy(Before, After) {
        if (Before is Primitive) {
            Before := Parser.String(Before)
        }
        if (After is Primitive) {
            After := Parser.String(After)
        }
        if (!(Before is Parser)) {
            throw TypeError("Expected a String or Parser",, Type(Before))
        }
        if (!(After is Parser)) {
            throw TypeError("Expected a String or Parser",, Type(After))
        }
        return this.Cast(QuotedBy)

        QuotedBy(&Input, Pos := 1) {
            Result := Before(&Input, Pos)
            if (!Result.Ok) {
                return Result
            }

            Pos := Result.Pos
            ; TODO
        }
    }

    /**
     * Returns a parser that applies the current parser at least once,
     * greedily.
     * 
     * @param   {Func?}  Combiner  function that combines two values
     * @returns {Parser}
     */
    AtLeastOnce(Combiner?) {
        if (!IsSet(Combiner)) {
            return this.Cast(AtLeastOnce)
        }
        GetMethod(Combiner)
        return this.Cast(AtLeastOnceWithReduce)

        AtLeastOnce(&Input, Pos := 1) {
            if (Pos > StrLen(Input)) {
                return Parser.OutOfBounds
            }

            Value := Array()
            loop {
                Result := this(&Input, Pos)
                if (!Result.Ok) {
                    break
                }
                Value.Push(Result)
                Pos := Result.Pos
            }
            if (!Value.Length) {
                return { Ok: false, Err: "unable to match" }
            }
            return { Ok: true, Pos: Value[-1].Pos, Value: Value }
        }

        AtLeastOnceWithReduce(&Input, Pos := 1) {
            if (Pos > StrLen(Input)) {
                return Parser.OutOfBounds
            }

            Value := Array()
            loop {
                Result := this(&Input, Pos)
                if (!Result.Ok) {
                    break
                }
                Value.Push(Result.Value)
                Pos := Result.Pos
            }
            if (!Value.Length) {
                return { Ok: false, Err: "unable to match" }
            }
            return { Ok: true, Pos: Pos, Value: Value.Reduce(Combiner) }
        }
    }

    AtLeastOnceDelimitedBy(Delim, Combiner?) {
        if (Delim is Primitive) {
            Delim := Delim ; TODO
        }
        ; TODO
    }

    static ZeroOrMore(Condition, Name) {

    }

    ZeroOrMore() {

    }

    ZeroOrMoreDelimited(First, Second, Delim, Combiner) {

    }

    ZeroOrMoreDelimitedBy(Delim, Combiner?) {
        if (Delim is Primitive) {
            Delim := Delim ; TODO
        }
        ; TODO
    }

    Between(Prefix, Suffix) {

    }

    static CaseInsensitive(Str) {

    }

    static CaseInsensitiveWord(Str) {

    }

    static Define() {

    }

    FlatMap(Mapper) {

    }

    FollowedBy(Other) {

    }

    FollowedByOrEnd(Other) {

    }

    IsPrefixOf(Input) {

    }

    static Literally(Psr_or_Rule) {

    }

    Map(Mapper) {

    }

    Matches(Input) {

    }

    NotFollowedBy(Suffix, Name?) {

    }

    NotImmediatelyFollowedBy(Condition, Name) {

    }

    One(Condition, Name) {

    }

    Optional() {

    }

    OptionallyFollowedBy(Suffix, Combiner?) {

    }

    Then(Other) {
        if (!(Other is Parser)) {
            throw TypeError("Expected a Parser",, Type(Other))
        }
        return this.Cast(Then)

        Then(&Input, Pos := 1) {
            if (Pos > StrLen(Input)) {
                return Parser.OutOfBounds
            }

            Result1 := this(&Input, Pos)
            if (!Result1.Ok) {
                return Result1
            }
            Result2 := Other(&Input, Result1.Pos)
            if (!Result2.Ok) {
                return Result2
            }
            return {
                Ok: true,
                Value: [Result1, Result2],
                Pos: Result2.Pos
            }
        }
    }

    OrElse(Other) {
        if (!(Other is Parser)) {
            throw TypeError("Expected a Parser",, Type(Other))           
        }
        return this.Cast(OrElse)

        OrElse(&Input, Pos := 1) {
            if (Pos > StrLen(Input)) {
                return Parser.OutOfBounds
            }

            Result1 := this(&Input, Pos)
            if (Result1.Ok) {
                return Result1
            }
            Result2 := Other(&Input, Pos)
            if (Result2.Ok) {
                return Result2
            }
            return {
                Ok: false,
                Err: "Expected " . String(this) . " or " . String(Other)
            }
        }
    }

    OrDefault(Default) {

    }

    Parse(&Input, Pos := 1) {

    }

    ParseSkipping(Skip, &Input) {

    }

    static OutOfBounds => { Ok: false, Err: "out of bounds" }
}

/**
 * Creates a parser that matches the given character with the specified
 * case-sensitivity (consistent with `StrCompare`).
 * 
 * @param   {String}               ExpectedChar  expected character
 * @param   {Primitive?|Integer?}  CaseSense     case sensitivity
 * @returns {Parser}
 * @example
 * Hello := Sequence(Char("h"), Char("e"), Char("l"), Char("l"), Char("o"))
 */
Char(ExpectedChar, CaseSense := true) {
    if (!(ExpectedChar is Primitive)) {
        throw TypeError("Expected a String",, Type(ExpectedChar))
    }
    if (StrLen(ExpectedChar) != 1) {
        throw ValueError("invalid string length",, StrLen(ExpectedChar))
    }
    StrCompare("", "", CaseSense)
    return Parser.Cast(Char)

    Char(&Input, Pos := 1) {
        if (Pos > StrLen(Input)) {
            return { Ok: false, Err: "out of bounds" }
        }
        CurrentChar := SubStr(Input, Pos, 1)
        if (!StrCompare(CurrentChar, ExpectedChar, CaseSense)) {
            return { Ok: true, Pos: Pos + 1, Value: CurrentChar }
        }
        return {
            Ok: false,
            Err: "Expected character: " . ExpectedChar
        }
    }
}

Str(ExpectedStr, CaseSense := true) {
    if (!(ExpectedStr is Primitive)) {
        throw TypeError("Expected a String",, Type(ExpectedStr))
    }
    StrCompare("", "", CaseSense)
    Len := StrLen(ExpectedStr)
    return Parser.Cast(Str)

    Str(&Input, Pos := 1) {
        if (Pos > StrLen(Input)) {
            return { Ok: false, Err: "out of bounds" }
        }
        CurrentStr := SubStr(Input, Pos, Len)
        if (!StrCompare(CurrentStr, ExpectedStr, CaseSense)) {
            return { Ok: true, Pos: Pos + Len, Value: CurrentStr }
        }
        return {
            Ok: false,
            Err: "Expected string: " . ExpectedStr
        }
    }
}

; TODO .AtLeastOnce() with some kind of collector support

#Include <AquaHotkey\src\Func\Monoid>
#Include <AquaHotkey\src\Func\Predicate>

Word := Parser.String("tesst")

Word(&Input := "test").ToString().MsgBox()
