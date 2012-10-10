
//
// History:
//   Oct 10, 2012 tcolar Creation
//

**
** JsonTest
**
class JsonTest : Test
{
  Void test()
  {
    buf := Buf()
    original := JsonTestObj()
    JsonUtils.save(buf.out, original)
    text := buf.flip.readAllStr
    buf.clear
    loaded := JsonUtils.load(text.in, JsonTestObj#) as JsonTestObj
    JsonUtils.save(buf.out, loaded)
    text2 := buf.flip.readAllStr
    verifyEq(text, text2)
  }
}

@Serializable
class JsonTestObj
{
  
  Bool bool1 := false
  Bool? nulBool
  
  @Transient Int ignore := 5
  
  Str string := "blah"
  
  Str[] list := ["a","b","c"]
  Str[]? nullList
  
  JsonSub sub1 := JsonSub()
}

@Serializable
class JsonSub
{
    Str:Obj map1 := ["a":"1", "b":2]
    Str:Int map2 := ["a":1, "b":2, "c":3]
    [Str:Obj]? nullMap  
      
    JsonSub2 sub2 := JsonSub2(27)
}

@Serializable {simple = true}
class JsonSub2
{
    Int a
    
    new make(Int val)
    {
      a = val  
    }      
    override Str toStr() {return a.toStr}  
    static JsonSub2 fromStr(Str str) {return make(str.toInt)}  
}