#Requires AutoHotkey v2.0
#Include <AquaHotkey\src\Core\Utils>
#Include <AquaHotkey\src\Core\AquaHotkey>

InheritBasedOnEnclosingClass(Cls, NestedClassName) {
    if (!TryGetNestedClass(Cls, NestedClassName, &NestedClass)) {
        throw ValueError("nested class not found")
    }

    DefineProp(Cls, NestedClassName, { Get: Getter, Call: Method })

    Getter(Cls) {
        if (ObjHasOwnProp(Cls, NestedClassName)) {
            return Cls.%NestedClassName%
        }
        BaseNested := Getter(ObjGetBase(Cls))
        Nested := NestedClassProp(AquaHotkey.CreateClass(BaseNested))
        DefineProp(Cls, NestedClassName, Nested)
        return Nested
    }
    Method(Cls, Args*) => Getter(Cls)(Args*)
}


class A {
    class Nested {

    }
}

class B extends A {

}

InheritBasedOnEnclosingClass(A, "Nested")

MsgBox(Type(B.Nested))