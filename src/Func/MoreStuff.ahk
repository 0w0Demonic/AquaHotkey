#Requires AutoHotkey v2.0

#Include <AquaHotkeyX>
#Include <AquaHotkey\src\Func\Cast>

/**
 * 
 */
class Reducer extends Func {
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        ObjSetBase(Map, ObjGetBase(this))
        return Map

        Map(Acc, Value) => this(Acc, Mapper(Value, Args*))
    }

    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        ObjSetBase(RetainIf, ObjGetBase(this))
        return RetainIf

        RetainIf(Acc, Value) {
            if (Condition(Value, Args*)) {
                return this(Acc, Value)
            }
            return Acc
        }
    }

    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        ObjSetBase(RemoveIf, ObjGetBase(this))
        return RemoveIf

        RemoveIf(Acc, Value) {
            if (Condition(Value, Args*)) {
                return Acc
            }
            return this(Acc, Value)
        }
    }
}

class FileStream extends Continuation {
    static Call(Pattern, Mode := "F") {
        return this.Cast(FileLoop)

        FileLoop(Downstream) {
            loop files Pattern, Mode {
                if (!Downstream(A_LoopFilePath)) {
                    return
                }
            }
        }
    }
}

class Continuation extends Func {
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
     * Creates a new Continuation that transforms its element with the given
     * mapper function before passing it onto the next stage.
     * 
     * ```ahk
     * Mapper(Value: Any) => Any
     * ```
     * 
     * @param   {Func}  Mapper  mapper function
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

    FlatMap(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(Result)

        Result(Downstream) {
            return this(FlatMap)

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

    Limit(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        Count := 0
        return this.Cast(Result)

        Result(Downstream) {
            return this(Limit)

            Limit(Value?) => (++Count <= n) && Downstream(Value?)
        }
    }

    Skip(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        Count := 0
        return this.Cast(Result)

        Result(Downstream) {
            return this(Skip)

            Skip(Value?) => (++Count <= n) || Downstream(Value?)
        }
    }

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

    DropWhile(Condition, Args*) {
        GetMethod(Condition)
        Drop := true
        return this.Cast(Result)

        Result(Downstream) {
            return this(DropWhile)

            DropWhile(Value?) {
                if (Drop && (Drop &= Condition(Value?, Args*))) {
                    return true
                }
                return Downstream(Value?)
            }
        }
    }

    Distinct(KeyExtractor?, MapParam?) {
        ; TODO
    }

    Peek(Action, Args*) {
        GetMethod(Action)
        return this.Cast(Result)

        Result(Downstream) {
            return this(Peek)

            Peek(Value?) {
                Action(Value?, Args*)
                return Downstream(Value?)
            }
        }
    }

    ; TODO same as `.Peek()`, but using the return value as termination flag

    ForEach(Action, Args*) {
        GetMethod(Action)
        this(ForEach)

        ForEach(Value) {
            Action(Value, Args*)
            return true
        }
    }

    ToArray() {
        Arr := Array()
        this.ForEach(Val => Arr.Push(Val))
        return Arr
    }

    Reduce(Reducer, Initial?) {
        this.ForEach(Reduce)
        return Initial

        Reduce(Value) {
            if (!IsSet(Initial)) {
                Initial := Value
            } else {
                Initial := Reducer(Initial, Value)
            }
        }
    }

    Find(&OutValue, Condition, Args*) {
        GetMethod(Condition)
        OutValue := unset

        Found := false
        this(Find)
        return Found

        Find(Value?) {
            if (Condition(Value?, Args*)) {
                OutValue := (Value?)
                Found := true
                return false
            }
            return true
        }
    }

    Any(Condition, Args*) {
        GetMethod(Condition)
        Found := false
        this(Any)
        return Found

        Any(Value?) {
            if (Condition(Value?, Args*)) {
                Found := true
                return false
            }
            return true
        }
    }

    All(Condition, Args*) {
        GetMethod(Condition)
        ReturnValue := true
        this(All)

        All(Value?) {
            if (!Condition(Value?, Args*)) {
                ReturnValue := false
                return false
            }
            return true
        }
    }

    None(Condition, Args*) {
        GetMethod(Condition)
        ReturnValue := true
        this(None)
        
        None(Value?) {
            if (Condition(Value?, Args*)) {
                ReturnValue := false
                return false
            }
            return true
        }
    }

    Join(Delim := "", Prefix := "", Suffix := "") {
        Result := ""
        Result .= Prefix

        this.ForEach(Join)

        Result .= Suffix
        return Result

        Join(Value) {
            if (Result == "") {
                Result .= String(Value)
            } else {
                Result .= Delim
                Result .= String(Value)
            }
        }
    }

    JoinLine() => this.Join("`r`n")

    __Enum(ArgSize) => this.ToArray().__Enum(ArgSize)
}
