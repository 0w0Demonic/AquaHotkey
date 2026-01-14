#Include <AquaHotkey\src\String\StringFormatting>
#Include <AquaHotkey\src\String\StringMatching>
#Include <AquaHotkey\src\String\Substrings>

class Test_String extends TestSuite {
    static IsEmpty1() {
        "".IsEmpty.AssertEquals(true)
    }

    static IsEmpty2() {
        "Hello, world!".IsEmpty.AssertEquals(false)
    }
    
    static __Enum1() {
        Arr := Array()
        for Char in "Hello, world!" {
            Arr.Push(Char)
        }
        Arr.Join().AssertEquals("Hello, world!")
    }

    static __Enum2() {
        Arr := Array()
        for Index, Char in "Hello, world!" {
            Arr.Push(Index, Char)
        }
        Arr.Join().AssertEquals("1H2e3l4l5o6,7 8w9o10r11l12d13!")
    }

    static Lines() {
        Arr := "
        (
        Hello
        world
        apple
        banana
        )".Lines()
        Arr.Length.AssertEquals(4)
        Arr[1].AssertEquals("Hello")
        Arr[2].AssertEquals("world")
        Arr[3].AssertEquals("apple")
        Arr[4].AssertEquals("banana")
    }

    static Before1() {
        "Hello, world!".Before("world!").AssertEquals("Hello, ")
    }

    static Before2() {
        "Hello, world!".Before("banana").AssertEquals("Hello, world!")
    }

    static Before3() {
        this.AssertThrows(() => (
            "Hello, world!".Before("")
        ))
    }

    static BeforeRegex1() {
        "Test123AppleBanana".BeforeRegex("\d++").AssertEquals("Test")
    }

    static BeforeRegex2() {
        "Test123AppleBanana".BeforeRegex("x").AssertEquals("Test123AppleBanana")
    }

    static BeforeRegex3() {
        this.AssertThrows(() => (
            "hi".BeforeRegex("")
        ))
    }

    static BeforeRegex4() {
        this.AssertThrows(() => (
            "hi".BeforeRegex(Object())
        ))
    }

    static Until1() {
        "Hello, world!".Until(",").AssertEquals("Hello,")
    }

    static Until2() {
        "Hello, world!".Until("x").AssertEquals("Hello, world!")
    }

    static UntilRegex1() {
        "Test123AppleBanana".UntilRegex("\d++").AssertEquals("Test123")
    }

    static UntilRegex2() {
        "Test123AppleBanana".UntilRegex("x").AssertEquals("Test123AppleBanana")
    }

    static From1() {
        "Hello, world!".From(",").AssertEquals(", world!")
    }

    static From2() {
        "Hello, world!".From("x").AssertEquals("Hello, world!")
    }

    static FromRegex1() {
        "Test123AppleBanana".FromRegex("\d++").AssertEquals("123AppleBanana")
    }

    static FromRegex2() {
        "Test123".FromRegex("x").AssertEquals("Test123")
    }

    static After1() {
        "Hello, world!".After(",").AssertEquals(" world!")
    }

    static After2() {
        "Hello, world!".After("x").AssertEquals("Hello, world!")
    }

    static Prepend() {
        "world!".Prepend("Hello, ").AssertEquals("Hello, world!")
    }

    static Append() {
        "Hello, ".Append("world!").AssertEquals("Hello, world!")
    }

    static Surround1() {
        "test".Surround("_").AssertEquals("_test_")
    }

    static Surround2() {
        "test".Surround("(", ")").AssertEquals("(test)")
    }

    static Repeat() {
        "t".Repeat(8).AssertEquals("tttttttt")
    }

    static Reversed()  {
        "banana".Reversed().AssertEquals("ananab")
    }

    static SplitPath() {
        SP := "C:\Users\sven\Desktop\images\potato.png".SplitPath()
        SP.Name.AssertEquals("potato.png")
        SP.Dir.AssertEquals("C:\Users\sven\Desktop\images")
        SP.Ext.AssertEquals("png")
        SP.NameNoExt.AssertEquals("potato")
        SP.Drive.AssertEquals("C:")
    }

    static RegExMatch1() {
        "Test123Abc".RegExMatch("\d++").AssertEquals(5)
    }

    static RegExMatch2() {
        "Test123Abc".RegExMatch("\d++", &Match).AssertEquals(5)

        Match[0].AssertEquals("123")
    }
    
    static RegExReplace() {
        "Test123Abc".RegExReplace("\d++").AssertEquals("TestAbc")
    }

    static Match() {
        "Test123Abc".Match("\d++")[0].AssertEquals("123")
    }

    static MatchAll() {
        MatchObjs := "Test123Abc".MatchAll("\d")
        MatchObjs.Length.AssertEquals(3)
        MatchObjs[1][0].AssertEquals(1)
        MatchObjs[2][0].AssertEquals(2)
        MatchObjs[3][0].AssertEquals(3)
    }

    static Capture() {
        "Test123Abc".Capture("\d++").AssertEquals("123")
    }

    static CaptureAll() {
        "Test123Abc".CaptureAll("\d").Join(" ").AssertEquals("1 2 3")
    }

    static Insert1() {
        "def".Insert("abc").AssertEquals("abcdef")
    }

    static Insert2() {
        "abdef".Insert("c", 3).AssertEquals("abcdef")
    }

    static Insert3() {
        "abc".Insert("d", 0).AssertEquals("abcd")
    }

    static Insert4() {
        "abd".Insert("c", -1).AssertEquals("abcd")
    }

    static Overwrite1() {
        "zbc".Overwrite("a").AssertEquals("abc")
    }
    
    static Overwrite2() {
        "abd".Overwrite("c", 3).AssertEquals("abc")
    }

    static Overwrite3() {
        "abc".Overwrite("d", 0).AssertEquals("abcd")
    }

    static Overwrite4() {
        "abd".Overwrite("c", -1).AssertEquals("abc")
    }

    static Delete1() {
        "abbbc".Delete(2, 2).AssertEquals("abc")
    }
    
    static Delete2() {
        "abcc".Delete(-1).AssertEquals("abc")
    }

    static Delete3() {
        "abcc".Delete(-1, 100).AssertEquals("abc")
    }

    static LPad() {
        "Hello, world!".LPad(" ", 1).AssertEquals(" Hello, world!")
    }

    static RPad() {
        "Hello, world!".RPad(" ", 1).AssertEquals("Hello, world! ")
    }

    static __Item() {
        "Hello, world!".__Item[2].AssertEquals("e")
    }

    static Length() {
        "abcdef".Length.AssertEquals(6)
    }

    static Size1() {
        "abcdef".Size.AssertEquals((6 + 1) * 2) ; UTF-16
    }

    static Size2() {
        "abcdef".Size["CP20127"].AssertEquals(6 + 1) ; US-ASCII
    }

    static Size3() {
        "abcdef".Size["UTF-8"].AssertEquals(6 + 1) ; UTF-8
    }
}

