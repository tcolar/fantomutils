// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//

class ModelTest : Test
{
  Void testModel()
  {
    m := ModelA()
    m.save
  }
}

class ModelA : DBModel
{
  Str keyField := "AbcdEf"
  Int val := 35
  @Transient Int hideit := 24
}

