// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//

using sql
**
** DB/SQL Utility functions
**
class DBUtil
{

  const static Str counterTable := "__net_colar_db_cpt"

  ** Normalize from Camel case (Fantom Type) into db friendly format : lower case, underscore separated
  ** Examples: "userSettings" -> "user_settings"
  static Str? normalizeDBName(Str? name)
  {
    if(name==null) return null

    norm := StrBuf()
    name.each |Int c|
    {
      if((c >= 'a' && c<='z') || (c >= '0' && c<='9'))
        norm.addChar(c)
      else if(c >= 'A' && c <= 'Z')
      {
        if( ! norm.isEmpty && norm[norm.size-1] >= 'a' && norm[norm.size-1] <= 'z')
          norm.addChar('_')
        norm.addChar(c.lower)
      }
      else
        norm.addChar('_')
    }
    return norm.toStr
  }
  
  static Bool tableExists(SqlService db, Str tableName)
  {
      db.tableExists(tableName)
  }

  static Void deleteTable(SqlService db, Str tableName)
  {
    if(tableExists(db, tableName))
      QueryManager.execute(db, "DROP TABLE $tableName" ,null, true)
  }

  static Void createTable(SqlService db, DBModelMapping mapping)
  {
    mapping.getCreateTableSql.each
    {
      QueryManager.execute(db, it ,null, true)
    }
  }

  // TODO: needs to be done atomically, how to do that in fantom ??
  // TODO: Maybe use SqlDialect instead and implement autoincrement for several DB's
  static Int nextVal(SqlService db, Str counterName)
  {
    //TODO: Useless since DB2 just returns db(this) -> just use db and set it to autocommit and back as needed
    SqlService db2 := db.open
    db2.autoCommit = false
    Int id := 1
    try
    {
      Str counterTable := "__net_colar_db_cpt"
      if( ! tableExists(db2, counterTable))
      {
        QueryManager.execute(db2, "CREATE TABLE $counterTable (name VARCHAR(80) NOT NULL, val BIGINT NOT NULL)", null, true)
      }
      Row[] rows := QueryManager.execute(db2, "SELECT * FROM $counterTable WHERE name='$counterName'", null, false)
      if(rows.isEmpty)
      {	// new counter
		QueryManager.execute(db2, "INSERT INTO $counterTable (val, name) values(2, '$counterName')", null, true)
      }
	  else
	  {
		id = rows[0]->val
	    nextId := id + 1
		QueryManager.execute(db2, "UPDATE $counterTable set val=$nextId WHERE name='$counterName'", null, true)
	  }
      db2.commit
    }
    catch (Err e)
    {
      db2.rollback
      throw(e)
    }
    finally
    {
      db2.close
    }
    return id
  }
}