#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

#Include <AquaHotkey\src\Func\Cast>
#Include <AquaHotkey\src\Collections\Map>

/**
 * 
 */
class Reducer extends Func {
}

class Transducer extends Func {
}

Grouping(Classifier, MapParam?) {
    GetMethod(Classifier)
    return Transducer.Cast(MakeGrouping)

    MakeGrouping(Reducer) {
        return WithGrouping

        WithGrouping(Values*) {
            M := Map.Create(MapParam?)
            for Value in Values {
                Key := Classifier(Value?)
                if (M.Has(Key)) {
                    M.Get(Key).Push(Key)
                } else {
                    M.Set(Key, Array(Key))
                }
            }
            for Key, Arr in M {
                M.Set(Key, Reducer(Arr*))
            }
            return M
        }
    }
}

ByProp(Name) => (Obj) => Obj.%Name%

Sum(Values*) {
    Result := Float(0)
    for Value in Values {
        Result += Value
    }
    return Result
}

Fn := Grouping(ByProp("x"))(Sum)

MsgBox(String(Fn({ x: 1 }, { x: 2 }, { x: 3 }, { x: 4 })))