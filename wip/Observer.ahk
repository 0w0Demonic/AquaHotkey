#Include <AquaHotkeyX>
#Include <AquaHotkey\src\Collections\OrderedMap>

; TODO move this somewhere else at some point

/**
 * Represents an observable object that holds a map of events and their
 * callback functions.
 * 
 * @module  <Base/Observable>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Observable {
    /**
     * Internal map that holds callback functions.
     * 
     * @readonly
     * @type {IMap}
     */
    Events := false ; stop VSCode plugin from complaining

    /**
     * Creates a new `Observable` with the given
     * {@link IMap.Create() map param}.
     * 
     * @constructor
     * @param   {Any?}  MapParam  map param
     */
    __New(MapParam := Map()) {
        Events := IMap.Create(MapParam)
        this.DefineProp("Events", { Get: (_) => Events })
    }

    /**
     * Adds a new callback event.
     * 
     * @param   {Any}       Event      the type of event
     * @param   {Func}      Callback   the function to be called
     * @param   {Integer?}  AddRemove  1 (last), -1 (first), 0 (remove)
     * @param   {Func}
     */
    OnEvent(Event, Callback, AddRemove := 1) {
        static ABSENT := Object()

        GetMethod(Callback)
        M := this.Events
        OM := M.Get(Event, ABSENT)
        if (OM == ABSENT) {
            OM := OrderedMap()
            M.Set(Event, OM)
        }

        switch {
          case (AddRemove == 0): ; remove
            OM.Delete(Callback)
            if (!OM.Count) {
                M.Delete(OM)
            }
          case (AddRemove > 0): ; call after
            OM.Push(Callback, true)
          case (AddRemove < 0): ; call before
            OM.Shove(Callback, true)
          default:
            throw ValueError(
                "invalid action",,
                (AddRemove is Primitive) ? AddRemove : Type(AddRemove))
        }
        return Callback
    }

    /**
     * Emits an event.
     * 
     * @param   {Any}   Event  the type of event
     * @param   {Any*}  Args   zero or more arguments passed to callbacks
     */
    Emit(Event, Args*) {
        for Callback in (this.Events).Get(Event, (*) => false) {
            Callback(Args*)
        }
    }
}

; TODO use `Enumerator.Empty()`?
class AquaHotkey_Enumerator_Empty extends AquaHotkey {
    class Enumerator {
        static Empty() => (*) => false
        static Empty   => (*) => false
    }
}

/**
 * A function that always returns `false`, useable as an {@link Enumerator}
 * that returns zero elements. This can be useful as default value when
 * retrieving a value in a {@link Map}.
 * 
 * @returns {Boolean}
 * @example
 * ; shorthand:
 * for Value in MapObj.Get(Key, EmptyEnumerator) {
 *     ...
 * }
 * 
 * ; instead of:
 * if (MapObj.Has(Key)) {
 *     for Value in MapObj.Get(Key) {
 *         ...
 *     }
 * }
 */
EmptyEnumerator(*) => false

/**
 * Utility class for creating functions that access methods and properties of
 * an input object.
 * 
 * @module  <.../Access> ; TODO find out where to put this
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Access extends Any {
    /**
     * Creates a function that accesses the specified method of its input.
     * 
     * @param   {String}  Name  name of method
     * @param   {Any*}    Args  zero or more arguments
     * @returns {Func}
     */
    static Method(Name, Args*) {
        if (!(Name is Primitive)) {
            throw TypeError("Expected a String",, Type(Name))
        }
        return (Obj) => Obj.%Name%(Args*)
    }

    /**
     * Creates a function that accesses the specified property of its input.
     * 
     * @param   {String}  Name  name of property
     * @param   {Any*}    Args  zero or more arguments
     * @returns {Func}
     * @example
     * Array({ x: 1, y: 2 }, { x: 3, y: 4 }).Map(Access.Property("x")) ; [1, 2]
     */
    static Property(Name, Args*) {
        if (!(Name is Primitive)) {
            throw TypeError("Expected a String",, Type(Name))
        }
        return (Obj) => Obj.%Name%[Args*]
    }
}
