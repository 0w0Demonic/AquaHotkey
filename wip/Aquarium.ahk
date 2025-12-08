#Requires AutoHotkey v2.0

class Aquarium extends Object {
    ;@region Setup + Construction

    static __New() {
        
    }

    __New() {

    }

    Has(PropertyName) {

    }

    __Item[Key] {
        get {

        }
        set {

        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Object Relation

    static Create() {
        if (this == Aquarium) {
            throw TypeError("This method must be called from a subtype")
        }
        ; TODO finish this
    }
    
    static BelongsTo(Cls) {

    }

    ; TODO these have to return another object where you can call "through"

    static HasOne(PropertyName, Conf?) {
        if (IsObject(PropertyName)) {
            throw TypeError("Expected a String",, Type(PropertyName))
        }
        
    }
    
    static HasMany(PropertyName, Args*) {

    }

    static HasAndBelongsToMany(PropertyName, Args*) {

    }

    static Serialize(PropertyName, Args*) {

    }

    static ComposedOf(Properties*) {

    }
    
    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Querying

    static Where() {

    }

    static Order(Comp) {

    }

    static Find() {

    }
    
    static FindBy() {

    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Results

    class Result {
        First() {

        }
    }

    ;@endregion
}

class User extends Aquarium {
    static __New() {
        this.HasOne("Profile")
    }

    static Auth(Username, Password) {
        
    }
}

class Profile extends Aquarium {
    static __New() {
        this.BelongsTo(User)
    }
}



; TODO list
; - beforeTypeCast?
; - static HasAttribute() ?
; - static Attributes ?
; - <...>InDatabase?
; - WillSaveChangeTo<...>?
; - <...>ChangeToBeSaved?
; - ChangesToSave?
; - <...>BeforeLastSave
; - Save
; - PrimaryKey ?
; - 
; - 
; - 
; - 
; - 
; - 
; - 
; - 