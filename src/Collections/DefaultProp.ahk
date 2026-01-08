#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Provides a convenient way to define `Default` properties for arrays and maps.
 * 
 * @module  <Collections/DefaultProp>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * M := Map.WithDefault((MapObj, Key) => Array())
 * 
 * ; Map { "foo": ["bar"] }
 * M["foo"].Push("bar")
 */
class AquaHotkey_DefaultProp {
    static __New() {
        if (this == AquaHotkey_DefaultProp) {
            this.ApplyOnto(Array, Map)
        }
    }
    
    /**
     * Creates a map with a custom `Default` method called whenever an
     * absent key is retrieved.
     * 
     * ```ahk
     * Callback(MapObj, Key) => Any
     * ```
     * 
     * @param   {Func}  Callback  the function to call
     * @returns {Map}
     * @example
     * M := Map.WithDefault((MapObj) => "")
     */
    static WithDefault(Callback) {
        GetMethod(Callback)
        Result := this()
        ({}.DefineProp)(Result, "Default", { Get: Callback })
        return Result
    }
}