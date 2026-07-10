/**
 * @config
 * 
 * Marker class that deactivates {@link AquaHotkey_DuckTypes duck type}
 * assertions (`.AssertType()`). This allows you to have thorough type
 * checking while debugging and prototyping your code, yet almost no
 * performance overhead after you've gained confidence that your code behaves
 * correctly.
 * 
 * @module  <cfg/DisableTypeAssertions>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link AquaHotkey_Assertions}
 * @example
 * #Include <AquaHotkey>
 * #Include <AquaHotkey\src\Base\DuckTypes>
 * #Include <AquaHotkey\src\cfg\DisableTypeAssertions>
 * 
 * ; immediately returns `Value` without type checking
 * Value.AssertType(SomethingComplicated)
 */
class AquaHotkey_cfg_DisableTypeAssertions extends Any {
}
