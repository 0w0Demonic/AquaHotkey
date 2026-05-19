#Requires AutoHotkey v2.0
#Include <AquaHotkey\src\Interfaces\IMap>

class AquaHotkey_Object_Properties extends AquaHotkey {
class Object {
    Properties => Object.Properties(this)

    /**
     * A map view of an object, whose properties are expressed as
     * property names, mapped to a property descriptor (`.GetOwnPropDesc()`).
     */
    class Properties extends IMap {
        ; TODO does this set of args break some kind of convention?
        /**
         * 
         */
        __New(Obj := Object()) {
            if (!IsObject(Obj)) {
                throw TypeError("Expected an Object",, Type(Obj))
            }
            this.DefineProp("O", { Get: (_) => Obj })
        }

        /**
         * Clears the map, removing all properties from the object.
         */
        Clear() {
            static Delete := ({}.DeleteProp)

            Obj := this.O
            PropNames := Array()
            for PropName in ObjOwnProps(Obj) {
                PropNames.Push(PropName)
            }

            for PropName in PropNames {
                Delete(Obj, PropName)               
            }
        }

        Clone() => Object.Properties(this.O.Clone())

        Delete(Key) {
            Obj := this.O
            if (!ObjHasOwnProp(Obj, Key)) {
                throw UnsetItemError("property does not exist")
            }

            return ({}.DeleteProp)(Obj, Key)
        }

        /**
         * Retrieves an item 
         */
        Get(Key, Default?) {
            Obj := this.O
            if (ObjHasOwnProp(Obj, Key)) {
                return ({}.GetOwnPropDesc)(Obj, Key)
            }
            if (IsSet(Default)) {
                return Default
            }
            if (HasProp(this, "Default")) {
                return this.Default
            }
            throw UnsetItemError("property does not exist",, Type(Key))
        }

        /**
         * Determines whether the given key is present in the map (whether the
         * object owns the given property)
         * 
         * @param   {String}  Key  map key (property name)
         * @returns {Boolean}
         */
        Has(Key) => ObjHasOwnProp(this.O, Key)

        ; TODO use prop descs or value itself?
        /**
         * Sets zero or more items.
         * 
         * @param   {Any*}  Args  alternating key `{String}` and value `{Any}`
         */
        Set(Args*) {
            static Define := ({}.DefineProp)
            static Delete := ({}.DeleteProp)

            if (Args.Length & 1) {
                throw ValueError("invalid param count",, Args.Length)
            }
            Enumer := Args.__Enum(1)
            Obj := this.O
            while (Enumer(&Key) && Enumer(&Value)) {
                Define(Obj, Key, Value)
            }
        }

        /**
         * Returns an `Enumerator` for this map.
         * 
         * @returns {Enumerator}
         */
        __Enum(ArgSize) => ObjOwnProps(this.O)

        /**
         * Retrieves the size of this map.
         * 
         * @returns {Integer}
         */
        Count => ObjOwnPropCount(this.O)

        /**
         * The capacity of this map. Increasing capacity also increases the
         * capacity of the wrapped object.
         * 
         * @param   {Integer}  value  the new capacity
         * @returns {Integer}
         */
        Capacity {
            get => ObjGetCapacity(this.O)
            set => ObjSetCapacity(this.O, value)
        }

        /**
         * Case-sensitivity of the map (by default always `false`).
         * 
         * @property {Boolean}
         */
        CaseSense {
            get => false
            set => ""
        }

        /**
         * Sets or retrieves properties.
         * 
         * @param   {String}  Key    property name
         * @param   {Any}     Value  property value
         */
        __Item[Key] {
            get => this.Get(Key)
            set => this.Set(Key, value)
        }

        /**
         * Returns the inner object this map wraps around.
         * 
         * @returns {Object}
         */
        AsObject() => (this.O)

        /**
         * Returns a clone of the wrapped object.
         * 
         * @returns {Object}
         */
        ToObject() => (this.O).Clone()
    }
}
}

O := Object()
Props := O.Properties
Props["foo"] := { Value: "bar" }

O.ToString().MsgBox()