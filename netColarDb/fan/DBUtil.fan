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
  static Str[] knownTables := [,]

  ** Normalize from Camel case (Fantom Type) into db friendly format : lower case, underscore separated
  ** Examples: "userSettings" -> "user_settings"
  static Str normalizeDBName(Str name)
  {
    norm := StrBuf()
    name.each |Int c|
    {
      if((c >= 'a' && c<='z') || (c >= '0' && c<='9'))
        norm.add(c)
      else if(c >= 'A' && c <= 'Z')
      {
        if( ! norm.isEmpty && norm[norm.size-1] >= 'a' && norm[norm.size-1] <= 'z')
          norm.add('_')
        norm.add(c.lower)
      }
      else
        norm.add('_')
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
    db.sql("DROP TABLE $tableName").execute
  }

  static Void createTable(SqlService db, DBModelMapping mapping)
  {
    mapping.getCreateTableSql.each
    {
      db.sql(it).execute
    }
  }
}