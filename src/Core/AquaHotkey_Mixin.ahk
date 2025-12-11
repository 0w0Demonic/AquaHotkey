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
class AquaHotkey_Mixin extends AquaHotkey
{
    static __New() {
        ; TODO put this logic into the other AquaHotkey core classes

        static Cache  := Map()
        static Define := ({}.DefineProp)

        if (this != AquaHotkey_Mixin) {
            return
        }
        super.__New()

        Define(Class.Prototype, "Implements", { Call: Implements })
        Define(Any.Prototype,   "Implements", { Call: Implements })
        Define(Class.Prototype, "Include",    { Call: Include    })

        static Implements(Obj, Mixin) {
            if (!(Mixin is Class)) {
                throw TypeError("Expected a Class",, Type(Obj))
            }
            Loop {
                if (Cache.Has(Obj) && Cache.Get(Obj).Has(Mixin)) {
                    return true
                }
                Obj := ObjGetBase(Obj)
                if (!Obj) {
                    return false
                }
            }
        }

        ; TODO recursion

        static Include(Cls, Mixin, Mixins*) {
            if (!(Mixin is Class)) {
                throw TypeError("Expected a Class",, Type(Cls))
            }
            for M in Mixins {
                if (!(M is Class)) {
                    throw TypeError("Expected a Class",, Type(Cls))
                }
            }

            if (Cache.Has(Cls)) {
                ObjGetBase(Cls).Backup(Mixin, Mixins*)
            } else {
                BaseClass := AquaHotkey
                    .CreateClass(ObjGetBase(Cls))
                    .Backup(Mixin, Mixins*)
                    
                ObjSetBase(Cls,           BaseClass)
                ObjSetBase(Cls.Prototype, BaseClass.Prototype)
            }

            if (!Cache.Has(Cls)) {
                Cache.Set(Cls, Map())
            }
            Classes := Cache.Get(Cls)
            Classes.Set(Mixin, true)
            Classes.Set(Mixin.Prototype, true)
            for M in Mixins {
                Classes.Set(M, true)
                Classes.Set(M.Prototype, true)
            }
            
            return Cls
        }
    }

    class Class {
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
