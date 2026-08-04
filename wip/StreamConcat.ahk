#Include <AquaHotkey>
#Include <AquaHotkey\src\Core\Utils>
#Include <AquaHotkey\src\Stream\Stream>
#Include <AquaHotkey\src\Func\Cast>

/**
 * Concatenation operations for {@link Stream}.
 * 
 * @module  <Stream/Concat>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Stream_Concat extends AquaHotkey {
    class Stream {
        /**
         * Returns a new stream with the given values appended at the end.
         * 
         * @param   {Any*}  Values
         * @returns {Stream}
         */
        ConcatValues(Values*) => this.Concat(Stream(Values))

        /**
         * 
         */
        Concat(Seqs*) {
            if (!Seqs.Length) {
                return this
            }
            loop Seqs.Length {
                if (!(Seqs[A_Index] is Stream)) {
                    Seqs[A_Index] := Stream(Seqs[A_Index])
                }
            }

            Enumers := GetEnumerator(Seqs)
            Enumer  := this
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

        /**
         * 
         */
        PrependValues(Values*) => Stream(Values).Concat(this)

        /**
         * Prepends zero or more other sequences.
         */
        Prepend(Seqs*) {
            Seqs.Push(this)
            FirstItem(Seqs, &First, &More)
            return Stream(First).Concat(More*)
        }
    }
}

#Include <AquaHotkey\src\Base\Primitives>
Stream.Of(1, 2, 3, 4).Concat(Stream.Of(5, 6, 7, 8))
      .Join(", ", "[", "]")
      .MsgBox()
