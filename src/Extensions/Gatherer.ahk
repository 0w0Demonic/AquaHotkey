;@region Gatherer
/**
 * AquaHotkey - Gatherer.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Comparator.ahk
 * 
 * ---
 * 
 * ### Gatherers
 *
 * Gatherers are an interface used for processing a stream of input
 * elements into a stream of output elements.
 *
 * They originate from JDK 24's "Structured Concurrency & Stream Gatherers"
 * feature, now adapted for AquaHotkey. Gatherers shine particularly when
 * working with infinite streams or scenarios where one input produces multiple
 * outputs.
 *
 * ```ahk
 * ; <[1, 2, 3], [2, 3, 4], [3, 4, 5]>
 * Range(5).Gather(Gatherer.WindowSliding(3))
 * ```
 *
 * ---
 *
 * ### How They Work
 *
 * Gatherers consist of three separate methods, which determine:
 * - how to initialize internal state (`.Initializer()`);
 * - how to integrate new elements into the output stream (`.Integrator()`);
 * - optionally how to finalize after processing (`.Finisher()`).
 *
 * ---
 *
 * #### Internal Flow Example
 *
 * Let's take a look at `Gatherer.WindowFixed` for a quick example of
 * how Stream Gatherers operate internally.
 *
 * ```ahk
 * ; <[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]>
 * Range(10).Gather(Gatherer.WindowFixed(3))
 * ```
 *
 * ---
 *
 * **`.Initializer()`**
 *
 * Initializes the internal state for processing. In this case, we create an
 * array to collect elements into fixed-size windows.
 *
 * ```ahk
 * Initializer() => Array()
 * ```
 *
 * The returned state is passed to `.Integrator()` for each input element,
 * and should generally be an object.
 * 
 * Otherwise, you can wrap strings and numbers into VarRefs (e.g., `&Str`).
 *
 * ---
 *
 * **`.Integrator(State, Next, Args*)`**
 *
 * Contains the core processing logic for every input element.
 *
 * @param  {Any}   State  data initialized by `.Initializer()`
 * @param  {Func}  Next   function pushing results downstream
 * @param  {Any*}  Args   the current stream element(s)
 *
 * - `Next()` refers to the downstream's internal `.Push()` method.
 * - The return value controls stream termination (`true` = continue,
 *   `false` = stop).
 *
 * ```ahk
 * Integrator(State, Next, Val?) {
 *     if (State.Length == Size) {
 *         Next(State.Clone()) ; Push full window downstream
 *         State.Length := 0
 *     }
 *     State.Push(Val?)
 *     return true
 * }
 * ```
 * 
 * A convenient way to write gatherers for primitive types is to box/unbox them
 * as VarRefs.
 * 
 * ```ahk
 * Integrator(&Str, Next, Args*) { ... }
 * ```
 *
 * ---
 *
 * **`.Finisher(State, Next)`**
 *
 * Runs after all input elements have been processed.
 *
 * In `WindowFixed`, any remaining collected elements are flushed.
 *
 * ```ahk
 * Finisher(State, Next) {
 *     Next(State.Clone())
 * }
 * ```
 *
 * ---
 *
 * ### Implementing Your Own Gatherers
 *
 * Similar to AquaHotkey's Collector API, there are three ways
 * to create custom gatherers:
 *
 * ---
 *
 * **Method 1 — Direct constructor call (low-level, not recommended)**
 *
 * Even though this works well for some very trivial Collectors, gatherers
 * are usually too complex to construct directly.
 * 
 * ```ahk
 * WF_Initializer() { ... }
 * WF_Integrator(State, Next, Args*) { ... }
 * WF_Finisher(State, Next) { ... }
 *
 * WindowFixed := Gatherer(WF_Initializer,
 *                         WF_Integrator,
 *                         WF_Finisher)
 * ```
 *
 * ---
 *
 * **Method 2 — Subclass (recommended)**
 *
 * - Fully encapsulates state and logic.
 * - Clean, maintainable, reusable.
 * - **If you define you own `.__New()`, you must call `super.__New()`**.
 *
 * ```ahk
 * class WindowFixed extends Gatherer {
 *     __New(Size) {
 *         super.__New() ; important!
 * 
 *         if (!IsInteger(Size)) {
 *             throw ValueError("nope! wrong value.")
 *         }
 *         this.Size := Size
 *     }
 * 
 *     Initializer() {
 *         return Array()
 *     }
 *
 *     Integrator(State, Next, Val) {
 *         if (State.Length == this.Size) {
 *             Next(State.Clone())
 *             State.Length := 0
 *         }
 *         State.Push(Val)
 *         return true
 *     }
 *
 *     Finisher(State, Next) {
 *         Next(State.Clone())
 *     }
 * }
 * 
 * ... MyStream.Gatherer(WindowFixed())
 * ```
 *
 * ---
 *
 * **Method 3 — Static Gatherer Class**
 *
 * - All methods are static.
 * - The class itself is passed as the gatherer.
 * - Simpler for purely stateless or more trivial implementations.
 *
 * ```ahk
 * class MyGatherer extends Gatherer {
 *     static Initializer() { ... }
 *     static Integrator(State, Next, Val) { ... }
 *     static Finisher(State, Next) { ... }
 * }
 * 
 * ; use the class itself as gatherer.
 * ... MyStream.Collect(MyGatherer)
 * ```
 */
class Gatherer {
    /**
     * Initializes static gatherers.
     */
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

    /**
     * Create a new gatherer from the given integrator, integrator and
     * finisher functions.
     * 
     * @param   {Func?}  Initializer  initializes data
     * @param   {Func?}  Integrator   processes input elements
     * @param   {Func?}  Finisher     final action after stream terminates
     * @returns {Gatherer}
     */
    __New(Initializer?, Integrator?, Finisher?) {
        Define("Initializer", Initializer?)
        Define("Integrator",  Integrator?)
        Define("Finisher",    Finisher?)

        Define(Name, Function?) {
            if (IsSet(Function)) {
                GetMethod(Function)
                this.DefineProp(Name, {
                    Get:  (_)        => Function,
                    Call: (_, Args*) => Function(Args*)
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

    /**
     * Collects elements in the form of fixed-sized, non-overlapping windows.
     * 
     * @example
     * ; <[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]>
     * Range(10).Gather(_.WindowFixed(3))
     * 
     * @param   {Integer}  Size  window size
     * @returns {Gatherer}
     */
    class WindowFixed extends Gatherer {
        __New(Size) {
            super.__New()
            if (!IsInteger(Size)) {
                throw TypeError("Expected an Integer",, Type(Size))
            }
            if (Size <= 0) {
                throw TypeError("Invalid window size",, Size)
            }
            this.DefineProp("Size", { Get: (_) => Size })
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

    /**
     * Collects elements in the form of fixed-sized, overlapping windows.
     * 
     * @example
     * ; <[1, 2, 3], [2, 3, 4], [3, 4, 5]>
     * Range(5).Gather(_.WindowSliding(3))
     * 
     * @param   {Integer}  Size  window size
     * @returns {Gatherer}
     */
    class WindowSliding extends Gatherer {
        __New(Size) {
            super.__New()
            if (!IsInteger(Size)) {
                throw TypeError("Expected an Integer",, Type(Size))
            }
            if (Size <= 0) {
                throw TypeError("Invalid window size",, Size)
            }
            this.DefineProp("Size", { Get: (_) => Size })
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

    /**
     * Creates a stream gatherer that emits a running result using the given
     * initial value produced by `Supplier` by repeatedly combining values
     * using `Combiner`.
     * 
     * ```ahk
     * CrossSums := _.Scan(() => 0, (a, b := 0) => (a + b))
     * 
     * ; <1, 3, 6, 10>
     * Array(1, 2, 3, 4).Gather(CrossSums)
     * ```
     * 
     * @param   {Func}  Supplier  function to produce initial value
     * @param   {Func}  Combiner  function to merge values with
     * @returns {Gatherer}
     */
    class Scan extends Gatherer {
        __New(Supplier, Merger) {
            super.__New()
            (GetMethod(Supplier) && GetMethod(Merger))
            this.Obj := Supplier()
            this.DefineProp("Merger", { Get: (_) => Merger })
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
;@endregion

;@region Extensions
class AquaHotkey_Gatherer extends AquaHotkey {
static __New() {
    if (IsSet(AquaHotkey_Stream) && (AquaHotkey_Stream is Class)) {
        return super.__New()
    }

    MsgBox("
    (
    Stream support not found. `.Gather()` will be unavailable.
    To enable, import the Stream module.

    #Include .../Extensions/Stream.ahk
    )", "AquaHotkey - Gatherer.ahk", 0x40)
}

;@region Any
class Any {
    /**
     * Applies the given Gatherer to process the elements of the stream.
     * 
     * @param   {Gatherer}  Gath  the gatherer to apply
     * @returns {Stream}
     */
    Gather(Gath) => this.Stream().Gather(Gath)
} ; class Any
;@endregion

;@region Stream
class Stream {
    /**
     * Applies the given Gatherer to process the elements of the stream.
     * 
     * @param   {Gatherer}  Gath  the gatherer to apply
     * @returns {Stream}
     */
    Gather(Gath) {
        static S := Stream ?? ""
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
            case 1: return S(Gather1)
            case 2: return S(Gather2)
            case 3: return S(Gather3)
            case 4: return S(Gather4)
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
} ; class Stream
;@endregion
} ; class AquaHotkey_Gatherer extends AquaHotkey
;@endregion