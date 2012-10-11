
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
    original := JsonTestObj {}
    JsonUtils.save(buf.out, original)
    text := buf.flip.readAllStr
    //echo(text)
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
  
  const Bool bool1 := false
  Bool? nulBool
  
  @Transient Int ignore := 5
  
  Str string := "blah"
  
  Str[] list := ["a","b","c"]
  Str[]? nullList
  
  JsonSub sub1 := JsonSub {}
  
  TestEnum en := TestEnum.f
  
  new make(|This| f) {f(this)}
}

@Serializable
class JsonSub
{
    Str:Obj map1 := ["a":"1", "b":2]
    Str:Int map2 := ["a":1, "b":2, "c":3]
    [Str:Obj]? nullMap  
      
    JsonSub2 sub2 := JsonSub2.makeInt(27)
    
    new make(|This| f) {f(this)}  
}

@Serializable {simple = true}
class JsonSub2
{
    Int a
    
    new makeInt(Int val)
    {
      a = val  
    }      
    override Str toStr() {return a.toStr}  
    static JsonSub2 fromStr(Str str) {return makeInt(str.toInt)}  
}

enum class TestEnum
{
  t, g, i , f
}