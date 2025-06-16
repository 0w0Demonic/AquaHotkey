
class Gatherer {
    __New(Initializer?, Integrator?, Finisher?) {
        Define("Initializer", Initializer?)
        Define("Integrator",  Integrator?)
        Define("Finisher",    Finisher?)

        Define(Name, Function?) {
            if (IsSet(Function)) {
                GetMethod(Function)
                this.DefineProp(Name, {
                    Get:  (Instance)        => Function,
                    Call: (Instance, Args*) => Function(Args*)
                })
            }
            if (!HasProp(this, Name)) {
                throw UnsetError("Missing function: " . Name)
            }
        }
    }
}

class AquaHotkey_Gatherer extends AquaHotkey {
    static __New() {
        if (!IsSet(AquaHotkey_Stream)) {
            return
        }
        super.__New()
    }

    class Any {
        Gather(Gath) => this.Stream().Gather(Gath)
    }

    class Stream {
        Gather(Gath) {
            if (!(Gath is Gatherer)) {
                throw TypeError("Expected a Collector",, Type(Gath))
            }
            Initializer := Gath.Initializer
            Integrator  := Gath.Integrator
            Finisher    := Gath.Finisher

            Downstream := Array()
            Enumer     := Downstream.__Enum(1)
            Consumer   := (Array.Prototype.Push).Bind(Downstream)

            State := Initializer()

            f := this.Call
            switch (this.MaxParams) {
                case 1: return Stream(Gather1)
                case 2: return Stream(Gather2)
                case 3: return Stream(Gather3)
                case 4: return Stream(Gather4)
            }
            throw ValueError("invalid parameter length",, this.MaxParams)

            Gather1(&Out) {
                Loop {
                    if (Enumer(&Out)) {
                        return true
                    }
                    Downstream.Length := 0
                    if (!f(&A)) {
                        break
                    }
                    if (!Integrator(State, Consumer, A?)) {
                        break
                    }
                    Enumer := Downstream.__Enum(1)
                }
                Finisher(State, Consumer)
                return false
            }

            Gather2(&Out) {
                Loop {
                    if (Enumer(&Out)) {
                        return true
                    }
                    Downstream.Length := 0
                    if (!f(&A, &B)) {
                        break
                    }
                    if (!Integrator(State, Consumer, A?, B?)) {
                        break
                    }
                    Enumer := Downstream.__Enum(1)
                }
                Finisher(State, Consumer)
                return false
            }

            Gather3(&Out) {
                Loop {
                    if (Enumer(&Out)) {
                        return true
                    }
                    Downstream.Length := 0
                    if (!f(&A, &B, &C)) {
                        break
                    }
                    if (Integrator(State, Consumer, A?, B?, C?)) {
                        break
                    }
                    Enumer := Downstream.__Enum(1)
                }
                Finisher(State, Consumer)
                return false
            }

            Gather4(&Out) {
                Loop {
                    if (Enumer(&Out)) {
                        return true
                    }
                    Downstream.Length := 0
                    if (!f(&A, &B, &C, &D)) {
                        break
                    }
                    if (!Integrator(State, Consumer, A?, B?, C?, D?)) {
                        break
                    }
                    Enumer := Downstream.__Enum(1)
                }
                Finisher(State, Consumer)
                return false
            }
        }
    }
}
