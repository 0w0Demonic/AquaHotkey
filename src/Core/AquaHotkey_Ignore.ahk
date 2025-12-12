/**
 * @public
 * @abstract
 * @class
 * @classdesc
 * 
 * Marker class for indicating that a class should be ignored by
 * `AquaHotkey.__New()`.
 * 
 * @example
 * class MyStuff extends AquaHotkey
 * {
 *     ; extend built-in `String`
 *     class String {
 *     }
 * 
 *     ; this class will be ignored
 *     class Util extends AquaHotkey_Ignore {
 *     }
 * }
 */
class AquaHotkey_Ignore {
    /**
     * Determines whether the current AHK version is above the specified
     * version.
     * 
     * @public
     * @param   {String}  Version  the required version
     * @returns {Boolean}
     * @example
     * if (this.Version(">v2.1-alpha.3")) {
     *     this.Delete("String", "Class")
     * }
     */
    static Version(Version) => VerCompare(A_AhkVersion, Version)

    /**
     * Asserts that the given version requirement is fulfilled, otherwise
     * deletes one or more properties from the class.
     *  
     * @public
     * @param   {String}   Version        version requirement
     * @param   {String}   PropertyPaths  affected property paths
     * @returns {this}
     * @example
     * this.RequiresVersion("v2.1-alpha.3", "Class", "Any")
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
     * Deletes one or more property paths from the class.
     * 
     * @public
     * @param   {String*}  PropertyPaths  one or more property paths
     * @returns {this}
     * @example
     * this.Delete("String")
     */
    static Delete(PropertyPaths*) {
        if (!PropertyPaths.Length) {
            throw UnsetError("No properties specified")
        }
        for PropertyPath in PropertyPaths {
            if (IsObject(PropertyPath)) {
                throw TypeError("Expected a String",, Type(PropertyPath))
            }
            Props := StrSplit(PropertyPath, ".")
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
     * Asserts that the given symbol is present, otherwise deletes one
     * or more properties from the class.
     * 
     * @example
     * ; provide ".Eq(Other?)" if `AquaHotkey_Eq` is present, otherwise remove
     * this.Requires(AquaHotkey_Eq?, "Prototype.Eq")
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