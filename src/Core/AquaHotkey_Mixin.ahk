#Include "%A_LineFile%\..\AquaHotkey.ahk"

/**
 * AquaHotkey - AquaHotkey_Mixin.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Core/AquaHotkey_Mixin.ahk
 * 
 * @description
 * Provides mixin-style composition similar to Ruby's `include` and `extend`.
 */
class AquaHotkey_Mixin extends AquaHotkey {
class Class {
    /**
     * Includes one or more mixin classes into the current class.
     * 
     * Each property defined in the mixin class will be attached to the
     * prototype of the target class.
     * 
     * @param   {Class*}  Mixins  one or more mixins to apply
     * @returns {this}
     * @example
     * Primitive.Include(HasStringRepr)
     * "Hello, world".Display()
     * 
     * class HasStringRepr {
     *     Display() => MsgBox(String(this))
     * }
     */
    Include(Mixins*) {
        if (!Mixins.Length) {
            throw ValueError("No mixins specified")
        }
        for M in Mixins {
            BaseClass := ObjGetBase(this)
            BaseProto := ObjGetBase(this.Prototype)

            MixinProto := M.Prototype

            ObjSetBase(MixinProto, BaseProto)
            ObjSetBase(M, BaseClass)

            ObjSetBase(this, M)
            ObjSetBase(this.Prototype, M.Prototype)
        }
        return this
    }

    /**
     * Extends one or more classes with the current class used as mixin.
     * 
     * @param   {Class*}  Classes  one or more classes to apply the mixin on
     * @returns {this}
     * @example
     * Enumerable1.Extend(Array)
     * Array(1, 2, 3).ForEach(MsgBox)
     * 
     * class Enumerable1 {
     *     ForEach(Action) {
     *         for Value in this {
     *             Action(this)
     *         }
     *         return this
     *     }
     * }
     */
    Extend(Classes*) {
        if (!Classes.Length) {
            throw ValueError("No classes specified")
        }
        for C in Classes {
            if (!(C is Class)) {
                throw TypeError("Expected a Class",, Type(C))
            }
            C.Include(this)
        }
        return this
    }
} ; class Class
} ; class AquaHotkey_Mixin extends AquaHotkey