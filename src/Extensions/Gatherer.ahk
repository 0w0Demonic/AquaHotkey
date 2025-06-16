
class Gatherer {
    static __New() {
        for Name in Array("Initializer", "Integrator", "Finisher") {
            if (!HasProp(this, Name)) {
                return
            }
            PropDesc := this.GetOwnPropDesc(Name)
            PropDesc.Get := GetterOf(this, this.%Name%)
            this.DefineProp(Name, PropDesc)
        }

        static GetterOf(this, f) => ((_) => ObjBindMethod(f,, this))
    }

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
                return
            }
            if (!HasProp(this, Name)) {
                throw UnsetError("Missing function: " . Name)
            }
            this.DefineProp(Name, { Get: GetterOf(this, this.%Name% )})
        }

        static GetterOf(this, f) => ((_) => ObjBindMethod(f,, this))
    }

    class WindowFixed extends Gatherer {
        __New(Size) {
            super.__New()
            if (!IsInteger(Size)) {
                throw TypeError("Expected an Integer",, Type(Size))
            }
            if (Size <= 0) {
                throw TypeError("Invalid window size",, Size)
            }
            this.DefineProp("Size", { Get: (Instance) => Size })
        }

        Initializer() {
            return Array()
        }

        Integrator(Arr, Downstream, Val?) {
            if (Arr.Length == this.Size) {
                Downstream(Arr.Clone())
                Arr.Length := 0
            }
            Arr.Push(Val?)
            return true
        }

        Finisher(Arr, Downstream) {
            Downstream(Arr.Clone())
        }
    }

    class WindowSliding extends Gatherer {
        __New(Size) {
            super.__New()
            if (!IsInteger(Size)) {
                throw TypeError("Expected an Integer",, Type(Size))
            }
            if (Size <= 0) {
                throw TypeError("Invalid window size",, Size)
            }
            this.DefineProp("Size", { Get: (Instance) => Size })
        }

        Initializer() {
            return Array()
        }

        Integrator(Arr, Downstream, Val?) {
            if (Arr.Length == this.Size) {
                Downstream(Arr.Clone())
                Arr.RemoveAt(1)
            }
            Arr.Push(Val?)
            return true
        }

        Finisher(Arr, Downstream) {
            Downstream(Arr.Clone())
        }
    }

    class Scan extends Gatherer {
        __New(Supplier, Merger) {
            super.__New()
            (GetMethod(Supplier) && GetMethod(Merger))
            this.Obj := Supplier()
            this.DefineProp("Merger",{ Get: (_) => Merger })
        }

        Initializer() {
            
        }

        Integrator(_, Downstream, Val?) {
            this.Obj := (this.Merger)(this.Obj, Val?)
            Downstream(this.Obj)
            return true
        }

        Finisher(_, Downstream) {

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
            if (!(Gath is Gatherer) && !HasBase(Gath, Gatherer)) {
                throw TypeError("Expected a Collector",, Type(Gath))
            }
            Initializer := Gath.Initializer
            Integrator  := Gath.Integrator
            Finisher    := Gath.Finisher

            Downstream := Array()
            Enumer     := Downstream.__Enum(1)
            Consumer   := (Array.Prototype.Push).Bind(Downstream)

            State    := Initializer()
            Finished := false

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
                if (!Finished) {
                    Finished := true
                    Finisher(State, Consumer)
                    Enumer := Downstream.__Enum(1)
                    return Enumer(&Out)
                }
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
                if (!Finished) {
                    Finished := true 
                    Finisher(State, Consumer)
                    Enumer := Downstream.__Enum(1)
                    return Enumer(&Out)
                }
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
                if (!Finished) {
                    Finished := true 
                    Finisher(State, Consumer)
                    Enumer := Downstream.__Enum(1)
                    return Enumer(&Out)
                }
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
                if (!Finished) {
                    Finished := true 
                    Finisher(State, Consumer)
                    Enumer := Downstream.__Enum(1)
                    return Enumer(&Out)
                }
                return false
            }
        }
    }
}
