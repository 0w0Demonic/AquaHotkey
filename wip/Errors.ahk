#Requires AutoHotkey v2.0
#Include <AquaHotkey\src\Core\AquaHotkey>

class ErrorConstructors extends AquaHotkey {
    class ValueError {
        static ThrowIfUnsetOrEmpty(Val?) {
            if (!IsSet(Val)) {
                throw this("value is unset", -2)
            }
            if (Val == "") {
                throw this("value is empty", -2, "(empty string)")
            }
        }
        static ThrowIfUnsetOrWhiteSpace() {

        }
    }

    class TypeError {
        static ThrowIfInvalidType(Arr, T) {

        }
    }

    class UnsetError {
        static ThrowIfUnset() {

        }
    }

    class ArgumentUnsetError {
    }

    class IndexError {
        static ThrowIfOutOfBounds(Arr, Idx) {

        }
    }
    
    class Error {
        static ThrowIf(Condition, Args*) {
            if (Condition) {
                throw this(Args*)
            }
        }
        static ThrowIfNot(Condition, Msg?, Extra?) {
            if (!Condition) {
                throw this(Msg?, -2, Extra?)
            }
        }
    }
}

class ArgumentUnsetError extends UnsetError {
}

class OutOfRangeError extends ValueError {
}

class NotSupportedException extends PropertyError {
}

Val := unset
ValueError.ThrowIfUnsetOrEmpty(Val?)

class MyFeature extends AquaHotkey {
    class Any {
        DoSomething => NotSupportedException.Throw()
    }
}

