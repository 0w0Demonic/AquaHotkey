#Requires AutoHotkey v2.0

class Transducer extends Func {
    static Call(Reducer) {
        GetMethod(Reducer)
        ; TODO use some kind of universal `Cast` method
        Fn := ObjBindMethod(Reducer)
        ObjSetBase(Fn, this.Prototype)
        return Fn
    }

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
    static Call(Pattern, Mode := "F", Args*) {
        return this.Cast(FileLoop)

        FileLoop(Downstream) {
            loop files Pattern, Mode {
                if (!Downstream(Args*)) {
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
            this(Map)

            Map(Value?) {
                if (IsSet(Value)) {
                    return Downstream(Mapper(Value, Args*))
                } else {
                    return Downstream(Mapper(Args*))
                }
            }
        }
    }

    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Result)

        Result(Downstream) {
            this(RetainIf)

            RetainIf(Value?) {
                if (IsSet(Value)) {
                    if (Condition(Value, Args*)) {
                        return Downstream(Value)
                    }
                } else if (Condition(Args*)) {
                    return Downstream()
                }
            }
        }
    }

    TakeWhile(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(Result)

        Result(Downstream, Value?) {
            this(TakeWhile)

            TakeWhile(Value?) {
                if (IsSet(Value)) {
                    return (Condition(Value, Args*) && Downstream(Value))
                } else {
                    return (Condition(Args*) && Downstream())
                }
            }
        }
    }

    ForEach(Action, Args*) {
        GetMethod(Action)
        this(ForEach)

        ForEach(Value?) {
            if (IsSet(Value)) {
                Action(Value, Args*)
            } else {
                Action(Args*)
            }
            return true
        }
    }
}