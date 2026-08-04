#Include <AquaHotkey>
#Include <AquaHotkey\src\Stream\Stream>
#Include <AquaHotkey\src\Func\Cast>

class AquaHotkey_Stream_Concat extends AquaHotkey {
    class Stream {
        ConcatValues(Values*) => this.Concat(Stream(Values))

        Concat(Seqs*) {
            if (!Seqs.Length) {
                return this
            }
            loop Seqs.Length {
                if (!(Seqs[A_Index] is Stream)) {
                    Seqs[A_Index] := Stream(Seqs[A_Index])
                }
            }

            Enumers := Array(this, Seqs*).__Enum(1)
            Enumers(&Enumer)
            ObjSetBase(Concat, ObjGetBase(this))
            return this.Cast(Concat)

            Concat(&Out) {
                loop {
                    if (Enumer(&Out)) {
                        return true
                    }
                    if (!Enumers(&Enumer)) {
                        return false
                    }
                }
            }
        }

        PrependValues(Values*) => Stream(Values).Concat(this)

        Prepend(Seqs*) {
            if (!Seqs.Length) {
                return this
            }
            Seqs.Push(this)
            Enumer := Seqs.__Enum(1)
            Enumer(&First)
            return Stream(First).Concat(Enumer*)
        }
    }
}

