// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//
using sql

class ModelTest : Test
{
  SqlService? db

  override Void setup()
  {
    db = SqlService("jdbc:mysql://localhost:3306/fantest", "fantest", "fantest")
    db.open
  }

  override Void teardown()
  {
    db?.close
  }

  Void testModel()
  {
    m := ModelA()
    m.save(db)
  }
}

class ModelA : DBModel
{
  Str keyField := "AbcdEf"
  Int myval := 35
  @Transient Int dontSaveIt := 24
  @SerializeField Str[] mylist := ["Me", "You", "Everybody"]
}

