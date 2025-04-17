/**
 * AquaHotkey - ComEventSink.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Other/ComEventSink.ahk
 * 
 * **Overview**:
 * 
 * `ComEventSink` creates event sinks for `COM` which handle events that are
 * raised by a COM object.
 * 
 * Instead of the `ComEventSink` instance, the `this`-keyword refers to the
 * instance of `COM` which raised the event. This allows directly managing the
 * COM object by using `this`.
 * 
 * Due to this change, methods no longer accept the original COM object which
 * raised the event as final parameter.
 * 
 * If non-static property `ShowEvents` is set to true, the event sink displays a
 * feed of all undefined events raised by the COM object.
 * 
 * **Example**:
 * 
 * ```
 * class InternetExplorer extends COM {
 *     static CLSID => "InternetExplorer.Application"
 *     
 *     class InternetExplorerEventSink extends ComEventSink
 *     {
 *         DocumentComplete(pDisp, &URL)
 *         {
 *             MsgBox("document complete: " . URL)
 *             this.Quit() ; [Instance of InternetExplorer].Quit()
 *         }
 * 
 *         ShowEvents => true
 *     }
 * }
 * ```
 */
class ComEventSink {
    /**
     * Class initialization. This methods sets up special method handling
     * which involves using the original event source (the COM class instance)
     * as `this`.
     */
    static __New() {
        if (ObjGetBase(this) == Object) {
            return
        }
        for MethodName in ObjOwnProps(this.Prototype) {
            DefineMethod(this, MethodName)
        }

        static DefineMethod(Cls, MethodName) {
            PropDesc := Cls.Prototype.GetOwnPropDesc(MethodName)
            if (!ObjHasOwnProp(PropDesc, "Call")) {
                return
            }
            Callback := PropDesc.Call
            
            EventHandler(Instance, Args*) {
                Args.Pop() ; gets rid of original COM object
                return Callback.Call(Instance.Source, Args*)
            }
            Cls.Prototype.DefineProp(MethodName, EventHandler)
        }
    }

    /**
     * Constructs a new `ComEventSink` from the given `COM` source.
     * 
     * @param   {COM}  Source  COM instance that throws events
     * @return  {ComEventSink}
     */
    __New(Source) => this.DefineConstant("Source", Source)

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
        SetTimer(DisplayAfterTimeout.Bind(Events), -3000)

        static DisplayAfterTimeout(Events) {
            Events.RemoveAt(1)
            Display(Events)
        }
        static Display(Events) {
            Events.JoinLine().ToolTip(x := 50, y := 50)
        }
    }

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
