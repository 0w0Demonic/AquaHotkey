/**
 * Sanity checks so I can sleep at night.
 */
class AquaHotkey_SanityChecks extends Any {
    static __New() {
        for Cls in Array(Any, Primitive, Number, Integer, Float, String) {
            if (HasMethod(Cls.Prototype)) {
                throw ValueError("Primitive values can never be callable")
            }
        }
    }
}