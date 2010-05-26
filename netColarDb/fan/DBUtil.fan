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
  ** "Cache" Of known table names, since lookup is expensive
  static const Str[] knownTables := [,]

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
      if(knownTables.contains(tableName))
        return true;
      Bool exists := db.tableExists(tableName)
      if(exists) knownTables.add(tableName)
      return exists
  }

  static Void deleteTable(SqlService db, Str tableName)
  {
    knownTables.remove(tableName)
    QueryManager.execute(db, "DROP TABLE $tableName" ,null, true)
  }

  static Void createTable(SqlService db, DBModelMapping mapping)
  {
    mapping.getCreateTableSql.each
    {
      QueryManager.execute(db, it ,null, true)
    }
  }
}