#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Adds universal properties for type information, such as the type and class
 * of a value.
 * 
 * @module  <Base/Any>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_TypeInfo extends AquaHotkey {
    class Any {
        /**
         * Returns the type of this value via `Type()`.
         * 
         * @returns {String}
         * @example
         * "foo".Type ; "String"
         */
        Type => Type(this)

        /**
         * Returns the type of this value as a class object.
         * 
         * @readonly
         * @returns {String}
         * @example
         * "foo".Class ; String (class)
         */
        Class => Class.ForName(
                        (IsObject(this) && ObjHasOwnProp(this, "__Class"))
                                ? this.__Class
                                : Type(this))

        /**
         * Returns the chain of bases of this value, including the value itself.
         * 
         * @returns {Array}
         * @example
         * ; ["foo", String.Prototype, Primitive.Prototype, Any.Prototype]
         * "foo".Hierarchy
         */
        Hierarchy {
            get {
                Val := this
                Result := Array()

                loop {
                    Result.Push(Val)
                    Val := ObjGetBase(Val)
                } until (Val == Any.Prototype)
                return Result
            }
        }

        /**
         * Returns the chain of bases of this value.
         * 
         * @readonly
         * @returns {Array}
         * @example
         * ; [String.Prototype, Primitive.Prototype, Any.Prototype]
         * "foo".Bases
         */
        Bases {
            get {
                Val := ObjGetBase(this)
                Result := Array()

                loop {
                    Result.Push(Val)
                    Val := ObjGetBase(Val)
                } until (Val == Any.Prototype)
                return Result
            }
        }
    }

    class Class {
        /**
         * Returns a class by the given property path.
         * 
         * @param   {String}  ClassName  name of a class
         * @returns {Class}
         * @throws  {UnsetError} when unable to find class
         * @example
         * Cls := Class.ForName("Gui.ActiveX") ; Gui.ActiveX (class)
         */
        static ForName(ClassName) {
            if (IsObject(ClassName)) {
                throw TypeError("Expected a String",, Type(ClassName))
            }
            ClassObj := false
            loop parse ClassName, "." {
                ClassObj := (ClassObj)
                        ? ClassObj.%A_LoopField%
                        : (AquaHotkey.Deref)(A_LoopField)
                
                if (!(ClassObj is Class)) {
                    throw TypeError("Expected a Class for " . A_LoopField,,
                                    Type(ClassObj))
                }
            }
            return ClassObj
        }

        /**
         * Returns the name of the class.
         * 
         * @returns {String}
         * @example
         * MsgBox(String.Name) ; "String"
         */
        Name => this.Prototype.__Class
    }
}