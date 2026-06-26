#Requires AutoHotkey v2.0
#Include <AquaHotkey>

; the document itself
class Xml {
    ; constructor, parse entire string
    __New(Str) {
        
    }

    ; to string, including header
    ToString() {

    }

    ; TODO find a way to differentiate between eager and lazy
    static FromFile() {

    }

    WriteToFile(File) {
        
    }
}

; any kind of XML tag --- meant to be an abstract class
class XmlElement {
    ; attributes (create a new map, if absent)
    Attributes {
        get {
            M := Map()
            this.DefineProp("Attributes", { Get: (_) => M })
            return M
        }
    }

    ; elements (create a new array, if absent)
    Elements {
        get {
            A := Array()
            this.DefineProp("Elements", { Get: (_) => A })
            return A
        }
    }

    ; constructor that receives name, optionally
    ; attributes and elements
    __New(Name, Attrs?, Elems?) {
        ; ...
    }

    ToString() {
        throw ValueError("abstract method")
    }

    ; `HasAttribute` and `HasElement`, possibly something for creating
    ; predicate function for visiting, not sure yet
    static HasAttribute(Key, Condition?) {

    }

    static HasElement(Key, Condition?) {

    }
}

; a comment
class XmlComment extends XmlElement {
    __New(Content) {
        ; ...
    }

    ToString() {

    }
}