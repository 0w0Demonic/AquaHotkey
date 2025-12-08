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
     * @param   {String}  Version  the required version
     * @returns {Boolean}
     */
    static Version(Version) => VerCompare(A_AhkVersion, Version)

    /**
     * Asserts that the given version requirement is fulfilled, otherwise
     * deletes one or more properties from the class.
     *  
     * @example
     * this.RequiresVersion("v2.1-alpha.3", "Class", "Any")
     * 
     * @param   {String}   Version        version requirement
     * @param   {String}   PropertyPaths  affected property paths
     * @returns {this}
     */
    static RequiresVersion(Version, PropertyPaths*) {
        if (!PropertyPaths.Length) {
            throw UnsetError("No properties specified")
        }
        if (!this.Version(Version)) {
            this.Delete(PropertyPaths*)
        }
        return this
    }

    /**
     */
    static Delete(PropertyPaths*) {
        if (!PropertyPaths.Length) {
            throw UnsetError("No properties specified")
        }
        for PropertyPath in PropertyPaths {
            if (IsObject(PropertyPath)) {
                throw TypeError("Expected a String",, Type(PropertyPath))
            }
            Props := StrSplit(PropertyPath, "/")
            Name := Props.Pop()
            Obj := this
            for Prop in Props {
                Obj := Obj.%Prop%
            }
            ({}.DeleteProp)(Obj, Name)
        }
        return this
    }

    /**
     * Asserts that the given global class or other value is present, otherwise
     * deletes one or more properties from the class.
     * 
     * @example
     * this.Requires(AquaHotkey_Eq?, "Any")
     * 
     * @param   {Any?}     Symbol         any global variable
     * @param   {String*}  PropertyPaths  affected property paths
     * @returns {this}
     */
    static Requires(Symbol?, PropertyPaths*) {
        if (!PropertyPaths.Length) {
            throw UnsetError("No properties specified")
        }
        if (!IsSet(Symbol)) {
            this.Delete(PropertyPaths*)
        }
        return this
    }
}