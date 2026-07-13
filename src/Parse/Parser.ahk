#Include "%A_LineFile%\..\MatchResult.ahk"
#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Func\Cast.ahk"
#Include "%A_LineFile%\..\..\Monads\Optional.ahk"
#Include "%A_LineFile%\..\..\Stream\DoubleStream.ahk"

;@region Parser

; TODO allow `unset` as return value?

/**
 * A simple parser combinator intended to parse grammers such as regex,
 * csv format string patterns etc.
 * 
 * Parser combinators consist of multiple smaller components - parser
 * functions - which are defined as follows:
 * 
 * ParserFunction(&Input, Pos := 1)
 * 
 * Parser functions are defined as follows:
 * 
 * ```ahk
 * Psr(Input: VarRef<String>, Pos: Integer :=  1)
 *   => MatchResult.Success | MatchResult.Failure
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
     * `Len` must be a positive integer.
     * 
     * @param   {Integer}  Len  amount of characters to be matched
     * @returns {Parser<String>}
     * @example
     * x4_chars := Parser.Chars(4)
     */
    static Chars(Len) {
        if (!IsInteger(Len)) {
            throw TypeError("Expected an Integer",, Type(Len))
        }
        if (Len <= 0) {
            throw ValueError("Must be > 0",, Len)
        }
        return this.Cast(Chars)

        Chars(&Input, Pos := 1) {
            return ((Pos + Len - 1) > StrLen(Input))
                ? MatchResult.Failure(Len . " characters", Pos)
                : MatchResult.Success(SubStr(Input, Pos, Len), Pos + Len)
        }
    }

    /**
     * Matches whitespace characters. `Len`, if specified, represents the number
     * of characters matched.
     * 
     * @param   {Integer?}  Len  string length
     * @returns {Parser<String>}
     */
    static Whitespace(Len?) {
        if (!IsSet(Len)) {
            return this.ZeroOrMore(IsSpace, "whitespace")
        }
        return this.Chars(Len).SuchThat(IsSpace)
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

        switch {
          case (!IsSet(Str)):
            return this.OneOrMore(IsWord, "word")
          case (!(Str is Primitive)):
            throw TypeError("Expected a String",, Type(Str))
          default:
            return this.String(Str, CaseSense?).NotFollowedBy(IsWord, "\w")
        }
    }

    /**
     * Creates a parser that matches exactly one digit.
     * 
     * @returns {Parser<String>}
     */
    static Digit() => this.One(IsDigit, "digit").Map(Number)

    /**
     * Creates a parser that matches one or more digits (as determined by
     * `IsDigit`).
     * 
     * @returns {Parser<String>}
     */
    static Digits() => this.OneOrMore(IsDigit, "digits").Map(Number)

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

    /**
     * Returns a parser that matches the end of a string.
     * 
     * @returns {Parser<String>}
     */
    static End() {
        ; turn `End` into a closure
        Unused := 0
        return this.Cast(End)

        End(&Input, Pos := 1) {
            (Unused)
            return (Pos == StrLen(Input))
                ? MatchResult.Success("", Pos)
                : MatchResult.Failure("(end)", Pos)
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
     * @param   {String?}    Name       name of the pattern
     * @returns {Parser<String>}
     */
    static One(Condition, Name := GetMethod(Condition).Name) {
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
     * @param   {String?}    Name       name of the pattern
     * @returns {Parser<String>}
     */
    static OneOrMore(Condition, Name := GetMethod(Condition).Name) {
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
    static ZeroOrMore(Fn, Name?) => this.OneOrMore(Fn, Name?).OrElse("")

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Pattern Searching

    /**
     * Creates a parser that searches for the first occurrence of a string
     * (`InStr`), discarding any characters before it.
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
     * Creates a parser that matches a regular expression that has to match
     * exactly at the specified position. This is done with the help of PCRE's
     * `(*COMMIT)` feature.
     * 
     * `Mapper` converts a regex match object into a result. By default, it
     * returns the entire matched string (i.e. `MatchObj[0]`).
     * 
     * @template                         R          return type of `Mapper`
     * @param   {String}                 Pattern    regex pattern to search
     * @param   {(RegExMatchInfo) => R}  Mapper     function that creates value
     * @returns {Parser<R>}
     */
    static Regex(Pattern, Mapper?) => this.FirstRegex(
        RegExReplace(Pattern, "^(?:[\w``]++\))?", "$0(*COMMIT)(?:") . ")",
        Mapper?
    )

    /**
     * Creates a parser that searches for the first occurrence of a regex
     * pattern, discarding any characters before it. `Mapper` is a function
     * that maps the regex match object to the value of the successful parse
     * result. By default, it returns the entire matched string
     * (i.e. `MatchObj[0]`).
     * 
     * @template                         R          return type of `Mapper`
     * @param   {String}                 Pattern    regex pattern to search
     * @param   {(RegExMatchInfo) => R}  Mapper     function that creates value
     * @returns {Parser<R>}
     */
    static FirstRegex(Pattern, Mapper := DefaultMapper) {
        /**
         * Returns the overall string match of the regex match object.
         * @param   {RegExMatchInfo}  MatchObj  a regex match object
         * @returns {String}
         */
        static DefaultMapper(MatchObj) => MatchObj[0]

        ; assert that `Pattern` compiles correctly
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

    /**
     * Creates a parser that searches for all occurrences of this parser,
     * discarding any other information.
     * 
     * @template                R         return type of `Combiner`
     * @param   {(Args*) => R}  Combiner  function that creates value
     * @returns {Parser<R>}
     */
    FindAll(Combiner := Array) {
        GetMethod(Combiner)
        return this.Cast(FindAll)

        FindAll(&Input, Pos := 1) {
            Values := Array()
            Len := StrLen(Input)

            while (Pos <= Len) {
                Result := this(&Input, Pos)
                if (Result.Ok) {
                    Values.Push(Result.Value)
                    Pos := Result.Pos
                } else {
                    Pos++
                }
            }
            
            return (Values.Length)
                ? MatchResult.Success(Combiner(Values*), Pos)
                : MatchResult.Failure("no matches", Pos)
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
            GetMethod(Psr)
        }
        return this.Cast(AnyOf)

        AnyOf(&Input, Pos := 1) {
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
            GetMethod(P)
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
            return MatchResult.Success(Combiner(Values*), Pos)
        }
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
        GetMethod(Delegate)
        return Psr
    }

    /**
     * Creates a parser that behaves like `Psr`, but can be used in a static
     * context. This method is useful for recursive parsers that need to
     * reference themselves directly or indirectly.
     * 
     * @param   {VarRef<Parser>}  Psr  reference to the parser to be defined
     * @returns {Parser}
     */
    static Rule(&Psr) => this.Cast((&Input, Pos := 1) => Psr(&Input, Pos))

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Quantifications

    /**
     * Returns a parser that applies the current parser at least once,
     * greedily. `Combiner` accepts all values are varargs, and combines
     * them into a final result.
     * 
     * @template                R         return type of `Combiner`
     * @param   {(Args*) => R}  Combiner  function that combines all values
     * @returns {Parser<R>}
     * @example
     * ; MatchResult.Success { Pos: 5, Value: 10 (1 + 2 + 3 + 4) }
     * "1234".Parse(Parser.Digit().AtLeastOnce((Nums*) => Nums.Sum()))
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
     * @example
     * Psr := Parser.Digit().AtLeastOnceDelimitedBy("|")
     * 
     * ; MatchResult.Success { Pos: 6, Value: [1, 2, 3] }
     * "1|2|3".Parse(Psr)
     */
    AtLeastOnceDelimitedBy(Delim, Combiner := Array) {
        if (Delim is Primitive) {
            Delim := this.Cast(Parser.String(Delim))
        }
        GetMethod(Delim)
        GetMethod(Combiner)
        return this.Cast(Parser.Sequence(
            (x, xs) => Combiner(x, xs*),
            this,
            Delim.Then(this).ZeroOrMore(Array, [])
        ))
    }

    /**
     * Returns a parser that matches zero or more times.
     * 
     * @template                 R             return type of `Combiner`
     * @param    {(Args*) => T}  Combiner      function that combines all values
     * @param    {Any?}          DefaultValue  default value on failure
     * @returns  {Parser<R>}
     */
    ZeroOrMore(Combiner := Array, DefaultValue := []) {
        return this.AtLeastOnce(Combiner).OrElse(DefaultValue)
    }

    /**
     * Creates a parser which matches the `First` and `Second` pattern in
     * order, delimited with `Delim`, collecting the results using `Combiner`
     * which accepts a {@link DoubleStream} of key-value pairs.
     * 
     * @template                 R         return type of `Combiner`
     * @param   {Parser}         First     first parser
     * @param   {Parser}         Second    first parser
     * @param   {String|Parser}  Delim     delimiter
     * @param   {(Strm*) => R}   Combiner  function that combines all values
     * @returns {Parser<R>}
     * @example
     * Psr := Parser.ZeroOrMoreDelimited(
     *     Parser.Word().FollowedBy(":"), ; key
     *     Parser.Digits(),               ; value (only integers)
     *     ",",                           ; delimiter
     *     Strm => Strm.ToMap()           ; double stream to map
     * ).Between("{", "}")
     * 
     * ; MatchResult.Success { Pos: 15, Value: Map { bar: 1, foo: 23 } }
     * "{foo:23,bar:1}".Parse(Psr).ToString().MsgBox()
     */
    static ZeroOrMoreDelimited(First, Second, Delim, Combiner) {
        GetMethod(Combiner)
        return this.Sequence(Array, First, Second)
            .ZeroOrMoreDelimitedBy(Delim,
                (Pairs*) => Combiner(Pairs.Stream().Split(
                    (A) => A[1],
                    (A) => A[2]
                ))
            )
    }

    /**
     * Creates a parser that matches the current parser zero or more times,
     * delimited by `Delim`. `Combiner` is a function that combines all results
     * into a final result.
     * 
     * @template                 R             return type of `Combiner`
     * @param   {String|Parser}  Delim         delimiter pattern
     * @param   {(Args*) => R}   Combiner      function that combines all values
     * @param   {Any?}           DefaultValue  fallback default value
     * @returns {Parser<R>}
     * @example
     * ; MatchResult.Success { Pos: 8, Value: ["a", "b", "c" ] }
     * "[a,b,c]".Parse(
     *     Parser.OneOrMore(IsAlpha, "item")
     *           .ZeroOrMoreDelimitedBy(",")
     *           .Between("[", "]")
     * )
     */
    ZeroOrMoreDelimitedBy(Delim, Combiner := Array, DefaultValue := []) {
        return this.AtLeastOnceDelimitedBy(Delim, Combiner)
                   .OrElse(DefaultValue)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Prefix/Suffix

    /**
     * Returns a parser that matches `this` parser between `Prefix` and
     * `Suffix`, which are non-empty and discarded from the result value.
     * 
     * @param   {String|Parser}  Prefix  prefix pattern
     * @param   {String|Parser}  Suffix  suffix pattern
     * @returns {Parser<T>}
     * @example
     * ; MatchResult.Success { Pos: 4, Value: 1 }
     * "<1>".Parse( Parser.Digit().Between("<", ">") )
     */
    Between(Prefix, Suffix := Prefix) {
        if (Prefix is Primitive) {
            Prefix := this.Cast(Parser.String(Prefix))
        }
        if (Suffix is Primitive) {
            Suffix := this.Cast(Parser.String(Suffix))
        }
        GetMethod(Prefix)
        GetMethod(Suffix)
        return Prefix.Then(this).FollowedBy(Suffix)
    }

    /**
     * Matches the characters quoted by `Before` and `After`, and return the
     * string in between.
     * 
     * @param   {String|Parser}    Before  before pattern
     * @param   {String?|Parser?}  After   after pattern
     * @returns {Parser<T>}
     */
    QuotedBy(Before, After := Before) {
        if (Before is Primitive) {
            Before := this.Cast(Parser.String(Before))
        }
        if (After is Primitive) {
            After := this.Cast(Parser.String(After))
        }
        GetMethod(Before)
        GetMethod(After)
        return this.Cast(QuotedBy)

        QuotedBy(&Input, Pos := 1) {
            Result := Before(&Input, Pos)
            if (!Result.Ok) {
                return Result
            }
            Result := this(&Input, Result.Pos)
            if (!Result.Ok) {
                return Result
            }
            Value := Result.Value
            Result := After(&Input, Result.Pos)
            return (Result.Ok)
                ? MatchResult.Success(Value, Result.Pos)
                : Result
        }
    }

    /**
     * If this parser matches, continue to match `Suffix`.
     * 
     * @param   {String|Parser}  Suffix  after pattern
     * @returns {Parser}
     */
    FollowedBy(Suffix) {
        if (Suffix is Primitive) {
            Suffix := this.Cast(Parser.String(Suffix))
        }
        GetMethod(Suffix)
        return this.Cast(Parser.Sequence(
                (Value, *) => Value,
                this,
                Suffix))
    }

    /**
     * Specifies that the matches pattern must be either followed by `Suffix`
     * or the end of the string.
     * 
     * @param   {String|Parser}  Suffix  pattern after this parser
     * @returns {Parser<T>}
     */
    FollowedByOrEnd(Suffix) {
        return this.FollowedBy(  Parser.AnyOf( Suffix, Parser.End() )  )
    }

    /**
     * If the `Other` parser matches, applies this given parser on the
     * remaining input.
     * 
     * @template             R      return value of other parser
     * @param   {Parser<R>}  Other  the next parser
     * @returns {Parser<R>}
     */
    Then(Other) {
        GetMethod(Other)
        return this.FlatMap((*) => Other)
    }

    /**
     * A form of negative lookahead such that the match is rejected if
     * followed by `Suffix`.
     * 
     * @param   {String|Parser}  Suffix  after pattern
     * @param   {String?}        Name    name of the pattern
     * @returns {Parser<T>}
     */
    NotFollowedBy(Suffix, Name?) {
        if (Suffix is Primitive) {
            if (!IsSet(Name)) {
                Name := Suffix
            }
            Suffix := this.Cast(Parser.String(Suffix))
        }
        GetMethod(Suffix)
        if (!IsSet(Name)) {
            Name := GetMethod(Suffix).Name
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
            return (Suffix(&Input, Result.Pos).Ok)
                ? Result.Failure("unexpected " . Name, Pos)
                : Result
        }
    }

    /**
     * If this parser matches, optionally matches `Suffix` with `Combiner`
     * to transform the current parser's result.
     * 
     * `Combiner`, if set, combines the two values into one, where the first
     * argument is the value of this parser, and the second argument
     * either the value of the other parser, or `unset`.
     * 
     * @param   {String|Parser}        Suffix    following pattern
     * @param   {(Curr, After?) => R}  Combiner  function combining values
     * @returns {Parser}
     */
    OptionallyFollowedBy(Suffix, Combiner?) {
        if (Suffix is Primitive) {
            Suffix := this.Cast(Parser.String(Suffix))
        }
        GetMethod(Suffix)
        if (!IsSet(Combiner)) {
            return this.FollowedBy( Suffix.OrElse("") )
        }
        GetMethod(Combiner)
        return this.Cast(OptionallyFollowedBy)

        OptionallyFollowedBy(&Input, Pos := 1) {
            Result := this(&Input, Pos)
            if (!Result.Ok) {
                return Result
            }
            Value := Result.Value
            Result := Suffix(&Input, Result.Pos)
            return (Result.Ok)
                ? MatchResult.Success(Combiner(Value, Result.Value), Result.Pos)
                : MatchResult.Success(Combiner(Value, unset), Pos)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Composition

    /**
     * If this parser matches, applies function `Fn` to get the next parser
     * to match in sequence.
     * 
     * @template        R     return type of new parser
     * @param   {Func}  Fn    function that produces a new parser
     * @param   {Any*}  Args  zero or more arguments
     * @returns {Parser<R>}
     * @example
     * LengthPrefix := Parser.Digits().FollowedBy(":")
     *                       .FlatMap(x => Parser.Chars(x))
     * 
     * ; MatchResult.Success { Pos: 6, Value: "abc" }
     * "3:abc".Parse(LengthPrefix)
     */
    FlatMap(Fn, Args*) {
        GetMethod(Fn)
        return this.Cast(FlatMap)

        FlatMap(&Input, Pos := 1) {
            Result := this(&Input, Pos)
            return (Result.Ok)
                ? Fn(Result.Value, Args*)(&Input, Result.Pos)
                : Result
        }
    }

    /**
     * If the parser matches, return the result of applying `Mapper` to the
     * match.
     * 
     * @template          R       return type of `Mapper`
     * @param   {T => R}  Mapper  mapper function
     * @param   {Any*}    Args    zero or more arguments
     * @returns {Parser<R>}
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(Map)

        Map(&Input, Pos := 1) {
            Result := this(&Input, Pos)
            return (Result.Ok)
                ? MatchResult.Success(Mapper(Result.Value, Args*), Result.Pos)
                : Result
        }
    }

    /**
     * Creates a parser that returns an {@link Optional} that contains the
     * captured value, if and only if matching was successful, otherwise an
     * empty optional.
     * 
     * @returns {Parser<Optional<T>>}
     */
    Optional() => this.Map(Optional).OrElseGet(Optional)

    /**
     * If the parser matches, returns the given result.
     * 
     * @template     V      type of `Value`
     * @param   {V}  Value  any value
     * @returns {Parser<V>}
     */
    ThenReturn(Value) => this.Map((*) => Value)

    /**
     * If this parser matches, applies the given `Condition` and disqualifies
     * the match if the condition is `false`.
     * 
     * @param   {(T, Args*) => Boolean}  Condition  predicate function
     * @param   {String?}                Name       name of pattern
     * @returns {Parser<T>}
     */
    SuchThat(Condition, Name := GetMethod(Condition).Name) {
        GetMethod(Condition)
        return this.Cast(SuchThat)

        SuchThat(&Input, Pos := 1) {
            Result := this(&Input, Pos)
            switch {
              case (!Result.Ok):
                return Result
              case (!Condition(Result.Value)):
                return MatchResult.Failure(Name, Pos)
              default:
                return Result
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Skipping

    /**
     * Returns a parser that discards the given pattern.
     * 
     * @param   {Parser<?>}  Skip  pattern to be discarded
     * @returns {Parser<T>}
     */
    Skipping(Skip) {
        GetMethod(Skip)
        return this.Cast(Skipping)

        Skipping(&Input, Pos := 1) {
            Result := Skip(&Input, Pos)
            return this(
                &Input,
                (Result.Ok) ? Result.Pos : Pos
            )
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Default Values

    /**
     * Returns a parser that matches `this` or `Other`.
     * 
     * @template U return type of `Other` parser
     * @param   {Parser<U>}    Other  the other parser
     * @returns {Parser<T|U>}
     */
    Or(Other) => Parser.AnyOf(this, Other)

    /**
     * If the parser doesn't match, returns the given default return value.
     * 
     * @param   {Any}  DefaultValue  default value
     * @returns {Parser}
     */
    OrElse(DefaultValue) {
        return this.Cast(OrElse)

        OrElse(&Input, Pos := 1) {
            Result := this(&Input, Pos)
            return Result.Ok
                ? Result
                : MatchResult.Success(DefaultValue, Pos)
        }
    }

    /**
     * If the parser doesn't match, calls the given `Supplier` to produce a
     * default return value.
     * 
     * @template           R         return type of `Supplier`
     * @param   {() => R}  Supplier  supplier function producing default value
     * @returns {Parser}
     */
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

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Matching

    /**
     * Determines whether this parser matches the beginning of the specified
     * `Input` string.
     * 
     * @param   {VarRef<String>}  Input  the string to be matched
     * @param   {Integer}         Pos    starting position in the string
     * @returns {Boolean}
     */
    IsPrefixOf(&Input, Pos := 1) => (this(&Input, Pos) is MatchResult.Success)

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
     * Parses a string and returns a value on success, otherwise throws an
     * error. Use {@link Parser#IsPrefixOf()}, 
     * 
     * @param   {VarRef<String>}  Input  input string
     * @param   {Integer?}        Pos    starting position in the string
     * @returns {T}
     */
    Parse(&Input, Pos := 1) {
        Result := this(&Input, Pos)
        if (Result.Ok) {
            return Result.Value
        }
        throw ValueError("unable to parse string: " . Result.Message,,
                Result.Pos)
    }

    /**
     * Parses a string while skipping patterns matched by `Skip`. An error
     * is thrown if unable to parse string.
     * 
     * @param   {String|Parser}  Skip  skip pattern
     * @param   {VarRef<String>}  Input  input string
     * @param   {Integer?}        Pos    starting position in the string
     * @returns {T}
     */
    ParseSkipping(Skip, &Input, Pos := 1) {
        return this.Skipping(Skip).Parse(&Input, Pos)
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extension methods related to {@link Parser}.
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
            return Psr.Parse(&this, Pos)
        }
    }
}
