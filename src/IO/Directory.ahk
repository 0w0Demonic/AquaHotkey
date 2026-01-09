
/**
 * @example
 * Monitor := Directory(A_ScriptDir).Watch()
 * 
 * Callbacks := Monitor.On(Directory.Event.Add)
 * Callbacks.Push((Event) {
 *     MsgBox(Type(Event)) ; "Directory.Event.Add"
 *     ; ...
 * })
 */
class Directory {
    __New(Dir) {
        
    }

    Name {

    }

    Parent {

    }

    __Enum(ArgSize) {
        
    }

    __Get(Name, Param) {
        if (!Param.Length) {
            throw TypeError("not supported")
        }

    }

    __Item[DirName] {

    }

    class Watcher {
        __New(Dir, Recursive := false, IntervalMs := 200) {
            if (!(Dir is Directory)) {
                Dir := Directory(Dir)
            }

        }
    }

    class Event {
        __New(Value) {
            if (!IsInteger(Value)) {
                throw TypeError("Expected an Integer",, Type(Value))
            }
            ({}.DefineProp)(this, "Value", { Get: (_) => Value })
        }
    }
}