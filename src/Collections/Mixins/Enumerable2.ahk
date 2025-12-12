
; TODO method for getting e.g. only the second parameter in 2-param for loop?

class Enumerable2 {
    ForEach2(Action, Args*) {
        for Key, Value in this {
            Action(Key?, Value?, Args*)
        }
    }

    Any2(&Out1, &Out2, Condition, Args*) {
        Out1 := unset
        Out2 := unset
        for Key, value in this {
            if (Condition(Key?, Value?, Args*)) {
                Out1 := Key ?? unset
                Out2 := Value ?? unset
                return true
            }
        }
        return false
    }

    None2(Condition, Args*) {
        for Key, Value in this {
            if (Condition(Key?, Value?, Args*)) {
                return false
            }
        }
        return true
    }

    All2(Condition, Args*) {
        for Key, Value in this {
            if (!Condition(Key?, Value?, Args*)) {
                return false
            }
        }
        return true
    }
}