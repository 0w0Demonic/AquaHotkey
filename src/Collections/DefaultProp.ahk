#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Provides a convenient way to define `Default` properties for arrays and maps.
 * 
 * @module  <Collections/DefaultProp>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * M := Map.WithFactory((MapObj, Key) => Array())
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
     * M := Map.WithDefault((MapObj, Key) => "")
     */
    static WithDefault(Callback) {
        GetMethod(Callback)
        Result := this()
        ({}.DefineProp)(Result, "Default", { Call: Callback })
        return Result
    }

    /**
     * Creates a map which initializes a new value, if an absent key is
     * retrieved.
     * 
     * ```ahk
     * Factory(MapObj, Key) => Any
     * ```
     * 
     * @param   {Func}  Factory  function that produces new value
     * @returns {Map}
     * @example
     * M := Map.WithFactory((MapObj, Key) => Array())
     * 
     * ; Map { "foo": ["bar"] }
     * M["foo"].Push("bar")
     */
    static WithFactory(Factory) {
        GetMethod(Factory)
        return this.WithDefault(Default)

        Default(MapObj, Key) {
            Value := Factory(MapObj, Key)
            MapObj.Set(Key, Value)
            return Value
        }
    }
}