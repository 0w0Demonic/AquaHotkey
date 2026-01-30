#Include "%A_LineFile%\..\Cast.ahk"

class Transducer extends Func {
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(RetainIf)

        RetainIf(Acc, Item) {
            if (Condition(Item, Args*)) {
                return this(Acc, Item)
            }
            return Acc
        }
    }

    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(RemoveIf)

        RemoveIf(Acc, Item) {
            if (Condition(Item, Args*)) {
                return Acc
            }
            return this(Acc, Item)
        }
    }

    Map(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(Mapped)

        Mapped(Acc, Item) => this(Acc, Mapper(Item, Args*))
    }
}