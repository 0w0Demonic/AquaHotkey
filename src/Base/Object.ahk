#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Object utilities.
 * 
 * @module  <Base/Object>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Object extends AquaHotkey {
class Object {
    ;@region General
    /**
     * Creates a `BoundFunc` which calls a method `MethodName` bound to this
     * particular instance, followed by zero or more arguments `Args*`.
     * 
     * @example
     * Arr       := Array()
     * PushToArr := Arr.BindMethod("Push")
     * PushToArr("Hello, world!")
     * 
     * @param   {String}  MethodName  the name of a method
     * @param   {Any*}    Args        zero or more additional arguments
     * @returns {BoundFunc}
     */
    BindMethod(MethodName, Args*) => ObjBindMethod(this, MethodName, Args*)

    /**
     * Sets the base of this object.
     * 
     * @example
     * class Foo {
     * 
     * }
     * 
     * Obj := Object().SetBase(Foo.Prototype)
     * MsgBox(Obj is Foo) ; true
     * 
     * @param   {Any}  BaseObj  the new base of this object
     * @returns {this}
     */
    SetBase(BaseObj) {
        ObjSetBase(this, BaseObj)
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region DefineProp

    /**
     * Defines a new read-only property by the name of `PropertyName` for this
     * object, which returns a constant `Value`.
     * 
     * @example
     * class Foo {
     *     ; property "Bar" becomes immutable
     *     __New(Bar) => this.DefineConstant("Bar", Bar)
     * }
     * 
     * @param   {String}  PropertyName  name of the new property
     * @param   {Any}     Value         value that is returned by this property
     * @returns {this}
     */
    DefineConstant(PropertyName, Value) {
        return this.DefineProp(PropertyName, { Get: (_) => Value })
    }

    /**
     * Defines a new read-only property by the name of `PropertyName`.
     * 
     * @example
     * TwoTimesValue(this) {
     *     return this.Value * 2
     * }
     * 
     * Obj := { Value: 3 }
     * Obj.DefineGetter("TwoTimesValue", TwoTimesValue)
     * 
     * MsgBox(Obj.TwoTimesValue) ; 6
     * 
     * @param   {String}  PropertyName  name of the property
     * @param   {Func}    Getter        the function to be called
     * @returns {this}
     */
    DefineGetter(PropertyName, Getter) {
        GetMethod(Getter)
        return this.DefineProp(PropertyName, { Get: Getter })
    }

    /**
     * Defines a new property by the name of `PropertyName` with `Getter` and
     * `Setter` methods.
     * 
     * @example
     * Getter(this) {
     *     ++this.Count
     *     return this.Value
     * }
     * 
     * Setter(this, Value) {
     *     ++this.Count
     *     return this.Value := Value
     * }
     * 
     * Obj := ({ Count: 0 }).DefineGetterSetter("Foo", Getter, Setter)
     * 
     * Obj.Foo := 3
     * MsgBox(Obj.Foo)   ; 3
     * MsgBox(Obj.Count) ; 2
     * 
     * @param   {String}  PropertyName  name of the new property
     * @param   {Func}    Getter        getter function
     * @param   {Func}    Setter        setter function
     * @returns {this}
     */
    DefineGetterSetter(PropertyName, Getter, Setter) {
        (GetMethod(Getter) && GetMethod(Setter))
        return this.DefineProp(PropertyName, { Get: Getter, Set: Setter })
    }

    /**
     * Defines a new property by the name of `PropertyName` with the given
     * `Setter` function.
     * 
     * @example
     * Setter(this, Value) {
     *     return this.Value := Value.Assert(IsInteger)
     * }
     * 
     * Obj     := ({ Value: 42 }).DefineSetter("Foo", Setter)
     * Obj.Foo := 2
     * Obj.Foo := "bar" ; Error!
     * 
     * @param   {String}  PropertyName  name of the new property
     * @param   {Func}    Setter        setter function
     * @returns {this}
     */
    DefineSetter(PropertyName, Setter) {
        GetMethod(Setter)
        return this.DefineProp(PropertyName, { Set: Setter })
    }
    
    /**
     * Defines a new method by the name of `PropertyName`.
     * 
     * @example
     * PrintValue(this) => MsgBox(this.Value)
     * 
     * Obj := ({ Value: 42 }).DefineMethod("PrintValue", PrintValue)
     * Obj.PrintValue()
     * 
     * @param   {String}  PropertyName  name of property
     * @param   {Func}    Method        the function to be called
     * @returns {this}
     */
    DefineMethod(PropertyName, Method) {
        GetMethod(Method)
        return this.DefineProp(PropertyName, { Call: Method })
    }
    ;@endregion
} ; class Object
} ; class AquaHotkey_Object extends AquaHotkey