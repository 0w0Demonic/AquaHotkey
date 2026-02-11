/**
 * @config
 * 
 * A marker class that disables the type checking done by generic collection
 * types like {@link GenericArray} and {@link GenericMap}.
 * 
 * This can improve performance significantly. You can choose to use
 * type-checked generic collections to catch type errors early during
 * development, and then switch off type-checks after asserting that your
 * code is working correctly.
 * 
 * @module  <cfg/DisableGenerics>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * #Include <AquaHotkeyX>
 * #Include <AquaHotkey/cfg/DisableGenerics>
 * 
 * ; same code as before, but without type checks. The resulting type ends
 * ; up being just plain old `Array`.
 * Grid := Integer[][](
 *     Integer[](1, 2, 3),
 *     Integer[](4, 5, 6)
 * )
 * 
 * ; --> class LinkedList
 * L := LinkedList.OfType(Numeric)
 */
class AquaHotkey_cfg_DisableGenerics {
}