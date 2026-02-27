#Include "%A_LineFile%\..\..\Base\Comparable.ahk"
#Include "%A_LineFile%\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\Base\Hash.ahk"

/**
 * Represents a file path or URL.
 * 
 * @module  <FileUtils/Path>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Path {
    ;@region Construction

    /**
     * Constructs a new path.
     * 
     * @constructor
     * @param   {String}  Str  file path or URL
     */
    static Call(Path) {
        if (!(Path is String)) {
            throw TypeError("Expected a String",, Type(Path))
        }
        
        Result := Object()
        ObjSetBase(Result, this.Prototype)
        Result.DefineProp("Value", { Get: (_) => Path })
        return Result
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Properties

    /**
     * The file name without its path.
     * 
     * @readonly
     * @property {String}
     */
    Name {
      get {
        SplitPath(this.Value, &Name)
        return Name
      }
    }

    /**
     * The directory of the file.
     * 
     * @readonly
     * @property {String}
     */
    Dir {
      get {
        SplitPath(this.Value,, &Dir)
        return Dir
      }
    }

    /**
     * The file extension.
     * 
     * @readonly
     * @property {String}
     */
    Ext {
      get {
        SplitPath(this.Value,,, &Ext)
        return Ext
      }
    }

    /**
     * The file name without its path, dot and extension.
     * 
     * @readonly
     * @property {String}
     */
    NameNoExt {
      get {
        SplitPath(this.Value,,,, &NameNoExt)
        return NameNoExt
      }
    }

    /**
     * The drive or server name of the file.
     * 
     * @readonly
     * @property {String}
     */
    Drive {
      get {
        SplitPath(this.Value,,,,, &Drive)
        return Drive
      }
    }

    /**
     * Returns the parent of this path.
     * 
     * @returns {Path}
     */
    Parent() => Path(this.Dir)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Compares this path with another.
     * 
     * @param   {Path}  Other  other path
     * @returns {Integer}
     * @example
     */
    Compare(Other) {
        if (!(Other is Path)) {
            throw TypeError("Expected a Path",, Type(Other))
        }
        return (this.Value).Compare(Other.Value)
    }

    /**
     * Determines whether this path is equal to the `Other` value.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     * @see {@link AquaHotkey_Eq `.Eq()`}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        return (Other is Path) && (this.Value).Eq(Other.Value)
    }

    /**
     * Returns a hash code for this path.
     * 
     * @returns {Integer}
     * @see {@link AquaHotkey_Hash `.HashCode()`}
     */
    HashCode() => (this.Value).HashCode()

    /**
     * Returns the string representation of this path.
     * 
     * @returns {String}
     * @see {@link AquaHotkey_ToString `.ToString()`}
     */
    ToString() => (this.Value)

    ;@endregion
}
