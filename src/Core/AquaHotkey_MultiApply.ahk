#Include "%A_LineFile%\..\AquaHotkey_Backup.ahk"

/**
 * @description
 * 
 * `AquaHotkey_MultiApply` copies contents of one class into one or more
 * specified target classes. This is useful both for simple changes made
 * to a single class, or when changing multiple unrelated classes
 * (like `Gui.Button` and `Gui.CheckBox`) which should share a common
 * set of properties.
 * 
 * The easiest way to use this class is to use `Class#ApplyOnto()`.
 * 
 * Alternatively, create a subclass of `AquaHotkey_MultiApply` and call
 * `super.__New()` within the static constructor, passing the class(es)
 * you want to copy into.
 * 
 * @example
 * class Example {
 *     static __New() => this.ApplyOnto(Gui.Button, Gui.CheckBox)
 * 
 *     CommonProp() => MsgBox("I'm a CheckBox or a Button!")
 * }
 * 
 * @exports Class#ApplyOnto()
 * @see https://www.github.com/0w0Demonic/AquaHotkey
 * @author 0w0Demonic
 */
class AquaHotkey_MultiApply extends AquaHotkey_Ignore {
    /**
     * Static class initializer that copies properties and methods into one or
     * many destination classes. An error is thrown if a subclass calls this
     * method without passing any parameters.
     * 
     * @example
     * class CommonButtonControls extends AquaHotkey_MultiApply {
     *     static __New() => super.__New(Gui.Button, Gui.ComboBox)
     * }
     * 
     * @param   {Object*}  Targets  where to copy properties and methods into
     * @returns {this}
     */
    static __New(Targets*) {
        if (this == AquaHotkey_MultiApply) {
            return
        }
        if (!Targets.Length) {
            throw ValueError("No target class provided")
        }

        ; Use the same method as `AquaHotkey_Backup`, but with the supplier and
        ; receiver swapped.
        for Target in Targets {
            (AquaHotkey_Backup.__New)(Target, this)
        }
        return this
    }

    ;@region Class#ApplyOnto()
    class Extensions extends Any {
        static __New() {
            if (ObjGetBase(this) != Any) {
                throw TypeError("This class cannot be extended",,
                                this.Prototype.__Class)
            }
            AquaHotkey_MultiApply.DeleteProp("Extensions")
            (AquaHotkey_MultiApply.__New)(this, Class)
        }

        /**
         * Copies the properties and methods of the class into one or more
         * specified targets.
         * 
         * @example
         * class Enumerable1 {
         *     static __New() => this.ApplyOnto(Array)
         * 
         *     ForEach(Action, Args*) {
         *         for Value in this {
         *             Action(Value, Args*)
         *         }
         *         return this
         *     }
         * }
         * 
         * @param   {Object*}  Targets  targets to copy properties into
         * @returns {this}
         */
        ApplyOnto(Targets*) => (AquaHotkey_MultiApply.__New)(this, Targets*)
    }
    ;@endregion
}