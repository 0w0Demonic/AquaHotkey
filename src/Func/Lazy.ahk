#Include <AquaHotkey\src\Func\Cast>

/**
 * TODO
 */
class Lazy extends Func {
    static Call(Fn, Args*) {
        GetMethod(Fn)
        return this.Cast(Lazy)

        Lazy() {
            static Value := Fn(Args*)
            return Value
        }
    }

    Map(Mapper, Args*) {
        return this.Cast(Mapped)

        Mapped() => Mapper(this(), Args*)
    }
}
