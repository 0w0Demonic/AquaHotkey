#Include "%A_LineFile%\..\AquaHotkey.ahk"

/**
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
 * @module  <Core/AquaHotkey_Mixin>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Mixin extends AquaHotkey
{
    static __New() {
        if (this == AquaHotkey_Mixin) {
            super.__New()
        }
    }

    class Class {
        ; TODO use a Collections/Set?
        ; TODO find out how to implement `Implements` on any object
        /**
         * The mixin classes implemented by this class.
         * 
         * @abstract
         * @type {Map}
         */
        Mixins => Map()
        
        /**
         * Determines whether the class implements the given mixin class.
         * 
         * @param   {Class}  Mixin  the given mixin class
         * @returns {Boolean}
         * @example
         * Array.Implements(Enumerable1) ; true
         * 
         * Arr := Array(1, 2, 3)
         * Arr.Implements(Enumerable1) ; true
         */
        Implements(Mixin) {
            if (!(Mixin is Class)) {
                throw TypeError("Expected a Class",, Type(Mixin))
            }
            Cls := this
            loop {
                if (this.Mixins.Has(Mixin)) {
                    return true
                }
                for Mixin in this.Mixins {
                    if (Mixin.Implements(Mixin)) {
                        return true
                    }
                }
                Cls := ObjGetBase(Cls)
                if (!Cls) {
                    return false
                }
            }
        }

        /**
         * Includes one or more mixin classes onto this class.
         * 
         * @param   {Class}   Mixin   mixin class to apply
         * @param   {Class*}  Mixins  more mixin classes to apply
         * @returns {this}
         * @example
         * class Enumerable1 {
         *   ForEach(Action, Args*) {
         *     for Value in this {
         *       Action(Value?, Args*)
         *     }
         *   }
         * }
         * Array.Include(Enumerable1)
         */
        Include(Mixin, Mixins*) {
            if (!(Mixin is Class)) {
                throw TypeError("Expected a Class",, Type(this))
            }
            for M in Mixins {
                if (!(M is Class)) {
                    throw TypeError("Expected a Class",, Type(this))
                }
            }

            if (this.Mixins.Count != 0) {
                ObjGetBase(this).Backup(Mixin, Mixins*)
            } else {
                BaseClass := AquaHotkey
                        .CreateClass(ObjGetBase(this))
                        .Backup(Mixin, Mixins*)
                ObjSetBase(this,           BaseClass)
                ObjSetBase(this.Prototype, BaseClass.Prototype)
            }

            Mixins := this.Mixins
            Mixins.Set(Mixin, true)
            for M in Mixins {
                Mixins.Set(M, true)
            }
            ({}.DefineProp)(this, "Mixins", { Get: (_) => Mixins.Clone() })
            return this
        }

        /**
         * Applies this mixin class onto one or more classes.
         * 
         * @param   {Class*}  Classes  classes on which to apply the mixin
         * @returns {this}
         */
        Extend(Cls, Classes*) {
            Cls.Include(this)
            for C in Classes {
                C.Include(this)
            }
            return this
        }
    }
} ; class AquaHotkey_Mixin extends AquaHotkey
