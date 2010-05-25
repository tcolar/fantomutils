// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//

using sql
**
** DBUtil
**
class DBUtil
{
  ** "Cache" Of known table names, since lookup is expensive
  static Str[] knownTables := [,]

  static Str normalizeDBName(Str name)
  {
		/*StringBuffer newName = new StringBuffer();
		for (int i = 0; i != name.length(); i++)
		{
			char c = name.charAt(i);
			if (c >= 'a' && c <= 'z')
			{
				newName.append(c);
			} else if (c >= 'A' && c <= 'Z')
			{
				// Camel case transaformed to _  EX: userTable -> user_table
				String lower = ("" + new Character(c)).toLowerCase();
				if (newName.length() > 0 && name.charAt(i - 1) >= 'a' && name.charAt(i - 1) <= 'z')
				{
					newName.append("_");
				}
				newName.append(lower);
			} else
			{
				// everyhting not letters is gonna be _
				newName.append("_");
			}
		}
		JOTLogger.debug(JOTLogger.CAT_DB, JOTModelMapping.class, "Table name for: '" + name + "' : '" + newName.toString().toUpperCase() + "'");
		return newName.toString().toUpperCase();
	}*/
  }
  
  static Bool tableExists(SqlService db, Str tableName)
  {
      if(knownTables.contains(tableName))
        return true;
      Bool exists := db.tableExists(tableName)
      if(exists) knownTables.add(tableName)
      return exists
  }

  static Bool deleteTable(SqlService db, Str tableName)
  {
    knownTables.remove(tableName)
    db.sql("DROP TABLE $tableName").execute
  }

  static Bool createTable(SqlService db, Str tableName, DBModelMapping mapping)
  {
    //db.sql(mapping.getTableCreateCmd).execute
					/*JOTDBManager.getInstance().update(con, "CREATE TABLE " + mapping.getTableName() + "(" + columns + ")");
					JOTDBManager.getInstance().update(con, "ALTER TABLE " + mapping.getTableName() + " ADD PRIMARY KEY (" + "ID" + ")");
					Vector indexes = mapping.getIndexes();
					for (int i = 0; i != indexes.size(); i++)
					{
						String column = (String) indexes.get(i);
						String indexName = "IDX_" + mapping.getTableName() + "_" + column;
						JOTDBManager.getInstance().update(con, "CREATE UNIQUE INDEX " + indexName + " ON " + mapping.getTableName() + " (" + column + ")");
					}
                    JOTModelMapping.writeMetaFile(mapping);
        */

  }
}