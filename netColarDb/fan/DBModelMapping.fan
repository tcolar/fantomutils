// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//
using sql

**
** DBModelMapping
**
const class DBModelMapping
{
  final Str name
  final Str dbName
  final TableModel? tableModel
  final FieldMapping[] fields := [,]

  new make(SqlService db, Type model)
  {
    if( ! model.fits(DBModel#))
      throw ArgErr("Model has to be of type DBModel")

    name = model.name
    tableModel = model.facet(TableModel#, false)

    dbName = tableModel?.name
    dbName ?: DBUtil.normalizeDBName(name)

    model.fields.each |Field f|
    {
      if( ! f.hasFacet(Transient#))
        fields.add(FieldMapping(f))
    }

    if(! DBUtil.tableExists(db, dbName))
    {
      if(tableModel == null || tableModel.autoCreate)
        DBUtil.createTable(db, dbName, this)
      else
        throw Err("Database $dbName does not exist and autocreate is turned off")
    }

    // TODO: Need to check against in DB schema, if mismatch -> Fail
    // TODO: ... or try to alter as needed on the fly
  }

  once Str[] getCreateTableSql()
  {
    Str columns := ""
    fields.each
    {
      Str Size :=  it.dbSize != null ? "($it.dbSize)" : ""
      columns += "${it.dbName} ${it.dbType}${it.dbSize} ,"
    }
    Str[] sql := [,]
    sql.add("CREATE TABLE $dbname (${column}))
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

enum class FieldType
{
  VARCHAR, BIT, BIGINT, FLOAT, DOUBLE, DATE, TIME, TIMESTAMP
}

const class FieldMapping
{
  final Str name
  final Str dbName
  final FieldModel? fieldModel
  final Str dbType
  final Int dbSize

  new make(Field f)
  {
    name = f.name
    fieldModel = f.facet(FieldModel#, false)
    dbName = fieldModel?.name
    dbName ?: DBUtil.normalizeDBName(name)
    dbType := getFieldType(f).name
    dbSize = fieldModel?.size
    dbSize ?: 80 // default
  }

  static FieldType getFieldType(Field f)
  {
    // TODO: allow DBModel childs ?
    switch(f.typeof)
    {
      case Bool#:     return FieldType.BIT
      case Int#:      return FieldType.BIGINT
      case Float#:    return FieldType.FLOAT
      case Decimal#:  return FieldType.DOUBLE
      case Str#:      return FieldType.VARCHAR
      case Uri#:      return FieldType.VARCHAR
      case Duration#: return FieldType.VARCHAR
      case Date#:     return FieldType.DATE
      case Time#:     return FieldType.TIME
      case DateTime#: return FieldType.TIMESTAMP
      // TODO: Serialize any other types ?
      //default:        return FieldType.TEXT CLOB ? VarChar ?
    }
  }
}