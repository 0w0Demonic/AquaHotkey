#Include <AquaHotkey\src\String\StringFormatting>
#Include <AquaHotkey\src\String\StringMatching>
#Include <AquaHotkey\src\String\Substrings>

class Test_String extends TestSuite {
    static IsEmpty1() {
        "".IsEmpty.Assert(Eq(true))
    }

    static IsEmpty2() {
        "Hello, world!".IsEmpty.Assert(Eq(false))
    }
    
    static __Enum1() {
        Arr := Array()
        for Char in "Hello, world!" {
            Arr.Push(Char)
        }
        Arr.Join().Assert(Eq("Hello, world!"))
    }

    static __Enum2() {
        Arr := Array()
        for Index, Char in "Hello, world!" {
            Arr.Push(Index, Char)
        }
        Arr.Join().Assert(Eq("1H2e3l4l5o6,7 8w9o10r11l12d13!"))
    }

    static Lines() {
        Arr := "
        (
        Hello
        world
        apple
        banana
        )".Lines()
        Arr.Length.Assert(Eq(4))
        Arr[1].Assert(Eq("Hello"))
        Arr[2].Assert(Eq("world"))
        Arr[3].Assert(Eq("apple"))
        Arr[4].Assert(Eq("banana"))
    }

    static Before1() {
        "Hello, world!".Before("world!").Assert(Eq("Hello, "))
    }

    static Before2() {
        "Hello, world!".Before("banana").Assert(Eq("Hello, world!"))
    }

    static Before3() {
        this.AssertThrows(() => (
            "Hello, world!".Before("")
        ))
    }

    static BeforeRegex1() {
        "Test123AppleBanana".BeforeRegex("\d++").Assert(Eq("Test"))
    }

    static BeforeRegex2() {
        "Test123AppleBanana".BeforeRegex("x").Assert(Eq("Test123AppleBanana"))
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
        "Hello, world!".Until(",").Assert(Eq("Hello,"))
    }

    static Until2() {
        "Hello, world!".Until("x").Assert(Eq("Hello, world!"))
    }

    static UntilRegex1() {
        "Test123AppleBanana".UntilRegex("\d++").Assert(Eq("Test123"))
    }

    static UntilRegex2() {
        "Test123AppleBanana".UntilRegex("x").Assert(Eq("Test123AppleBanana"))
    }

    static From1() {
        "Hello, world!".From(",").Assert(Eq(", world!"))
    }

    static From2() {
        "Hello, world!".From("x").Assert(Eq("Hello, world!"))
    }

    static FromRegex1() {
        "Test123AppleBanana".FromRegex("\d++").Assert(Eq("123AppleBanana"))
    }

    static FromRegex2() {
        "Test123".FromRegex("x").Assert(Eq("Test123"))
    }

    static After1() {
        "Hello, world!".After(",").Assert(Eq(" world!"))
    }

    static After2() {
        "Hello, world!".After("x").Assert(Eq("Hello, world!"))
    }

    static Prepend() {
        "world!".Prepend("Hello, ").Assert(Eq("Hello, world!"))
    }

    static Append() {
        "Hello, ".Append("world!").Assert(Eq("Hello, world!"))
    }

    static Surround1() {
        "test".Surround("_").Assert(Eq("_test_"))
    }

    static Surround2() {
        "test".Surround("(", ")").Assert(Eq("(test)"))
    }

    static Repeat() {
        "t".Repeat(8).Assert(Eq("tttttttt"))
    }

    static Reversed()  {
        "banana".Reversed().Assert(Eq("ananab"))
    }

    static SplitPath() {
        SP := "C:\Users\sven\Desktop\images\potato.png".SplitPath()
        SP.Name.Assert(Eq("potato.png"))
        SP.Dir.Assert(Eq("C:\Users\sven\Desktop\images"))
        SP.Ext.Assert(Eq("png"))
        SP.NameNoExt.Assert(Eq("potato"))
        SP.Drive.Assert(Eq("C:"))
    }

    static RegExMatch1() {
        "Test123Abc".RegExMatch("\d++").Assert(Eq(5))
    }

    static RegExMatch2() {
        "Test123Abc".RegExMatch("\d++", &Match).Assert(Eq(5))

        Match[0].Assert(Eq("123"))
    }
    
    static RegExReplace() {
        "Test123Abc".RegExReplace("\d++").Assert(Eq("TestAbc"))
    }

    static Match() {
        "Test123Abc".Match("\d++")[0].Assert(Eq("123"))
    }

    static MatchAll() {
        MatchObjs := "Test123Abc".MatchAll("\d")
        MatchObjs.Length.Assert(Eq(3))
        MatchObjs[1][0].Assert(Eq(1))
        MatchObjs[2][0].Assert(Eq(2))
        MatchObjs[3][0].Assert(Eq(3))
    }

    static Capture() {
        "Test123Abc".Capture("\d++").Assert(Eq("123"))
    }

    static CaptureAll() {
        "Test123Abc".CaptureAll("\d").Join(" ").Assert(Eq("1 2 3"))
    }

    static Insert1() {
        "def".Insert("abc").Assert(Eq("abcdef"))
    }

    static Insert2() {
        "abdef".Insert("c", 3).Assert(Eq("abcdef"))
    }

    static Insert3() {
        "abc".Insert("d", 0).Assert(Eq("abcd"))
    }

    static Insert4() {
        "abd".Insert("c", -1).Assert(Eq("abcd"))
    }

    static Overwrite1() {
        "zbc".Overwrite("a").Assert(Eq("abc"))
    }
    
    static Overwrite2() {
        "abd".Overwrite("c", 3).Assert(Eq("abc"))
    }

    static Overwrite3() {
        "abc".Overwrite("d", 0).Assert(Eq("abcd"))
    }

    static Overwrite4() {
        "abd".Overwrite("c", -1).Assert(Eq("abc"))
    }

    static Delete1() {
        "abbbc".Delete(2, 2).Assert(Eq("abc"))
    }
    
    static Delete2() {
        "abcc".Delete(-1).Assert(Eq("abc"))
    }

    static Delete3() {
        "abcc".Delete(-1, 100).Assert(Eq("abc"))
    }

    static __Item() {
        "Hello, world!".__Item[2].Assert(Eq("e"))
    }

    static Length() {
        "abcdef".Length.Assert(Eq(6))
    }

    static Size1() {
        "abcdef".SizeInBytes.Assert(Eq((6 + 1) * 2)) ; UTF-16
    }

    static Size2() {
        "abcdef".SizeInBytes["CP20127"].Assert(Eq(6 + 1)) ; US-ASCII
    }

    static Size3() {
        "abcdef".SizeInBytes["UTF-8"].Assert(Eq(6 + 1)) ; UTF-8
    }
}

