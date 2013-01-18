// History:
//  Jan 13 13 tcolar Creation
//

**
** JsonSettingsTest
**
class JsonSettingsTest : Test
{
  Void testSettings()
  {
    settings := JsonSettings
    {
      headComments =
      [
    "This is the setting file for Dummy Test 1.3",
    "Feel free to change stuff !"
      ]
    }

    s := MySettings {}
    f := File(`/tmp/jsonsettings.txt`)//.deleteOnExit
    settings.save(s, f.out)

    // save & read
    MySettings? s2 := settings.read(MySettings#, f.in) as MySettings

    validateSettings(s, s2)

    // change values and test save/read
    s.port = 1000
    s.host = "tesHost"
    s.notSaved = 0
    s.paths = ["test1", "test2"]
    settings.save(s, f.out)
    s2 = settings.read(MySettings#, f.in) as MySettings

    validateSettings(s, s2)
    verifyEq(s.notSaved, 0)
    verifyEq(s2.notSaved, 5)

    // Testing in-place update
    // add user comments and test update/read
    lines := f.readAllLines
    lines.insert(0, "# Custom comment 1")
    lines.add("# Custom comment 2")
    out:=f.out
    lines.each {out.printLine(it)}
    out.close
    //changes values
    s.port = 2000
    s.host = "testHost2"
    s.notSaved = 1
    s.paths = ["test2", "test3"]
    settings.update(s, f)
    s2 = settings.read(MySettings#, f.in)

    validateSettings(s, s2)
    verifyEq(s.notSaved, 1)
    verifyEq(s2.notSaved, 5)

    lines = f.readAllLines
    verifyEq(lines[0], "# Custom comment 1")
    verifyEq(lines[-1], "# Custom comment 2")

    // check nullable exception
    s3 := BrokenSettings {}
    verifyErr(Err#) { settings.update(s3, f) }
  }

  ** Validate s and s2 have the same values
  Void validateSettings(MySettings s, MySettings s2)
  {
    verifyEq(s.port, s2.port)
    verifyEq(s.host, s2.host)
    verifyEq(s.paths, s2.paths)
    verifyEq(s.complex.bar, s2.complex.bar)
    verifyEq(s.complex.foo, s2.complex.foo)
  }

}


