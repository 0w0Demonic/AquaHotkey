/**
 * AquaHotkey - COM.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/COM.ahk
 * 
 * ---
 * 
 * **Overview**:
 * 
 * `COM` is a user-friendly framework that wraps COM objects neatly
 * into clean and class-based interfaces.
 * 
 * **How to Use**:
 * 
 * Create a subtype of `COM`, and define one of the following members:
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
 *   Class that handles events thrown by the COM object. Events contained
 *   in the event sink are modified in such a way that *the `this`-keyword
 *   refers to the original COM object*.
 * 
 * ---
 * 
 * **Notes**:
 * 
 * - To assign new fields, you must use `.DefineProp(..., { Value: ...})`.
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
 *     class EventSink extends COM.EventSink
 *     {
 *         DocumentComplete(pDisp, &URL)
 *         {
 *             MsgBox("document completed: " . URL)
 *             ; [InternetExplorer].Quit()
 *             this.Quit()
 *         }
 *     }
 * 
 *     ie := InternetExplorer("https://www.autohotkey.com")
 *     ie.DoSomething(1, 4)
 *     ie(4, "Int", 23, "UInt", 0)
 * }
 * ```
 * 
 * @example
 * class InternetExplorer extends COM {
 *     ; [...]
 * 
 *     ; alternatively, just define them here - much easier.
 *     IsBoring := false
 * }
 * 
 * Obj := InternetExplorer()
 * Obj.DefineProp("IsBoring", { Value: false })
 */
class COM {
    /** (optional) The default IID used for COM objects (IID-IDispatch). */
    static IID => "{00020400-0000-0000-C000-000000000046}"

    /** (required) CLSID to wrap around. This property must be overwritten. */
    static CLSID => false

    /** (optional) Method signatures to `ComCall()` methods. */
    static MethodSignatures => false

    /**
     * Class initialization.
     * 
     * 1. Ensures a COM-class has both `CLSID` and `IID`.
     * 2. Sets up `ComCall()`-methods declared in `static MethodSignatures`.
     */
    static __New() {
        if (this == COM) {
            return
        }
        (Object.Prototype.DeleteProp)(this.Prototype, "__Class")

        if (!this.CLSID) {
            throw ValueError('Missing "static CLSID" property.',,
                             this.Prototype.__Class)
        }
        if (IsObject(this.CLSID)) {
            throw TypeError("Expected CLSID to be a String",, Type(this.CLSID))
        }
        if (IsObject(this.IID)) {
            throw TypeError("Expected IID to be a String",, Type(this.IID))
        }
        if (ObjHasOwnProp(this, "EventSink") && !(this.EventSink is Class)) {
            throw TypeError("Event sink must be a Class object.")
        }
        if (!this.MethodSignatures) {
            return
        }

        Signatures := this.MethodSignatures
        if (!(ObjGetBase(Signatures)) is Object) {
            Msg   := '"static MethodSignatures" must be an object literal'
            Extra := Type(Signatures)
            throw TypeError(Msg,, Extra)
        }

        for MethodName, Signature in ObjOwnProps(Signatures) {
            if (IsObject(MethodName)) {
                throw TypeError("Expected a String",, Type(MethodName))
            }
            if (!(Signature is Array)) {
                throw TypeError("Expected an Array",, Type(Signature))
            }

            Index := Signature.RemoveAt(1)
            if (!IsInteger(Index)) {
                throw TypeError("Expected an Integer",, Type(Index))
            }
            if (Index < 0) {
                throw ValueError("Index < 0",, Index)
            }
            
            Mask := Array()
            for TypeArg in Signature {
                if (IsObject(TypeArg)) {
                    throw TypeError("Expected a String",, Type(TypeArg))
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
                Name := Cls.Prototype.__Class . ".Prototype." . MethodName
                Callback.DefineProp("Name", {
                    Get: (Instance) => Name
                })
            }
            Cls.Prototype.DefineProp(MethodName, { Call: Callback })
        }
    }

    /**
     * Constructs a new `COM` object from the `static CLSID` and `static IID`
     * properties of the class.
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
     * If you provide your own event sink class, it **should** inherit from
     * `COM.EventSink`. Otherwise, it'll be automatically forced to do so.
     * 
     * @param   {Class}  EventSink  event sink that handles events
     * @return  {this}
     */
    __Connect(EventSink) {
        if (EventSink is Class) {
            throw TypeError("Expected a Class object",, Type(EventSink))
        }
        if (!HasBase(EventSink, COM.EventSink))
        {
            (Object.Prototype.DeleteProp)(EventSink, "__New")
            ObjSetBase(EventSink,           COM.EventSink)
            ObjSetBase(EventSink.Prototype, COM.EventSink.Prototype)

            ; call `static __New()`, which sets up its smart event handling.
            (COM.EventSink.__New)(EventSink)
        }
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
     * 
     * @example
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
     * 
     * @example
     * ie := InternetExplorer.FromActive()
     * 
     * @param   {Any*}  Args  arguments passed to the `.New()` constructor
     * @return  {COM}
     */
    static FromActive(Args*) => this.FromObj(ComObjActive(this.CLSID), Args*)

    /**
     * Constructs a new instance of `COM` with the given COM object to wrap
     * around.
     * 
     * ---
     * 
     * **Custom Event Sinks Must Extend `COM.EventSink`**
     * 
     * Under the hood, `COM` uses a specialized helper class `COM.EventSink` to
     * intercept and rewrite COM events.
     * 
     * If you provide your own event sink class, it **should** inherit from
     * `COM.EventSink`. Otherwise, it'll be automatically forced to do so.
     * 
     * ---
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
        ; create a new `COM` object
        Obj := Object()
        ObjSetBase(Obj, this.Prototype)

        ; define internal `ComObject` to wrap around
        Obj.DefineProp("_", { Get: (Instance) => ComObj })

        if (!ObjHasOwnProp(this, "EventSink") || !this.EventSink) {
            Obj.__New(Args*)
            return Obj
        }

        ; event sink must be a class object.
        if (!(this.EventSink is Class)) {
            throw TypeError("Expected a Class object",, Type(this.EventSink))
        }

        ; if the event sink doesn't derive from `COM.EventSink`, we force it to.
        if (!HasBase(this.EventSink, COM.EventSink))
        {
            ; ensure that `COM.EventSink.Prototype.__New` is called.
            this.EventSink.DeleteProp("__New")

            ObjSetBase(this.EventSink,           COM.EventSink)
            ObjSetBase(this.EventSink.Prototype, COM.EventSink.Prototype)

            ; call `static __New()`, which sets up its smart event handling.
            (COM.EventSink.__New)(this.EventSink)
        }

        EventSink := (this.EventSink)(Obj)
        ComObjConnect(Obj._, EventSink)

        ; construct and return the new object
        if (HasProp(Obj, "__Init") && HasMethod(Obj.__Init)) {
            Obj.__Init()
        }
        if (HasProp(Obj, "__New") && HasMethod(Obj.__New)) {
            Obj.__New(Args*)
        }
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
     * Sets a property of the COM object.
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
     * 
     * @example
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


    /**
     * `COM.EventSink` is a class that handles events thrown by the `COM`
     * object.
     * 
     * **COM Event Binding Made Clean**:
     * 
     * - Events are handled in such a way that the `this`-keyword inside of
     *   methods refers to the **calling instance of `COM`, not the event sink
     *   itself.**
     * 
     * - This change makes event handling feel a lot more natural and
     *   object-oriented.
     * 
     * - Because the last argument always refers to the `ComObject` and we
     *   already refer to its wrapper by `this`, it is omitted.
     * 
     * **Display Events**:
     * 
     * If a non-static property `ShowEvents` is set to true, the event sink
     * displays a feed of all undefined events raised by the COM object in
     * the form of a tool tip.
     */
    class EventSink {
        /**
         * Class initialization. This methods sets up special method handling
         * which involves using the original event source (the COM class
         * instance) as `this`.
         */
        static __New() {
            if (this == COM.EventSink) {
                return
            }

            Proto := this.Prototype
            for PropertyName in ObjOwnProps(Proto) {
                try {
                    PropDesc := Proto.GetOwnPropDesc(PropertyName)
                    ; an overridden version of `.DefineProp()` is used here.
                    Proto.DefineProp(PropertyName, PropDesc)
                }
            }
        }

        /**
         * Defines or modifies an own property.
         * 
         * @param   {String}  PropertyName  the name of the property
         * @param   {Object}  PropDesc      property descriptor
         */
        DefineProp(PropertyName, PropDesc) {
            if (ObjHasOwnProp(PropDesc, "Call")) {
                Callback := PropDesc.Call
                PropDesc.Call := EventHandler
            }
            (Object.Prototype.DefineProp)(this, PropertyName, PropDesc)

            /**
             * Wraps the original callback to remove the final `ComObject`
             * argument and rebind `this` to the `COM` wrapper.
             */
            EventHandler(Instance, Args*) {
                Args.Pop()
                return Callback(Instance.Source, Args*)
            }
        }

        /**
         * Constructs a new `COM.EventSink` from the given `COM` source.
         * 
         * @param   {COM}  Source  COM instance that throws events
         * @return  {COM.EventSink}
         */
        __New(Source) {
            this.DefineProp("Source", { Get: (Instance) => Source })
        }

        /**
         * Determines if `__Call()` should display events on a tooltip.
         * 
         * @return  {Boolean}
         */
        ShowEvents => false

        /**
         * If `ShowEvents` is enabled, shows the name and type signature of
         * undefined events thrown by the COM object. Otherwise, does nothing.
         * 
         * @param   {String}  MethodName  name of the undefined event
         * @param   {Any*}    Args        zero or more arguments
         * @return  {Any}
         */
        __Call(MethodName, Args) {
            static Events := Array()

            if (!this.ShowEvents) {
                return
            }
            CoordMode("ToolTip", "Screen")
            Args.Pop()

            ArgumentTypes := ""
            for Arg in Args {
                if (A_Index != 1) {
                    ArgumentTypes .= ", "
                }
                ArgumentTypes .= ToString(Arg)
            }

            DisplayedText := Format("{}({})", MethodName, ArgumentTypes)
            
            static ToString(Arg) {
                if (Arg is VarRef) {
                    return "&" . Type(%Arg%)
                }
                try return String(Arg)
                return Type(Arg)
            }

            Events.Push(DisplayedText)
            Display(Events)
            SetTimer(DisplayAfterTimeout.Bind(Events), -5000)

            static DisplayAfterTimeout(Events) {
                Events.RemoveAt(1)
                Display(Events)
            }
            static Display(Events) {
                Result := ""
                for Event in Events {
                    if (A_Index != 1) {
                        Result .= "`r`n"
                    }
                    Result .= Event
                }
                ToolTip(Result, 50, 50)
            }
        }

        /** Called when an object is deleted. */
        __Delete() {
            Arr := Array()
            for PropertyName in ObjOwnProps(this) {
                Arr.Push(Object.Prototype.DeleteProp.Bind(this, PropertyName))
            }
            for Function in Arr {
                Function()
            }
        }
    }
}