// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//
using sql

**
** Test DBModel functionality (ORM)
** DB needs to be created first:
** > mysql -u root -p
** > create user fantest identified by 'fantest';
** > create database fantest;
** > grant all privileges on fantest.* to fantest identified by 'fantest';
**
class ModelTest : Test
{
  SqlService? db

  override Void setup()
  {
    // create con
    db = SqlService("jdbc:mysql://localhost:3306/fantest", "fantest", "fantest")
    db.open
    // start with clean sheet
    DBUtil.deleteTable(db, DBUtil.normalizeDBName(ModelA#.name))
    DBUtil.deleteTable(db, DBUtil.counterTable)
  }

  override Void teardown()
  {
    db?.close
  }

  Void testModel()
  {
    m1 := ModelA()
    m1.save(db)
    verify(m1.id == 1, "Checking Unique id created on save")
    m2 := ModelA()
    m2.save(db)
    verify(m2.id == 2, "Sequential unique id")

    // load new copy of saved record and compare values
    ModelA? m1b := DBModel.findById(db, ModelA#, m1.id)
    verify(m1b != null, "Find By ID")
    verify(m1b.id == m1.id, "Find By ID - check same ID")
    verify(m1b.keyField == m1.keyField, "Find By ID - keyfield")
    verify(m1b.myval == m1.myval, "Find By ID - check myval")
    verify(m1b.mylist == m1.mylist, "Find By ID - check mylist")
    verify(m1b.mybool == m1.mybool, "Find By ID - check mybool")
    verify(m1b.myfloat == m1.myfloat, "Find By ID - check myfloat")
    //verify(m1b.mydecimal.compare(m1.mydecimal) == 0, "Find By ID - check mydecimal")

    // perform an update and check value are updated
    m1b.myval = 25
    m1b.mybool = false
    idBeforeUpdate := m1b.id
    m1b.save(db)
    ModelA? m1c := DBModel.findById(db, ModelA#, m1.id)
    verify(m1c.myval == 25, "Updated value - myval")
    verify(m1c.mybool == false, "Updated value - mybool")
    verify(m1b.id == m1c.id && idBeforeUpdate == m1c.id, "Checking update didn't chnage id")

    // check "delete"
    m1c.delete(db)
    verify(m1c.id == -1, "id reset on delete")
    verifyNull(DBModel.findById(db, ModelA#, m1.id), "Check deleted record is gone")
    verifyNotNull(DBModel.findById(db, ModelA#, m2.id), "Check other record was not deleted")

    // delete tables
    DBUtil.deleteTable(db, DBUtil.normalizeDBName(ModelA#.name))
    DBUtil.deleteTable(db, DBUtil.counterTable)
    verify( ! DBUtil.tableExists(db, DBUtil.normalizeDBName(ModelA#.name)), "Table deleted")
    verify( ! DBUtil.tableExists(db, DBUtil.counterTable), "Cpt table deleted")
  }
}

class ModelA : DBModel
{
  Str keyField := "AbcdEf"
  Int myval := 35
  @Transient Int dontSaveIt := 24
  @SerializeField Str[] mylist := ["Me", "You", "Everybody"]
  Bool mybool := true
  Float myfloat := 3.37f
  // TODO: decimal doesn't work -> fantom sql bug ??
  //Decimal mydecimal := 0.200526489e+6D
}

