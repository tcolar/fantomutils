// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//
using sql

**
** DBModelMapping
** Holds the mapping between a DBModel fields and the corresponding DB Table
**
const class DBModelMapping
{
  const Str name
  const Str dbName
  const TableModel? tableModel
  const FieldMapping[] fields := [,]

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
        DBUtil.createTable(db, this)
      else
        throw Err("Database $dbName does not exist and autocreate is turned off")
    }

    // TODO: Need to check against in DB schema, if mismatch -> Fail
    // TODO: ... or try to alter as needed on the fly
  }

  ** Returns the SQL commands to create the Table associated with this mapping
  Str[] getCreateTableSql()
  {
    columns := StrBuf()
    Str? pKey := DBUtil.normalizeDBName(tableModel?.primaryKey?.name)
    pKey ?: DBUtil.normalizeDBName("id")
    fields.each
    {
      //Str size :=  it.dbSize != null ? "($it.dbSize)" : ""
      Str notNull := it.nullable ? "" : "NOT NULL"
      columns.add("${it.dbName} ${it.dbType} ${notNull},")
    }
    Str[] sql := [,]
    sql.add("CREATE TABLE $dbName (${columns.toStr})")
    sql.add("ALTER TABLE $dbName ADD PRIMARY KEY (${pKey})")
    fields.each
    {
      if(it.fieldModel?.indexIt)
      {
        indexName := "IDX_${this.dbName}_${it.dbName}"
        sql.add("CREATE UNIQUE INDEX $indexName ON ${this.dbName} (${it.dbName})")
      }
    }
    return sql
  }
}

** Database Column Types enum
enum class FieldType
{
  VARCHAR, BIT, BIGINT, FLOAT, DOUBLE, DATE, TIME, TIMESTAMP, NA
}

** Mapping for a single Field (to a table column)
const class FieldMapping
{
  const Str name
  const Str dbName
  const FieldModel? fieldModel
  const Str dbType
  //final Int dbSize
  const Bool nullable

  new make(Field f)
  {
    name = f.name
    nullable = f.typeof.isNullable
    fieldModel = f.facet(FieldModel#, false)
    dbName = fieldModel?.name
    dbName ?: DBUtil.normalizeDBName(name)
    dbType := getFieldType(f).name
    //dbSize = fieldModel?.size
    // Default size (for varchar)
    //dbSize ?: 80
  }

  ** Get the proper DB column type equivalent for the given Fantom field
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
    return FieldType.NA;
  }
}
