; TODO implement IntersectBy, UnionBy, ExceptBy?
#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Collections\HashSet.ahk"
#Include "%A_LineFile%\..\..\Collections\HashMap.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"
#Include "%A_LineFile%\..\Stream.ahk"

/**
 * Experimental set addition and SQL-like join methods for {@link Stream}.
 * 
 * These methods rely on {@link HashSet}s, and therefore on
 * {@link AquaHotkey_Hash `.Hash()`} and {@link AquaHotkey_Eq `.Eq()`} to
 * determine whether two values are considered equal.
 * 
 * @see {@link Stream}
 * @see {@link HashSet}
 * @see {@link AquaHotkey_Hash `.Hash()`}
 * @see {@link AquaHotkey_Eq `.Eq()`}
 * @module <Stream/Joins>
 * @author 0w0Demonic
 * @see    https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Stream_Joins extends AquaHotkey {
class Stream {
    /**
     * Produces the set difference of this stream and the `Other`.
     * 
     * @param   {Enumerable1}  Other  any enumerable sequence
     * @returns {Stream}
     * @example
     * ; <1, 2, 3>
     * Stream.Of(1, 2, 3, 4).Except( [4, 5] )
     */
    Except(Other) {
        Elements := HashSet()
        return this.Cast(Except)

        Except(&Out) {
            if (!(Other is HashSet)) {
                Other := HashSet(Other*)
            }
            while (this(&Out)) {
                if (!Other.Contains(Out) && Elements.Add(Out)) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Produces the set intersection of this stream and the `Other`.
     * 
     * @param   {Enumerable1}  Other  any enumerable sequence
     * @returns {Stream}
     * @example
     * Range(1, 4).Intersect(Range(3, 10)) ; <3, 4>
     */
    Intersect(Other) {
        return this.Cast(Intersect)

        Intersect(&Out) {
            if (!(Other is HashSet)) {
                Other := HashSet(Other*)
            }
            while (this(&Out)) {
                if (Other.Contains(Out)) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Produces the set union of this stream and the `Other`. The resulting
     * stream first iterates through the current elements, before iterating
     * through `Other`.
     * 
     * @param   {Enumerable1}  Other  any enumerable sequence
     * @returns {Stream}
     * @example
     * ; <5, 6, 7, 8, 9, 10, 3, 4>
     * Range(5, 10).Union(3, 7)
     */
    Union(Other) {
        Elements := HashSet()
        Enumer := false
        return this.Cast(Union)

        Union(&Out) {
            if (!Enumer) {
                while (this(&Out)) {
                    if (Elements.Add(Out)) {
                        return true
                    }
                }
                if (Other is HashSet) {
                    Enumer := Other.__Enum(1)
                } else {
                    Enumer := HashSet(Other*).__Enum(1)
                }
            }

            while (Enumer(&Out)) {
                if (Elements.Add(Out)) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Performs an SQL-like `INNER JOIN` between two sequences based on
     * matching keys.
     * 
     * A *key selector* (used for `LHS` and `RHS`) can be either a 1-param
     * function that returns a key, or the name of a property that should be
     * treated as key.
     * 
     * ```ahk
     * KeySelector(Obj: Any) => Any
     * ```
     * 
     * The *combiner* function combines both elements into a result value. By
     * default, the stream produces size 2 arrays as elements.
     * 
     * ```
     * Combiner(Left: Any, Right: Any) => Any
     * ```
     * 
     * @param   {Enumerable1}    Other     any enumerable sequence
     * @param   {String|Func}    LHS       left-hand side key selector
     * @param   {String?|Func?}  RHS       right-hand side key selector
     * @param   {Func?}          Combiner  function producing result element
     * @returns {Stream}
     * @example
     * ArrA := [ { Key: 1, a: "a" },
     *           { Key: 2, b: "b" } ]
     * 
     * ArrB := [ { Key: 1, c: "c" },
     *           { Key: 1, d: "d" },
     *           { Key: 2, e: "e" } ]
     * 
     * ; [{ a: a, Key: 1 }, { c: c, Key: 1 }]
     * ; [{ a: a, Key: 1 }, { d: d, Key: 1 }]
     * ; [{ b: b, Key: 2 }, { e: e, Key: 2 }]
     * Stream(ArrA).InnerJoin(ArrB, "Key").JoinLine().ToClipboard()
     * 
     * ; same as above:
     * Stream(ArrA).InnerJoin(
     *     ArrB
     *     A => A.Key, B => B.Key,
     *     (A, B) => Array(A, B)
     * ).JoinLine().ToClipboard()
     */
    InnerJoin(Other, LHS, RHS := LHS, Combiner := Array) {
        if (LHS is Primitive) {
            LHS := ((Str) => (Obj) => Obj.%Str%)(LHS)
        }
        if (RHS is Primitive) {
            RHS := ((Str) => (Obj) => Obj.%Str%)(RHS)
        }

        GetMethod(LHS)
        GetMethod(RHS)
        GetMethod(Combiner)
        Lookup := false
        Enumer := (*) => false
        LV := unset
        LK := unset
        return this.Cast(InnerJoin)

        InnerJoin(&Out) {
            if (!Lookup) {
                Lookup := HashMap()
                for RV in Other {
                    RK := RHS(RV)
                    if (Lookup.TryGet(RK, &Arr)) {
                        Arr.Push(RV)
                    } else {
                        Lookup.Set(RK, Array(RV))
                    }
                }
            }

            loop {
                if (Enumer(&RV)) {
                    Out := Combiner(LV, RV)
                    return true
                }
                if (!this(&LV)) {
                    return false
                }
                LK := LHS(LV)
                Enumer := Lookup.Get(LK, Array()).__Enum(1)
            }
        }
    }

    /**
     * Correlates the elements of this stream and the `Other` based on key
     * equality, and groups the results.
     * 
     * A *key selector* (used for `LHS` and `RHS`) can be either a 1-param
     * function that returns a key, or the name of a property that should be
     * treated as key.
     * 
     * ```ahk
     * KeySelector(Obj: Any) => Any
     * ```
     * 
     * The *combiner* function combines an element on the "left" with a stream
     * of matching elements on the "right". By default, the stream produces size
     * 2 arrays as elements.
     * 
     * ```
     * Combiner(Left: Any, Right: Stream<Any>) => Any
     * ```
     * 
     * @param   {Enumerable1}    Other     any enumerable sequence
     * @param   {String|Func}    LHS       left-hand side key selector
     * @param   {String?|Func?}  RHS       right-hand side key selector
     * @param   {Func?}          Combiner  function producing result element
     * @returns {Stream}
     * @example
     * People := [
     *     Magnus    := { Name: "Magnus Hedlund"  },
     *     Terry     := { Name: "Terry Adams"     },
     *     Charlotte := { Name: "Charlotte Weiss" }
     * ]
     * 
     * Pets := [
     *     { Name: "Barley",   Owner: Terry     },
     *     { Name: "Boots",    Owner: Terry     },
     *     { Name: "Whiskers", Owner: Charlotte },
     *     { Name: "Daisy",    Owner: Magnus    }
     * ]
     * 
     * ; Magnus Hedlund: [Daisy]
     * ; Terry Adams: [Barley, Boots]
     * ; Charlotte Weiss: [Whiskers]
     * Stream(People).GroupJoin(
     *     Pets,
     *     Person => Person,
     *     Pet => Pet.Owner,
     *     (Person, Pets) {
     *         Str := Pets.Map(P => P.Name).Join(", ", "[", "]")
     *         return Person.Name . ": " . Str
     *     }
     * ).JoinLine().ToClipboard()
     */
    GroupJoin(Other, LHS, RHS := LHS, Mapper := Array) {
        if (LHS is Primitive) {
            LHS := ((Str) => (Obj) => Obj.%Str%)(LHS)
        }
        if (RHS is Primitive) {
            RHS := ((Str) => (Obj) => Obj.%Str%)(RHS)
        }

        GetMethod(LHS)
        GetMethod(RHS)
        GetMethod(Mapper)
        Lookup := false
        return this.Cast(GroupJoin)

        GroupJoin(&Out) {
            if (!Lookup) {
                Lookup := HashMap()
                for RV in Other {
                    RK := RHS(RV)
                    if (Lookup.TryGet(RK, &Arr)) {
                        Arr.Push(RV)
                    } else {
                        Lookup.Set(RK, Array(RV))
                    }
                }
            }

            while (this(&LV)) {
                LK := LHS(LV)
                if (Lookup.TryGet(LK, &Arr)) {
                    Out := Mapper(LV, Arr.Stream())
                    return true
                }
            }
            return false
        }
    }
} ; class Stream
} ; class AquaHotkey_Stream_Joins extends AquaHotkey
