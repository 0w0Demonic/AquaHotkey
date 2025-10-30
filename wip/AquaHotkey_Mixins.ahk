#Include "%A_LineFile%\..\..\Src\Core\AquaHotkey.ahk"
; #Include "%A_LineFile%\..\AquaHotkey.ahk"

/**
 * AquaHotkey - AquaHotkeyX.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Core/AquaHotkeyX.ahk
 * 
 * @description
 * Provides mixin-style composition similar to Ruby's `include` and `extend`.
 */
class AquaHotkey_Mixins extends AquaHotkey_MultiApply {
    static __New() => super.__New(Class)

    /**
     * Includes one or more mixin classes into the current class.
     * 
     * Each property defined in the mixin class will be attached to the
     * prototype of the target class.
     * 
     * @param   {Class}   Mixin   the mixin to apply
     * @param   {Class*}  Mixins  zero or more mixins to apply
     * @example
     * Primitive.Include(HasStringRepr)
     * "Hello, world".Display()
     * 
     * class HasStringRepr {
     *     Display() => MsgBox(String(this))
     * }
     */
    Include(Mixin, Mixins*) => AquaHotkey.ApplyMixin(this, Mixin, Mixins*)

    /**
     * Extends one or more classes with the current class used as mixin.
     * 
     * @param   {Class}   Cls      the class on which to apply the mixin
     * @param   {Class*}  Classes  one or more classes to apply the mixin on
     * @example
     * Enumerable1.Extend(Array)
     * Array(1, 2, 3).ForEach(MsgBox)
     * 
     * class Enumerable1 {
     *     ForEach(Action) {
     *         for Value in this {
     *             Action(this)
     *         }
     *         return this
     *     }
     * }
     */
    Extend(Cls, Classes*) => (AquaHotkey_MultiApply.__New)(this, Cls, Classes*)
}