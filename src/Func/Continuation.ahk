#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Func\Cast.ahk"

/**
 * Creates a new file stream.
 * 
 * @param   {String}   Pattern  file pattern
 * @param   {String?}  Mode     loop-files mode
 * @returns {Continuation}
 */
LoopFiles(Pattern, Mode := "F") {
    return Continuation.Cast(LoopFiles)

    LoopFiles(Downstream) {
        loop files Pattern, Mode {
            if (!Downstream(A_LoopFilePath)) {
                return
            }
        }
    }
}

/**
 * Creates a registry stream.
 * 
 * @param   {String}   KeyName  name of registry key
 * @param   {String?}  Mode     which items to include
 * @returns {Continuation}
 */
LoopReg(KeyName, Mode := "V") {
    return Continuation.Cast(LoopReg)

    LoopReg(Downstream) {
        loop reg KeyName, Mode {
            if (!Downstream(A_LoopRegName)) {
                return
            }
        }
    }
}

/**
 * Creates a string parse stream.
 * 
 * @param   {String}   Str        he string to analyze
 * @param   {String?}  Delim      delimiter string
 * @param   {String?}  OmitChars  chars to trim from results
 * @returns {Continuation}
 */
LoopParse(Str, Delim := "", OmitChars := "") {
    return Continuation.Cast(LoopParse)

    LoopParse(Downstream) {
        loop parse Str, Delim, OmitChars {
            if (!Downstream(A_LoopField)) {
                return
            }
        }
    }
}

/**
 * Creates a loop read stream.
 * 
 * @param   {String}   InputFile   file to read from
 * @param   {String?}  OutputFile  file to write into
 * @returns {Continuation}
 */
LoopRead(InputFile, OutputFile?) {
    InputFile .= ""
    if (IsSet(OutputFile)) {
        OutputFile .= ""
        Result := WithOutput
    } else {
        Result := WithoutOutput
    }
    return Continuation.Cast(Result)
    
    WithOutput(Downstream) {
        loop read InputFile, OutputFile {
            if (!Downstream(A_LoopReadLine)) {
                return
            }
        }
    }

    WithoutOutput(Downstream) {
        loop read InputFile {
            if (!Downstream(A_LoopReadLine)) {
                return
            }
        }
    }
}

/**
 * Allows the creation of pipelines in continuation-passing style.
 * 
 * @module  <Func/Continuation>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Continuation extends Func {
    static __New() {
        if (this == Continuation) {
            this.Backup(Enumerable1, Enumerable2)
        }
    }

    ;@region Filtering
    /**
     * Creates a continuation where elements are only passed to the next
     * stage if they fulfill the given condition.
     * 
     * ```ahk
     * Condition(Value: Any?) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Continuation}
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Result)

        Result(Downstream) {
            this(RetainIf)

            RetainIf(Value?) {
                if (Condition(Value?, Args*)) {
                    return Downstream(Value?)
                }
                return true
            }
        }
    }

    /**
     * Creates a continuation where elements are remove if they fulfill
     * the given condition.
     * 
     * ```ahk
     * Condition(Value: Any?) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any}   Args       zero or more arguments
     * @returns {Continuation}
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Result)

        Result(Downstream) {
            this(RemoveIf)

            RemoveIf(Value?) {
                if (!Condition(Value?, Args*)) {
                    return Downstream(Value?)
                }
                return true
            }
        }
    }

    /**
     * Creates a continuation limited to the first `n` elements.
     * 
     * @param   {Integer}  n  max count of elements to retrieve
     * @returns {Continuation}
     */
    Limit(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        return this.Cast(Result)

        Result(Downstream) {
            Count := 0
            this(Limit)

            Limit(Value?) => (++Count <= n) && Downstream(Value?)
        }
    }

    /**
     * Creates a continuation that skips the first `n` elements.
     * 
     * @param   {Integer}  n  count of elements to skip
     * @returns {Continuation}
     */
    Skip(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        return this.Cast(Result)

        Result(Downstream) {
            Count := 0
            this(Skip)

            Skip(Value?) => (++Count <= n) || Downstream(Value?)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Transformation

    /**
     * Creates a new continuation that transforms its elements with the given
     * mapper function before passing it onto the next stage.
     * 
     * ```ahk
     * Mapper(Value: Any?) => Any
     * ```
     * 
     * @param   {Func}  Mapper  mapper function
     * @param   {Any*}  Args    zero or more arguments
     * @returns {Continuation}
     * @example
     * FileLoop(A_Desktop . "\*", "DR").Map((*) => A_LoopFileName).ForEach(MsgBox)
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(Result)

        Result(Downstream) {
            return this(Map)

            Map(Value?) => Downstream(Mapper(Value?, Args*))
        }
    }

    /**
     * Creates a new continuation that transforms its elements with the given
     * mapper function, flattening resulting values and passing them onto the
     * the next stage.
     * 
     * ```ahk
     * Mapper(Value: Any?) => Enumerable1
     * ```
     * 
     * @param   {Func}  Mapper  mapper function
     * @param   {Any*}  Args    zero or more arguments
     * @returns {Continuation}
     */
    FlatMap(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(Result)

        Result(Downstream) {
            this(FlatMap)

            FlatMap(Value?) {
                for Elem in Mapper(Value?, Args*) {
                    if (Downstream(Elem?)) {
                        return false
                    }
                }
                return true
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Take/Drop

    /**
     * Creates a continuation that immediately terminates when an element
     * does not fulfill the given `Condition`.
     * 
     * ```ahk
     * Condition(Value: Any?) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Continuation}
     */
    TakeWhile(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Result)

        Result(Downstream) {
            this(TakeWhile)

            TakeWhile(Value?) {
                return (Condition(Value?, Args*) && Downstream(Value?))
            }
        }
    }

    /**
     * Creates a continuation that immediately terminates when an element
     * fulfills the given `Condition`.
     * 
     * ```ahk
     * Condition(Value: Any?) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Continuation}
     */
    TakeUntil(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Result)

        Result(Downstream) {
            this(TakeUntil)

            TakeUntil(Value?) {
                return (!Condition(Value?, Args*) && Downstream(Value?))
            }
        }
    }

    /**
     * Creates a continuation that skips the first elements as long as they
     * fulfill the given `Condition`.
     * 
     * ```ahk
     * Condition(Value: Any?) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Continuation}
     */
    DropWhile(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Result)

        Result(Downstream) {
            Drop := true
            this(DropWhile)

            DropWhile(Value?) {
                if (Drop && (Drop &= Condition(Value?, Args*))) {
                    return true
                }
                return Downstream(Value?)
            }
        }
    }

    /**
     * Creates a continuation that skips the first elements as long as they
     * do not fulfill the given `Condition`.
     * 
     * ```ahk
     * Condition(Value: Any?) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Continuation}
     */
    DropUntil(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Result)

        Result(Downstream) {
            Drop := true
            this(DropUntil)

            DropUntil(Value?) {
                if (Drop && (Drop &= !Condition(Value?, Args*))) {
                    return true
                }
                return Downstream(Value?)
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region .Distinct()

    /**
     * Creates a contination that retains only unique elements according to
     * the given classifier function and set.
     * 
     * ```ahk
     * Classifier(Value: Any?) => Any
     * ```
     * 
     * @param   {Func}  Classifier  function that retrieves map key
     * @param   {Any*}  SetParam    internal set options
     * @returns {Continuation}
     * @see {@link ISet.Create()}
     */
    Distinct(Classifier?, SetParam := Set()) {
        if (IsSet(Classifier)) {
            GetMethod(Classifier)
        }
        return this.Cast(Result)

        Result(Downstream) {
            S := ISet.Create(SetParam)
            if (IsSet(Classifier)) {
                return this(DistinctBy)
            } else {
                return this(Distinct)
            }

            Distinct(Value?) {
                if (S.Add(Value?)) {
                    return Downstream(Value?)
                }
                return true
            }

            DistinctBy(Value?) {
                if (S.Add(Classifier(Value?))) {
                    return Downstream(Value?)
                }
                return true
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Side Effects

    /**
     * Creates a continuation which calls the given `Action` on an element
     * before passing it to the next stage.
     * 
     * ```ahk
     * Action(Value: Any?) => void
     * ```
     * 
     * @param   {Func}  Action  the function to call
     * @param   {Any*}  Args    zero or more arguments
     * @returns {Continuation}
     */
    Peek(Action, Args*) {
        GetMethod(Action)
        return this.Cast(Result)

        Result(Downstream) {
            this(Peek)

            Peek(Value?) {
                Action(Value?, Args*)
                return Downstream(Value?)
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Reduction

    /**
     * Collects all elements to an array.
     * 
     * @returns {Array}
     */
    ToArray() {
        Arr := Array()
        this.ForEach((Value?) => Arr.Push(Value?))
        return Arr
    }

    /**
     * Performs the given `Action` for each element.
     * 
     * ```ahk
     * Action(Value: Any?) => void
     * ```
     * 
     * @param   {Func}  Action  the function to call
     * @param   {Any*}  Args    zero or more arguments
     */
    ForEach(Action, Args*) {
        this(ForEach)

        ForEach(Value?) {
            Action(Value?, Args*)
            return true
        }
    }

    /**
     * Reduces elements of the continuation into a final result.
     * 
     * ```ahk
     * Reducer(Left: Any, Right: Any?) => Any
     * ```
     * 
     * @param   {Func}  Reducer  combines two values repeatedly
     * @param   {Any?}  Initial  initial value
     * @returns {Any}
     */
    Reduce(Reducer, Initial?) {
        GetMethod(Reducer)
        if (!IsSet(Initial) && Reducer.Is(Monoid)) {
            Initial := Reducer.Identity
        }
        this(Reduce)
        return Initial

        Reduce(Value?) {
            if (!IsSet(Initial)) {
                Initial := (Value?)
            } else {
                Initial := Reducer(Initial, Value?)
            }
        }
    }

    /**
     * Returns an {@link Enumerator} for this continuation.
     * 
     * @param   {Integer}  ArgSize  param-size of for-loop
     * @returns {Enumerator}
     */
    __Enum(ArgSize) => this.ToArray().__Enum(ArgSize)
}
