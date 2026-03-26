#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Base\Primitives>

#Include <AquaHotkey\src\Func\Cast>
#Include <AquaHotkey\src\Monads\Optional>
#Include "%A_LineFile%\..\MatchResult.ahk"

/**
 * @extension Extensions related to {@link Parser}.
 */
class AquaHotkey_Parser extends AquaHotkey {
    class String {
        /**
         * Parses this string using the given parser and optional starting
         * position.
         * 
         * @param   {Parser}    Psr  the parser to be used
         * @param   {Integer?}  Pos  starting position
         * @returns {MatchResult}
         */
        Parse(Psr, Pos := 1) {
            if (!(Psr is Parser)) {
                throw TypeError("Expected a Parser",, Type(Psr))
            }
            return Psr(&this, Pos)
        }
    }
}

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
 * @template T type of output value on successful parsing
 */
class Parser extends Func {
    ;@region Patterns

    /**
     * Creates a parser that matches exactly one character.
     * 
     * @returns {Parser<String>}
     * @example
     * "a".Parser(Parser.Char()) ; MatchResult.Success { Value: "a", Pos: 2 }
     */
    static Char() => this.Chars(1)

    /**
     * Creates a parser that matches a specified amount of any character.
     * `NumChars` must be a positive integer.
     * 
     * @param   {Integer}         NumChars  amount of characters to be matched
     * @returns {Parser<String>}
     * @example
     * x4_chars := Parser.Chars(4)
     */
    static Chars(NumChars) {
        if (!IsInteger(NumChars)) {
            throw TypeError("Expected an Integer",, Type(NumChars))
        }
        if (NumChars <= 0) {
            throw ValueError("Must be > 0",, NumChars)
        }
        return this.Cast(Chars)

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

    /**
     * Creates a parser that matches a specified word `Str` with word
     * boundaries, otherwise any word defined by regex `\w+`.
     * 
     * Case-sensitivity is consistent with `StrCompare`, and only applies when
     * `Str` is set.
     * 
     * @param   {String?}           Str        the word to be matched
     * @param   {String?|Integer?}  CaseSense  case sensitivity
     * @returns {Parser<String>}
     */
    static Word(Str?, CaseSense?) {
        static IsWord(s) => IsAlpha(s) || IsDigit(s) || (s == "_")

        if (!IsSet(Str)) {
            return this.OneOrMore(IsWord, "word")
        }
        if (!(Str is Primitive)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        return this.String(Str).NotImmediatelyFollowedBy(IsWord, "\w")
    }

    /**
     * Creates a parser that matches exactly one digit.
     * 
     * @returns {Parser<String>}
     */
    static Digit() => this.One(IsDigit, "digit")

    /**
     * Creates a parser that matches one or more digits (as determined by
     * `IsDigit`).
     * 
     * @returns {Parser<String>}
     */
    static Digits() => this.OneOrMore(IsDigit, "digits")

    /**
     * Creates a parser that matches a specified string `Str` with the given
     * case-sensitivity (consistent with `StrCompare`). `Str` must be a
     * non-empty string.
     * 
     * @param   {String}            Str        the string to be matched
     * @param   {String?|Integer?}  CaseSense  case sensitivity
     * @returns {Parser<String>}
     */
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
            if ((Pos + Len - 1) <= StrLen(Input)) {
                Current := SubStr(Input, Pos, Len)
                if (!StrCompare(Current, Str, CaseSense?)) {
                    return MatchResult.Success(Current, Pos + Len)
                }
            }
            return MatchResult.Failure(Str, Pos)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Predicate Patterns

    /**
     * Creates a parser that matches exactly one character as determined by
     * a predicate function `Condition`.
     * 
     * @param   {Predicate}  Condition  function that matches characters
     * @param   {String}     Name       name of the pattern
     * @returns {Parser<String>}
     */
    static One(Condition, Name) {
        GetMethod(Condition)
        if (!(Name is Primitive)) {
            throw TypeError("Expected a String",, Type(Name))
        }
        return this.Cast(One)

        One(&Input, Pos := 1) {
            if (Pos > StrLen(Input)) {
                return MatchResult.Failure("Out of bounds", Pos)
            }
            Char := SubStr(Input, Pos, 1)
            return Condition(Char)
                ? MatchResult.Success(Char, Pos + 1)
                : MatchResult.Failure("One of " . Name, Pos)
        }
    }

    /**
     * Creates a parser that matches one or more characters - greedily - as
     * determined by a predicate function `Condition`.
     * 
     * @param   {Predicate}  Condition  function that matches characters
     * @param   {String}     Name       name of the pattern
     * @returns {Parser<String>}
     */
    static OneOrMore(Condition, Name) {
        GetMethod(Condition)
        if (!(Name is Primitive)) {
            throw TypeError("Expected a String",, Type(Name))
        }
        return this.Cast(OneOrMore)

        OneOrMore(&Input, Pos := 1) {
            if (Pos > StrLen(Input)) {
                return MatchResult.Failure("Out of bounds", Pos)
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

    /**
     * Creates a parser that matches zero or more characters, greedily, as
     * determined by a predicate function.
     * 
     * @param   {(Char) => Boolean}  Fn    character predicate
     * @param   {String}             Name  pattern name
     */
    static ZeroOrMore(Fn, Name) => this.OneOrMore(Fn, Name).OrElse(Name)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Pattern Searching

    /**
     * Creates a parser that searches for the first occurrence of a string,
     * discarding any characters before it. Case-sensitivity is consistent with
     * `StrCompare`.
     * 
     * @param   {String}            Pattern    the string to be searched for
     * @param   {String?|Integer?}  CaseSense  case sensitivity
     * @returns {Parser<String>}
     */
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

    /**
     * Creates a parser that searches for the first occurrence of a regex
     * pattern, discarding any characters before it. `Mapper` is a function
     * that maps the regex match object to the value of the successful parse
     * result. By default, it returns the entire matched string
     * (i.e. `MatchObj[0]`).
     * 
     * @param   {String}            Pattern    regex pattern to be searched for
     * @param   {String?|Integer?}  CaseSense  case sensitivity
     * @returns {Parser<String>}
     */
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

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Combinations

    /**
     * Creates a parser that matches if any of the given parsers match.
     * 
     * @param   {Parser*}  Parsers  zero or more parsers
     * @returns {Parser}
     * @example
     * Choice(Parsers*) => Parser.AnyOf(Parsers*)
     * Once(Condition, Name) => Parser.One(Condition, Name)
     * 
     * Word := Choice(
     *     Once(IsAlpha, "alpha"),
     *     Once(IsDigit, "digit"),
     *     Once(Eq("_"), "underscore")
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
                return MatchResult.Failure("Out of bounds", Pos)
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

    /**
     * Creates a parser consisting of the specified parsers in sequence.
     * `Combiner` is a function that receives all captured values as varargs,
     * and the combines them into a final result.
     * 
     * @template                  R         return value of `Combiner`
     * @param   {(Values*) => R}  Combiner  function that combines all values
     * @param   {Parser*}         Parsers   two or more parsers
     * @returns {Parser<R>}
     */
    static Sequence(Combiner, Parsers*) {
        GetMethod(Combiner)
        if (Parsers.Length < 2) {
            throw ValueError("At least two parsers are required",,
                    Parsers.Length)
        }
        for P in Parsers {
            if (!(P is Parser)) {
                throw TypeError("Expected a Parser",, Type(P))
            }
        }
        return this.Cast(Sequence)

        Sequence(&Input, Pos := 1) {
            Values := Array()
            for P in Parsers {
                Result := P(&Input, Pos)
                if (!Result.Ok) {
                    return Result
                }
                Pos := Result.Pos
                Values.Push(Result.Value)
            }

            return MatchResult.Success(Combiner(Values*), Result.Pos)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Quantifications

    /**
     * Returns a parser that applies the current parser at least once,
     * greedily. `Combiner` accepts all values are varargs, and combines
     * them into a final result.
     * 
     * @param   {Func?}  Combiner  function that combines values
     * @returns {Parser}
     */
    AtLeastOnce(Combiner := Array) {
        GetMethod(Combiner)
        return this.Cast(AtLeastOnce)

        AtLeastOnce(&Input, Pos := 1) {
            Values := Array()
            loop {
                Result := this(&Input, Pos)
                if (!Result.Ok) {
                    break
                }
                Pos := Result.Pos
                Values.Push(Result.Value)
            }
            return (Values.Length)
                ? MatchResult.Success(Combiner(Values*), Result.Pos)
                : MatchResult.Failure("at least once", Pos)
        }
    }

    /**
     * Creates a parse that matches `this` parser one or more times, each
     * captured values separated with the specified delimiter and then
     * later combined by using the `Combiner` function.
     * 
     * @template                 R         return type of `Combiner`
     * @param   {String|Parser}  Delim     delimiter
     * @param   {(Args*) => R}   Combiner
     * @returns {Parser<R>}
     */
    AtLeastOnceDelimitedBy(Delim, Combiner := Array) {
        if (Delim is Primitive) {
            Delim := Parser.String(Delim)
        }
        if (!(Delim is Parser)) {
            throw TypeError("Expected a String or Parser",, Type(Delim))
        }
        GetMethod(Combiner)
        return Parser.Sequence(
            (x, xs) => Combiner(x, xs*),
            this,
            Delim.Then(this).ZeroOrMore()
        )
    }

    /**
     * Returns a parser that matches zero or more times.
     * 
     * @template                 R         return type of `Combiner`
     * @param    {(Args*) => T}  Combiner  function that combines all values
     * @returns  {Parser<R>}
     */
    ZeroOrMore(Combiner := Array) => this.AtLeastOnce(Combiner).OrElse("")

    ZeroOrMoreDelimited(First, Second, Delim, Combiner) {

    }

    ZeroOrMoreDelimitedBy(Delim, Combiner?) {
        if (Delim is Primitive) {
            Delim := Delim ; TODO
        }

        ; TODO
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Prefix/Suffix

    Between(Prefix, Suffix) {
        if (Prefix is Primitive) {
            Prefix := Parser.String(Prefix)
        }
        if (Suffix is Primitive) {
            Suffix := Parser.String(Suffix)
        }
        if (!(Prefix is Parser)) {
            throw TypeError("Expected a String or Parser",, Type(Prefix))
        }
        if (!(Suffix is Parser)) {
            throw TypeError("Expected a String or Parser",, Type(Suffix))
        }
        return Prefix.Then(this).FollowedBy(Suffix)
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

    FollowedBy(Suffix) {
        if (!(Suffix is Parser)) {
            throw TypeError("Expected a Parser",, Type(Suffix))
        }
        return Parser.Sequence(
                (Value, *) => Value,
                this,
                Suffix)
    }

    NotFollowedBy(Suffix, Name) {
        if (!(Suffix is Parser)) {
            throw TypeError("Expected a Parser",, Type(Suffix))
        }
        if (!(Name is Primitive)) {
            throw TypeError("Expected a String",, Type(Name))
        }
        return this.Cast(NotFollowedBy)

        NotFollowedBy(&Input, Pos := 1) {
            Result := this(&Input, Pos)
            if (!Result.Ok) {
                return Result
            }
            Result := Suffix(&Input, Result.Pos)
            return (Result.Ok)
                ? Result.Failure("unexpected " . Name, Pos)
                : Result
        }
    }

    FollowedByOrEnd(Other) {

    }

    /**
     * Provides a convenient way to create a parser that can reference itself
     * recursively.
     * 
     * @param   {(Parser) => Parser>}  Mapper  function that create a new parser
     * @returns {Parser}
     * @example
     * Num := Parser.Digit()
     * Expr := Parser.Define(
     *     Expr => Parser.AnyOf(Expr.Between("(", ")"), Num)
     * )
     * 
     * ; MatchResult.Success { Pos: 10, Value: 5 }
     * Expr(&Input := "((((5))))")
     */
    static Define(Mapper) {
        GetMethod(Mapper)

        ; Create a "useless" parser that delegates to nothing.
        ; Then, pass that to `Mapper` so it can produce a parser that's able
        ; to reference itself recursively. Retroactively assign that to
        ; `Delegate` to define the actual function.
        Delegate := unset
        Psr := this.Cast((&Input, Pos := 1) => Delegate(&Input, Pos))

        Delegate := Mapper(Psr)
        if (!(Delegate is Parser)) {
            throw TypeError("Expected a Parser",, Type(Delegate))
        }
        return Psr
    }

    FlatMap(Mapper) {
        GetMethod(Mapper)
        return this.Cast(FlatMap)

        FlatMap(&Input, Pos := 1) {
            Result := this(&Input, Pos)
            return (Result.Ok)
                ? Mapper(Result.Value)(&Input, Result.Pos)
                : Result
        }
    }


    static Literally(Psr_or_Rule) {

    }

    Map(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(Map)

        Map(&Input, Pos := 1) {
            Result := this(&Input, Pos)
            return (Result.Ok)
                ? MatchResult.Success(Mapper(Result.Value, Args*), Pos)
                : Result
        }

    }

    NotImmediatelyFollowedBy(Condition, Name) {

    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Matching

    /**
     * Determines whether this parser matches the beginning of the specified
     * `Input` string.
     * 
     * @param   {VarRef<String>}  Input  the string to be matched
     * @returns {Boolean}
     */
    IsPrefixOf(&Input) => (this(&Input) is MatchResult.Success)

    /**
     * Determines whether this parser matches the *entirety* of the specified
     * `Input` string. This is similar to having `^$` or `\A\Z` anchors in
     * regular expressions.
     * 
     * @param   {VarRef<String>}  Input  the string to be matched
     * @returns {Boolean}
     */
    Matches(&Input) {
        Result := this(&Input)
        return Result.Ok && ((Result.Pos - 1) == StrLen(Input))
    }

    /**
     * Creates a parser that returns an {@link Optional} that contains the
     * captured value, if and only if matching was successful, otherwise an
     * empty optional.
     * 
     * @returns {Parser<Optional<T>>}
     */
    Optional() => this.Map(Optional).OrElse(Optional)

    OptionallyFollowedBy(Suffix, Combiner?) {

    }

    Then(Other) {
        if (!(Other is Parser)) {
            throw TypeError("Expected a Parser",, Type(Other))
        }
        return this.FlatMap((_) => Other)
    }

    /**
     * Returns a parser that matches `this` or `Other`.
     * 
     * @template U return type of `Other` parser
     * @param   {Parser<U>}    Other  the other parser
     * @returns {Parser<T|U>}
     */
    Else(Other) => Parser.AnyOf(this, Other)

    OrElse(DefaultValue) {
        return this.Cast(OrElse)

        OrElse(&Input, Pos := 1) {
            Result := this(&Input, Pos)
            return Result.Ok
                ? Result
                : MatchResult.Success(DefaultValue, Pos)
        }
    }

    OrElseGet(Supplier) {
        GetMethod(Supplier)
        return this.Cast(OrElseGet)

        OrElseGet(&Input, Pos := 1) {
            Result := this(&Input, Pos)
            return (Result.Ok)
                ? Result
                : MatchResult.Success(Supplier(), Pos)
        }
    }

    Parse(&Input, Pos := 1) {

    }

    ParseSkipping(Skip, &Input) {

    }
}

#Include <AquaHotkey\src\Func\Monoid>
#Include <AquaHotkey\src\Func\Predicate>

Unspread(Fn) {
    GetMethod(Fn)
    return (Args*) => Fn(Args)
}

Spread(Fn) {
    GetMethod(Fn)
    return (Args) => Fn(Args*)
}

Psr := Parser.Digit().AtLeastOnceDelimitedBy(",", (Args*) => Args.Reduce(Sum))
Psr(&Input := "1,2,3,4,5").ToString().MsgBox()