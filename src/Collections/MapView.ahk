#Include <AquaHotkey>

class IMap {
    static __New() => this.Extend(Map)
}

class MapView {
    static __New() => this.Include(IMap)

    __New(M) {
        if (!(M is Map)) {
            throw TypeError("Expected a Map",, Type(M))
        }
        this.DefineProp("M", { Get: (_) => M })
    }

    Get(Key, Default?) => this.M.Get(Key, Default?)
    Has(Key)           => this.M.Has(Key)
    __Enum(ArgSize)    => this.M.__Enum(ArgSize)
    __Item[Key]        => (this.M)[Key]

    Count     => this.M.Count
    Capacity  => this.M.Capacity
    CaseSense => this.M.CaseSense
    Default   => this.M.Default
}