/**
 * A user-friendly framework that wraps COM objects in clean and class-based
 * interfaces.
 * 
 * ---
 * 
 * **How to Use**:
 * 
 * Create a subclass of `Com`, and define one of the following members:
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
 *   IID of the interface (default `IID_IDispatch`).
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
 * - `(optional) static ReturnTypes => Object`
 * 
 *   Maps method or property names to their corresponding COM wrapper classes.
 *   Used to automatically wrap returned COM object to the given types.
 *  
 * ---
 * 
 * **Example**:
 * 
 * ```
 * class InternetExplorer extends Com {
 *     static CLSID => "InternetExplorer.Application"
 *     ; static IID => "..."
 * 
 *     __New(URL) {
 *         this.Visible := true
 *         this.Navigate(URL)
 *     }
 * 
 *     static MethodSignatures => {
 *         ; converted to:
 *         ; 
 *         ;   DoSomething(Arg1, Arg2) {
 *         ;       return ComCall(1, this, "Int", Arg1, "UInt", Arg2)
 *         ;   }
 *         DoSomething: [1, "Int", "UInt"]
 *     }
 *     
 *     class EventSink extends Com.EventSink
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
 * ---
 * 
 * **Notes**:
 * 
 * - To assign new fields, you must use `.DefineProp(..., { Value: ... })`.
 * 
 * ---
 * 
 * **`AbstractCom` class**:
 * 
 * `AbstractCom` is a marker class for non-instantiable COM wrappers. It's
 * used as a base for classes that represent COM object with their own
 * properties and methods, which have no CLSID and are usually returned
 * by accessing other COM objects.
 * 
 * @module  <System/COM>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * class InternetExplorer extends Com {
 *     ...
 * }
 * 
 * IE := InternetExplorer()
 * IE.DefineProp("IsBoring", { Value: false })
 * 
 * @example
 * class Word extends Com {
 *     static CLSID => "Word.Application"
 *     static ReturnTypes => { Documents: Word.Documents }
 * 
 *     class Documents extends AbstractCom {
 *         ...
 *     }
 * }
 * 
 * Wd := Word()
 * Docs := Wd.Documents
 * Docs.Add()
 */
class Com {
    /**
     * (required) CLSID to wrap around. This property must be overwritten.
     * 
     * @abstract
     * @returns {String}
     */
    static CLSID => false

    /**
     * (optional) The default IID used for Com objects (IID-IDispatch).
     * 
     * @abstract
     * @returns {String}
     */
    static IID => "{00020400-0000-0000-C000-000000000046}"

    /**
     * (optional) Method signatures to `ComCall()` methods.
     * 
     * @abstract
     * @returns {Object}
     */
    static MethodSignatures => false

    /**
     * (optional) Maps methods and properties to the given return type.
     * 
     * @abstract
     * @returns {Object}
     */
    static ReturnTypes => false

    /**
     * Class initialization.
     * 
     * 1. Ensures a Com-class has both `CLSID` and `IID`.
     * 2. Maps return types defined by `static ReturnTypes`.
     * 3. Sets up `ComCall()`-methods declared in `static MethodSignatures`.
     */
    static __New() {
        static GetProp := {}.GetOwnPropDesc
        static Define  := {}.DefineProp
        static Delete  := {}.DeleteProp

        if (this == Com || this == AbstractCom) {
            return
        }
        ClassName := this.Prototype.__Class
        if (!HasBase(this, AbstractCom)) {
            Delete(this.Prototype, "__Class")
            if (!this.CLSID) {
                throw ValueError('Missing "static CLSID" property.',,
                                 ClassName)
            }
            if (IsObject(this.CLSID)) {
                throw TypeError("Expected CLSID to be a String",,
                                Type(this.CLSID))
            }
            if (IsObject(this.IID)) {
                throw TypeError("Expected IID to be a String",,
                                Type(this.IID))
            }
        }

        if (ObjHasOwnProp(this, "EventSink") && !(this.EventSink is Class)) {
            throw TypeError("Event sink must be a Class object.")
        }

        if (this.ReturnTypes) {
            Types := this.ReturnTypes
            if (ObjGetBase(Types) != Object.Prototype) {
                throw TypeError("Expected an Object literal",, Type(Types))
            }
            for PropName, ReturnType in ObjOwnProps(Types) {
                if (!HasBase(ReturnType, Com)) {
                    throw TypeError("Expected a Com class", Type(ReturnType))
                }
                PropDesc := CreateMethod(PropName, ReturnType)
                Define(this.Prototype, PropName, PropDesc)

                static CreateMethod(PropName, T) {
                    return {
                        Get:  (C, Args*) => T.FromObj(C._.%PropName%[Args*]),
                        Call: (C, Args*) => T.FromObj(C._.%PropName%(Args*))
                    }
                }
            }
        }

        if (!this.MethodSignatures) {
            return
        }

        Signatures := this.MethodSignatures
        if (ObjGetBase(Signatures) != Object.Prototype) {
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
            Callback := ObjBindMethod(ComCall,, Index, unset, Mask*)
            try  {
                Name := Cls.Prototype.__Class . ".Prototype." . MethodName
                Define(Callback, "Name", { Get: (_) => Name })
            }
            Define(Cls.Prototype, MethodName, { Call: Callback })
        }
    }

    /**
     * Constructs a new `Com` object from the `static CLSID` and `static IID`
     * properties of the class.
     * 
     * @param   {Any*}  Args  arguments passed to `__New()`
     * @returns {Com}
     * @example
     * class InternetExplorer extends Com {
     *     static CLSID => "InternetExplorer.Application"
     *     ; ...
     * }
     * 
     * ie := InternetExplorer("https://www.autohotkey.com")
     */
    static Call(Args*) {
        return this.FromObj(ComObject(this.CLSID, this.IID), Args*)
    }

    /**
     * Queries the Com object for an interface or service.
     * 
     * @param   {String}   IID  the interface identifier to query
     * @param   {String?}  SID  the service identifier to query
     * @returns {ComValue}
     */
    __Query(Arg1, Arg2?) {
        return ComObjQuery(this._, Arg1, Arg?)
    }

    /**
     * Connects the Com object to an event sink.
     * 
     * If you provide your own event sink class, it **should** inherit from
     * `Com.EventSink`. Otherwise, it'll be automatically forced to do so.
     * 
     * @param   {Class}  EventSink  event sink that handles events
     * @returns {this}
     */
    __Connect(EventSink) {
        if (EventSink is Class) {
            throw TypeError("Expected a Class object",, Type(EventSink))
        }
        if (!HasBase(EventSink, Com.EventSink))
        {
            (Object.Prototype.DeleteProp)(EventSink, "__New")
            ObjSetBase(EventSink,           Com.EventSink)
            ObjSetBase(EventSink.Prototype, Com.EventSink.Prototype)

            ; call `static __New()`, which sets up its smart event handling.
            (Com.EventSink.__New)(EventSink)
        }
        ComObjConnect(this._, EventSink)
        return this
    }

    /**
     * Disconnects the Com object from its current event sink.
     * 
     * @returns {this}
     */
    __Disconnect() {
        ComObjConnect(this._)
        return this
    }

    /**
     * Constructs a new instance of `Com` by using a pointer to the Com object.
     * 
     * @param   {Integer}  Ptr   pointer to the Com object
     * @param   {Any*}     Args  arguments passed to `.New()`
     * @returns {Com}
     * @example
     * ie  := ComObject("InternetExplorer.Application")
     * ptr := ComObjValue(ie)
     * 
     * ie  := InternetExplorer.FromPtr(ptr)
     */
    static FromPtr(Ptr, Args*) => this.FromObj(ComObjFromPtr(Ptr), Args*)

    /**
     * Constructs a new instance of `Com` using a currently registered
     * Com object (using `ComObjActive()`).
     * 
     * @param   {Any*}  Args  arguments passed to the `.New()` constructor
     * @returns {Com}
     * @example
     * ie := InternetExplorer.FromActive()
     */
    static FromActive(Args*) => this.FromObj(ComObjActive(this.CLSID), Args*)

    /**
     * Constructs a new instance of `Com` with the given Com object to wrap
     * around.
     * 
     * ---
     * 
     * **Custom Event Sinks Must Extend `Com.EventSink`**
     * 
     * Under the hood, `Com` uses a specialized helper class `Com.EventSink` to
     * intercept and rewrite Com events.
     * 
     * If you provide your own event sink class, it **should** inherit from
     * `Com.EventSink`. Otherwise, it'll be automatically forced to do so.
     * 
     * ---
     * 
     * @param   {ComObject}  ComObj  the Com object to wrap around
     * @param   {Any*}       Args    arguments passed to `.New()`
     * @returns {Com}
     * @example
     * 
     * ie := ComObject("InternetExplorer.Application")
     * ie := InternetExplorer.FromObj(ie)
     */
    static FromObj(ComObj, Args*) {
        ; create a new `Com` object
        Obj := Object()
        ObjSetBase(Obj, this.Prototype)

        ; define internal `ComObject` to wrap around
        Obj.DefineProp("_", { Get: (Instance) => ComObj })

        ; construct the new object
        Obj.__Init()
        if (HasMethod(Obj, "__New")) {
            Obj.__New(Args*)
        }

        if (!ObjHasOwnProp(this, "EventSink") || !this.EventSink) {
            return Obj
        }

        ; event sink must be a class object.
        if (!(this.EventSink is Class)) {
            throw TypeError("Expected a Class object",, Type(this.EventSink))
        }

        ; if the event sink doesn't derive from `Com.EventSink`, we force it to.
        if (!HasBase(this.EventSink, Com.EventSink))
        {
            ; ensure that `Com.EventSink.Prototype.__New` is called.
            (Object.Prototype.DeleteProp)(this.EventSink, "__New")

            ObjSetBase(this.EventSink,           Com.EventSink)
            ObjSetBase(this.EventSink.Prototype, Com.EventSink.Prototype)

            ; call `static __New()`, which sets up its smart event handling.
            (Com.EventSink.__New)(this.EventSink)
        }

        EventSink := (this.EventSink)(Obj)
        ComObjConnect(Obj._, EventSink)
        return Obj
    }

    /**
     * Returns the pointer to the Com object.
     * 
     * @returns {Integer}
     */
    Ptr => ComObjValue(this)

    /**
     * Gets a property from the Com object.
     * 
     * @param   {String}  PropertyName  name of the property to get
     * @param   {Array}   Args          zero or more arguments
     * @returns {Any}
     */
    __Get(PropertyName, Args) {
        if (HasProp(this, "_")) {
            return this._.%PropertyName%[Args*]
        }
        throw UnsetError("no internal Com object")
    }

    /**
     * Sets a property of the Com object.
     * 
     * @param   {String}  PropertyName  name of the property to set
     * @param   {Array}   Args          zero or more arguments
     * @param   {Any}     Value         the new value of the property
     * @returns {Any}
     */
    __Set(PropertyName, Args, Value) {
        if (HasProp(this, "_")) {
            return this._.%PropertyName%[Args*] := Value
        }
        throw UnsetError("no internal Com object")
    }

    /**
     * Calls a method of the Com object.
     * 
     * @param   {String}  MethodName  name of the method to call
     * @param   {Array}   Args        zero or more arguments
     * @returns {Any}
     */
    __Call(MethodName, Args) {
        if (HasProp(this, "_")) {
            return this._.%MethodName%(Args*)
        }
        throw UnsetError("no internal Com object")
    }

    /**
     * Calls a native interface method of this Com object by index.
     * 
     * @param   {Integer}  Index  zero-based index of the method
     * @param   {Any*}     Args   zero or more arguments
     * @returns {Any}
     * @example
     * ComObj(3, "Int", 0, "UInt", 1)
     */
    Call(Index, Args*) => ComCall(Index, this._, Args*)

    /**
     * Enumerates the contents of the underlying Com object.
     * 
     * @param   {Integer}  ArgSize  parameter length of the for-loop
     * @returns {Enumerator}
     */
    __Enum(ArgSize) {
        Result := Array()
        for Value in this._ {
            Result.Push(Value)
        }
        return Result.__Enum(ArgSize)
    }

    /**
     * Returns the name of the Com object's default interface.
     * @returns {String}
     */
    __Name  => ComObjType(this._, "Name")

    /**
     * Returns the IID of the Com object.
     * @returns {String}
     */
    __IID   => ComObjType(this._, "IID")

    /**
     * Returns the object's class name. 
     * @returns {String}
     */
    __Class => ComObjType(this._, "Class")


    /**
     * `Com.EventSink` is a class that handles events thrown by the `Com`
     * object.
     * 
     * **Com Event Binding Made Clean**:
     * 
     * - Events are handled in such a way that the `this`-keyword inside of
     *   methods refers to the **calling instance of `Com`, not the event sink
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
     * displays a feed of all undefined events raised by the Com object in
     * the form of a tool tip.
     */
    class EventSink {
        /**
         * Class initialization. This methods sets up special method handling
         * which involves using the original event source (the Com class
         * instance) as `this`.
         */
        static __New() {
            if (this == Com.EventSink) {
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
             * argument and rebind `this` to the `Com` wrapper.
             */
            EventHandler(Instance, Args*) {
                Args.Pop()
                return Callback(Instance.Source, Args*)
            }
        }

        /**
         * Constructs a new `Com.EventSink` from the given `Com` source.
         * 
         * @param   {Com}  Source  Com instance that throws events
         * @returns {Com.EventSink}
         */
        __New(Source) {
            this.DefineProp("Source", { Get: (Instance) => Source })
        }

        /**
         * Determines if `__Call()` should display events on a tooltip.
         * 
         * @returns {Boolean}
         */
        ShowEvents => false

        /**
         * If `ShowEvents` is enabled, shows the name and type signature of
         * undefined events thrown by the Com object. Otherwise, does nothing.
         * 
         * @param   {String}  MethodName  name of the undefined event
         * @param   {Any*}    Args        zero or more arguments
         * @returns {Any}
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

/**
 * Marker class for non-instantiable COM wrappers.
 * 
 * Used as a base for classes that represent COM objects returned
 * by method calls, rather than directly created via CLSID.
 * 
 * Use `static ReturnTypes` to specify the return type to use as wrapper when
 * accessing a property.
 * 
 * @example
 * class Word extends Com {
 *     static CLSID => "Word.Application"
 *     static ReturnTypes => { Documents: Word.Documents }
 * 
 *     class Documents extends AbstractCom {
 *         ...
 *     }
 * }
 * 
 * Wd := Word()
 * Docs := Wd.Documents
 * MsgBox(Type(Docs)) ; Word.Documents
 * MsgBox(Docs.Application)
 * 
 * Docs.Add()
 */
class AbstractCom extends Com {
}