#Include "%A_LineFile%/../../Classes/Any.ahk"
#Include "%A_LineFile%/../../Classes/Object.ahk"
#Include "%A_LineFile%/../../Classes/Number.ahk"
#Include "%A_LineFile%/../../Other/DllCallType.ahk"

/**
 * AquaHotkey - COM.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Other/COM.ahk
 * 
 * **Overview**:
 * 
 * The `COM` class is a user-friendly framework for COM objects which allows the
 * user to create complex wrapper classes, complete with `ComCall()`-methods and
 * event handling.
 * 
 * To define a COM subclass, extend the `COM` class and provide the necessary
 * static properties:
 * 
 * **Parameters**:
 * 
 * ---
 * 
 * - `(required) static CLSID => String`:
 * 
 *   CLSID or Prog ID of the COM object.
 * 
 * ---
 * 
 * - `(optional) static IID => String`:
 * 
 *   IID of the interface (default IID_IDispatch).
 * 
 * ---
 * 
 * - `(optional) static MethodSignatures => Object`:
 * 
 *   An object that contains type signatures for `ComCall()`-methods.
 * 
 * ---
 * 
 * - `(optional) static EventSink => Class`:
 * 
 *   A nested class that handles events thrown by the COM object.
 * 
 * Alternatively, a static property `static EventSink => Class` can point to an
 * event sink class somewhere else in the script.
 * 
 * Although not necessary, an event sink should be a subtype of `ComEventSink`.
 * Otherwise, the base class of the current event sink class will be changed.
 * 
 * Instead of the event sink, the `this`-keyword used in methods of the event
 * sink refer to the instance of `COM` that raised the event.
 * 
 * Due to this change, methods of the event sink no longer accept the original
 * COM object as last parameter.
 * 
 * ---
 * 
 * **Example**:
 * 
 * ```
 * class InternetExplorer extends COM {
 *     static CLSID => "InternetExplorer.Application"
 *     ; static IID => "..."
 * 
 *     __New(URL) {
 *         this.Visible := true
 *         this.Navigate(URL)
 *     }
 * 
 *     static MethodSignatures => {
 *         ; DoSomething(Arg1, Arg2) {
 *         ;     return ComCall(1, this, "Int", Arg1, "UInt", Arg2)
 *         ; }
 *         DoSomething: [1, "Int", "UInt"]
 *     }
 *     
 *     class EventSink extends ComEventSink
 *     {
 *         ; see AHK docs on `ComObjConnect()`:
 *         ; the last parameter `ieFinalParam` is omitted
 *         DocumentComplete(pDisp, &URL)
 *         {
 *             MsgBox("document completed: " . URL)
 *             
 *             ; `this` refers to the instance of `InternetExplorer`!
 *             ; in this example: [InternetExplorer].Quit()
 *             this.Quit()
 *         }
 *     }
 * 
 *     ie := InternetExplorer("https://www.autohotkey.com")
 *     ie.DoSomething(1, 4)
 *     ie(4, "Int", 23, "UInt", 0)
 * }
 * ```
 */
class COM {
    /**
     * The default IID used for COM objects (IID-IDispatch).
     * 
     * @return  {Integer}
     */
    static IID => "{00020400-0000-0000-C000-000000000046}"

    /**
     * Class initialization.
     * 
     * 1. Ensures a COM-class has both `CLSID` and `IID`.
     * 2. Sets up `ComCall()`-methods declared in `static MethodSignatures`.
     */
    static __New() {
        if (ObjGetBase(this) == Object) {
            return
        }
        
        (Object.Prototype.DeleteProp)(this.Prototype, "__Class")
        this.CLSID.AssertType(String)
        this.IID.AssertType(String)

        if (!ObjHasOwnProp(this, "MethodSignatures")) {
            return
        }

        Signatures := this.MethodSignatures
        if (Type(Signatures) != "Object") {
            Msg   := '"static MethodSignatures" must be an object literal'
            Extra := Type(Signatures)
            throw TypeError(Msg,, Extra)
        }

        for MethodName, Signature in ObjOwnProps(Signatures) {
            MethodName.AssertType(String)
            Signature.AssertType(Array)

            Index := Signature.RemoveAt(1).AssertInteger()
                              .AssertGreaterOrEqual(0)
            
            Mask := Array()
            for TypeArg in Signature {
                TypeArg.AssertType(String)
                if (!DllCallType.Exists(TypeArg)) {
                    throw ValueError("invalid data type",, TypeArg)
                }
                Mask.Push(TypeArg, unset)
            }
            if (Mask.Length) {
                Mask.Pop()
            }

            CreateComMethod(this, MethodName, Index, Mask*)
        }

        static CreateComMethod(Cls, MethodName, Index, Mask*) {
            Callback := ComCall.Bind(Index, unset, Mask*)
            try  {
                Name     := Cls.Prototype.__Class . ".Prototype." . MethodName
                Callback.DefineConstant("Name", Name)
            }
            Cls.Prototype.DefineMethod(MethodName, Callback)
        }
    }

    /**
     * Constructs a new `COM` object from the `static CLSID` and `static IID`
     * properties of this class.
     * @example
     * 
     * class InternetExplorer extends COM {
     *     static CLSID => "InternetExplorer.Application"
     *     ; ...
     * }
     * 
     * ie := InternetExplorer("https://www.autohotkey.com")
     * 
     * @param   {Any*}  Args  arguments passed to `__New()`
     * @return  {COM}
     */
    static Call(Args*) {
        return this.FromObj(ComObject(this.CLSID, this.IID), Args*)
    }

    /**
     * Queries the COM object for an interface or service.
     * 
     * @param   {String}   IID  the interface identifier to query
     * @param   {String?}  SID  the service identifier to query
     * @return  {ComValue}
     */
    __Query(Arg1, Arg2?) {
        return ComObjQuery(this._, Arg1, Arg?)
    }

    /**
     * Connects the COM object to an event sink.
     * 
     * @param   {String/Object}  EventSink  an event sink that handles events
     * @return  {this}
     */
    __Connect(EventSink) {
        ComObjConnect(this._, EventSink)
        return this
    }

    /**
     * Disconnects the COM object from its current event sink.
     * 
     * @return  {this}
     */
    __Disconnect() {
        ComObjConnect(this._)
        return this
    }

    /**
     * Constructs a new instance of `COM` by using a pointer to the COM object.
     * @example
     * 
     * ie  := ComObject("InternetExplorer.Application")
     * ptr := ComObjValue(ie)
     * 
     * ie  := InternetExplorer.FromPtr(ptr)
     * 
     * @param   {Integer}  Ptr   pointer to the COM object
     * @param   {Any*}     Args  arguments passed to `.New()`
     * @return  {COM}
     */
    static FromPtr(Ptr, Args*) => this.FromObj(ComObjFromPtr(Ptr), Args*)

    /**
     * Constructs a new instance of `COM` using a currently registered
     * COM object (using `ComObjActive()`).
     * @example
     * 
     * ie := InternetExplorer.FromActive()
     * 
     * @param   {Any*}  Args  arguments passed to the `.New()` constructor
     * @return  {COM}
     */
    static FromActive(Args*) => this.FromObj(ComObjActive(this.CLSID), Args*)

    /**
     * Constructs a new instance of `COM` with the given COM object to wrap
     * around.
     * @example
     * 
     * ie := ComObject("InternetExplorer.Application")
     * ie := InternetExplorer.FromObj(ie)
     * 
     * @param   {ComObject}  ComObj  the COM object to wrap around
     * @param   {Any*}       Args    arguments passed to `.New()`
     * @return  {COM}
     */
    static FromObj(ComObj, Args*) {
        Obj := Object()
        ObjSetBase(Obj, this.Prototype)
        Obj.DefineConstant("_", ComObj)
        if (HasProp(this, "EventSink") && this.EventSink) {
            if (!(HasBase(this.EventSink, ComEventSink))) {
                this.EventSink.DeleteProp("__New")
                ObjSetBase(this.EventSink, ComEventSink)
                ObjSetBase(this.EventSink.Prototype, ComEventSink.Prototype)
                (ComEventSink.__New)(this.EventSink)
            }
            EventSink := (this.EventSink)(Obj)
            ComObjConnect(Obj._, EventSink)
        }
        Obj.__New(Args*)
        return Obj
    }

    /**
     * Returns the pointer to the COM object.
     * 
     * @return  {Integer}
     */
    Ptr => ComObjValue(this)

    /**
     * Gets a property from the COM object.
     * 
     * @param   {String}  PropertyName  name of the property to get
     * @param   {Array}   Args          zero or more arguments
     * @return  {Any}
     */
    __Get(PropertyName, Args) {
        if (HasProp(this, "_")) {
            return this._.%PropertyName%[Args*]
        }
        throw UnsetError("no internal COM object")
    }

    /**
     * Gets a property of the COM object.
     * 
     * @param   {String}  PropertyName  name of the property to set
     * @param   {Array}   Args          zero or more arguments
     * @param   {Any}     Value         the new value of the property
     * @return  {Any}
     */
    __Set(PropertyName, Args, Value) {
        if (HasProp(this, "_")) {
            return this._.%PropertyName%[Args*] := Value
        }
        throw UnsetError("no internal COM object")
    }

    /**
     * Calls a method of the COM object.
     * 
     * @param   {String}  MethodName  name of the method to call
     * @param   {Array}   Args        zero or more arguments
     * @return  {Any}
     */
    __Call(MethodName, Args) {
        if (HasProp(this, "_")) {
            return this._.%MethodName%(Args*)
        }
        throw UnsetError("no internal COM object")
    }

    /**
     * Calls a native interface method of this COM object by index.
     * @example
     * 
     * ComObj(3, "Int", 0, "UInt", 1)
     * 
     * @param   {Integer}  Index  zero-based index of the method
     * @param   {Any*}     Args   zero or more arguments
     * @return  {Any}
     */
    Call(Index, Args*) => ComCall(Index, this._, Args*)

    /**
     * Returns the name of the COM object's default interface.
     * @return  {String}
     */
    __Name  => ComObjType(this._, "Name")

    /**
     * Returns the IID of the COM object.
     * @return  {String}
     */
    __IID   => ComObjType(this._, "IID")

    /**
     * Returns the object's class name. 
     * @return  {String}
     */
    __Class => ComObjType(this._, "Class")
}