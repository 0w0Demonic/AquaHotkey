#Include "%A_LineFile%\..\Set.ahk"
#Include "%A_LineFile%\..\SkipListMap.ahk"

/**
 * A {@link Set} implementation of {@link SkipListMap}. Keys are sorted
 * by {@link AquaHotkey_Comparable natural order} or using a custom
 * {@link Comparator comparator function}.
 * 
 * @module  <Collections/SkipListSet>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class SkipListSet extends Set {
    /**
     * Constructs a new SkipListSet containing the specified elements.
     * 
     * @constructor
     * @param   {Any*}  Values  zero or more elements
     * @returns {SkipListSet}
     */
    static Call(Values*) => this.FromMap(SkipListMap(Values*))

    /**
     * Creates a subclass of {@link SkipListSet} that uses the given
     * {@link Comparator} function.
     * 
     * @param   {Comparator}  Comp  comparator function
     * @returns {Class<? extends SkipListSet>}
     * @example
     * Cls := SkipListSet.WithComparator( Comparator.Num(StrLen).ThenAlpha() )
     * S := Cls("aa", "bb", "b", "ccc")
     * 
     * ; --> ["b", "aa", "bb", "ccc"]
     * S.ToArray()
     */
    static WithComparator(Comp) {
        MapCls := SkipListMap.WithComparator(Comp)

        Cls := Class()
        Proto := Object()
        Cls.Prototype := Proto
        Proto.DefineProp("Call", {
            Call: (Cls, Values*) => this.FromMap(MapCls(Values*))
        })

        ObjSetBase(Cls, this)
        ObjSetBase(Proto, this.Prototype)
        return Cls
    }
}
