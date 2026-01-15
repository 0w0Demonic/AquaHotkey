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
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(Result)

        Result(Downstream) {
            return this(Map)

            Map(Value) => Downstream(Mapper(Value, Args*))
        }
    }

    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Result)

        Result(Downstream) {
            this(RetainIf)

            RetainIf(Value) {
                if (Condition(Value, Args*)) {
                    return Downstream(Value)
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

            RemoveIf(Value) {
                if (!Condition(Value, Args*)) {
                    return Downstream(Value)
                }
                return true
            }
        }
    }

    TakeWhile(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Result)

        Result(Downstream, Value?) {
            this(TakeWhile)

            TakeWhile(Value) {
                return (Condition(Value, Args*) && Downstream(Value))
            }
        }
    }

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

    Join(Delim := "") {
        Result := ""
        this.ForEach(Join)
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

;FileStream("C:\*", "F")
;        .Map((*) => Format("{:-20} {:20}", A_LoopFileName, A_LoopFileAttrib))
;        .JoinLine()
;        .o0(MsgBox)

Factorial(X, Acc := 1) {
    if (X <= 1) {
        return Acc
    }
    return () => Factorial(X - 1, X * Acc)
}

Trampoline(Fn, Args*) {
    Result := Fn(Args*)
    while (Result is Func) {
        Result := Result()
    }
    return Result
}

MsgBox(Trampoline(Factorial, 12))