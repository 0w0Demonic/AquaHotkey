#Include "%A_LineFile%\..\AquaHotkey.ahk"

/**
 * @description
 * Provides mixin-style composition similar to Ruby's `include` and `extend`.
 * 
 * Mixins work by "injecting a class" between the class and its base class.
 * 
 * @example
 * ; class Object
 * ; `- class (unnamed) extends Object
 * ;    |- Foo()
 * ;    |- Bar()
 * ;    `- class C extends (unnamed)
 * class A { Foo() => "foo" }
 * class B { Bar() => "bar" }
 * class C { static __New() => this.Include(A, B) }
 * 
 * @see https://www.github.com/0w0Demonic/AquaHotkey
 * @author 0w0Demonic
 */
class AquaHotkey_Mixin extends AquaHotkey {
class Class {
    /**
     * Adds the properties of one or more classes as mixin onto the
     * specified class.
     * 
     * @param   {Class}   Cls      a class to be contained in the mixin
     * @param   {Class*}  Classes  zero or more classes
     */
    Include(Cls, Classes*) {
        if (!(Cls is Class)) {
            throw ValueError("Expected a Class",, Type(Cls))
        }
        for C in Classes {
            if (!(C is Class)) {
                throw TypeError("Expected a Class",, Type(C))
            }
        }

        Mixin := AquaHotkey
            .CreateClass(ObjGetBase(this))
            .Backup(Cls, Classes*)
        
        ObjSetBase(this,           Mixin)
        ObjSetBase(this.Prototype, Mixin.Prototype)
        return this
    }

    /**
     * Applies this mixin class onto one or more classes.
     * 
     * @param   {Class*}  Classes  classes on which to apply the mixin
     * @returns {this}
     */
    Extend(Cls, Classes*) {
        if (!(Cls is Class)) {
            throw TypeError("Expected a Class",, Type(Cls))
        }
        Cls.Include(this)
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