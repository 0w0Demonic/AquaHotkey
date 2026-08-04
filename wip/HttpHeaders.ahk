#Include <AquaHotkey\src\Collections\Generic\Array>
#Include <AquaHotkey\src\Interfaces\Enumerable1>
#Include <AquaHotkey\wip\HttpHeader>

; TODO generalize this and `UrlParams`

/**
 * An array of HTTP headers.
 * 
 * @module  <Net/HttpHeaders>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class HttpHeaders extends GenericArray {
    static __New() => super.__New(Array, HttpHeader)
    
    ToString() => this.Join("`r`n")
}
