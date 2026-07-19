; TODO cast descs to Property.Prototype, add instance methods
; TODO remove this again

/**
 * Provides a wide range of property descriptors for constructing AutoHotkey
 * objects.
 * 
 * @module  <Base/Property>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Property extends Any {
    /**
     * Creates a property descriptor that resembles a field whose value is
     * type-checked ({@link AquaHotkey_DuckTypes `.Is()`}).
     * 
     * @param   {Any}   T             type pattern
     * @param   {Any?}  InitialValue  initial value
     * @returns {Object}
     * @example
     * Obj := Object()
     * Obj.DefineProp("Value", CheckedField(Integer, 42))
     * MsgBox(Obj.Value) ; 42
     * Obj.Value := Buffer(16, 0) ; Error!
     */
    static CheckedField(T, Value?) {
        return { Get: (this) => Value, Set: Setter }

        Setter(this, NewValue?) {
            if (!T.IsInstance(NewValue?)) {
                throw TypeError("type mismatch", -2)
            }
            Value := (NewValue?)
        }
    }

    /**
     * Defines a new property that resembles a regular field.
     * 
     * @param   {Any}  Value  value of the field
     * @returns {Object}
     * @example
     * Obj := Object()
     * Obj.DefineProp("Name", Property.Field(42))
     * 
     * ; same as:
     * Obj.Name := 42
     */
    static Field(Value) => { Value: Value }

    /**
     * Defines a new method by the name of `PropertyName`.
     * 
     * @param   {Func}  Fn  the function to be called
     * @returns {Object}
     * @example
     * Obj := { Value: 42 }
     * Obj.Define("Increment", Property.Method(this => ++this.Value))
     * Obj.Increment() ; 43
     */
    static Method(Fn) {
        GetMethod(Fn)
        return { Call: Fn }
    }

    /**
     * Defines a new read-only property.
     * 
     * @param   {Func}  Fn  the function to be called.
     * @returns {Object}
     * @example
     * Obj := { Value: 3 }
     * Obj.DefineProp("TwoTimesValue", Property.Getter(this => 2 * this.Value))
     * MsgBox(Obj.TwoTimesValue) ; 6
     */
    static Getter(Fn) {
        GetMethod(Fn)
        return { Get: Fn }
    }

    /**
     * Defines a new write-only property.
     * 
     * @param   {Func}  Fn  the function to be called
     * @returns {Object}
     */
    static Setter(Fn) {
        GetMethod(Fn)
        return { Set: Fn }
    }

    /**
     * Defines a new property with the specified `Getter` and `Setter`.
     * 
     * @param   {Func}  Get  getter function
     * @param   {Func}  Set  setter function
     * @returns {Object}
     */
    static GetterSetter(Get, Set) {
        GetMethod(Get)
        GetMethod(Set)
        return { Get: Get, Set: Set }
    }

    /**
     * Defines a new read-only property which returns a constant `Value`.
     * 
     * @param   {Any}  Value  value returned by this property
     * @returns {Object}
     * @example
     * class Foo {
     *     ; property "Bar" becomes immutable
     *     __New(Bar) => this.DefineProp("Bar", Property.Constant(Bar))
     * }
     */
    static Constant(Value) => { Get: (_) => Value }

    /**
     * Defines a new read-only property which returns the value referenced by
     * the given VarRef. This is especially useful with the introduction to
     * `PropRef` in v2.1-alpha.10.
     * 
     * @param   {VarRef}  Value  reference to the value
     * @returns {Object}
     * @example <caption>Using VarRef</caption>
     * Obj := Object()
     * Value := 42
     * Obj.DefineProp("Value", ConstantRef(&Value))
     * MsgBox(Obj.Value) ; 42
     * 
     * @example <caption>Using PropRef</caption>
     * OtherObj := { Value: 42 }
     * Obj := Object()
     * Obj.DefineProp("Value", ConstantRef(&OtherObj.Value))
     * 
     * MsgBox(Obj.Value) ; 42
     */
    static ConstantRef(&Value) => { Get: (_) => Value }

    /**
     * Defines a new property that resembles a struct field in AHK alpha.
     * 
     * @param   {Any}       T     the type of struct field
     * @param   {Integer?}  Pack  alignment of the property, if applicable
     * @returns {Object}
     * @example
     * Obj.DefineProp("Value", StructField("u32"))
     */
    static StructField(T, Pack?) => { Type: T, Pack: (Pack?) }

    /**
     * Defines an observable property which calls the specified callback
     * whenever its value changes.
     * 
     * `Callback` is called with the new value as first parameter.
     * 
     * @param   {Func}  Callback  the function to be called
     * @param   {Any?}  Value     initial value
     * @returns {Object}
     */
    static Reactive(Callback, Value?) {
        GetMethod(Callback)
        return { Get: (this) => Value, Set: Setter }

        Setter(this, NewValue?) {
            Callback(NewValue?)
            Value := (NewValue?)
        }
    }
}
