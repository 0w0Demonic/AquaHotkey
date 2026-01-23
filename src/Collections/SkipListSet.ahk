; TODO fix this
#Include <AquaHotkeyX>
#Include "%A_LineFile%\..\..\Interfaces\Sizeable.ahk"
#Include "%A_LineFile%\..\..\Collections\Set.ahk"
#Include "%A_LineFile%\..\..\Collections\SkipListMap.ahk"

/**
 * A {@link Set} implementation of {@link SkipListMap}. Keys are sorted
 * by natural order (`.Compare()`) or using a custom {@link Comparator}
 * function.
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
    static Call(Values*) => this.FromMap(SkipListMap(), Values*)
}