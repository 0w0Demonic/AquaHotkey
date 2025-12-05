/**
 * AquaHotkey - AquaHotkey_Ignore.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Core/AquaHotkey_Ignore.ahk
 * 
 * `AquaHotkey_Ignore` is a special marker class used to indicate that a class
 * should be excluded from AquaHotkey's class prototyping system. It serves as
 * a signal for AquaHotkey to skip over any class it is applied to, ensuring
 * that nested or non-prototyped classes do not undergo the class modification
 * that AquaHotkey typically performs on standard classes.
 * 
 * **When to use**:
 * 
 * - Extend the `AquaHotkey_Ignore` class to indicate that it should be ignored.
 * 
 * @example
 * 
 * class Tanuki extends AquaHotkey {
 *     class Util extends AquaHotkey_Ignore {
 *         ; this class will be ignored by AquaHotkey's prototyping
 *     }
 * }
 */
class AquaHotkey_Ignore {
    /**
     * Determines whether the current AHK version is above the specified
     * version.
     * 
     * @example
     * class Util extends AquaHotkey {
     *     static __New() {
     *         if (!this.VersionAbove("v2.1-alpha.3")) {
     *         
     *         }
     *     }
     * }
     * 
     * @param   {String}  Version  the required version
     * @returns {Boolean}
     */
    Version(Version) => VerCompare(A_AhkVersion, Version)

    /**
     * 
     */
    DeleteClassIfAbsent(PropertyName, Cls?) {
        if (!IsSet(Cls)) {
            this.DeleteProp(PropertyName)
        }
        return this
    }
}