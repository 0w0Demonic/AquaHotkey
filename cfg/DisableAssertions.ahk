/**
 * @config
 * 
 * Marker class that deactivates {@link AquaHotkey_Assertions assertions}
 * through the `.Assert()` method. This allows you to add validation to your
 * code while prototyping and debugging, and then remove these checks for
 * better performance after you've gained confidence that your code behaves
 * correctly. The global `Assert()` function still works as previously.
 * 
 * @module  <cfg/DisableAssertions>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link AquaHotkey_Assertions}
 * @example
 * #Include <AquaHotkey>
 * #Include <AquaHotkey\src\cfg\DisableAssertions>
 * 
 * ; immediately returns `Value` without performing any validation
 * Value.Assert(SomethingExpensive)
 */
class AquaHotkey_cfg_DisableAssertions {
}