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
  const FieldMapping[] fields

  new make(SqlService db, Type model)
  {
    if( ! model.fits(DBModel#))
      throw ArgErr("Model has to be of type DBModel")

    name = model.name
    tableModel = model.facet(TableModel#, false)

    if(tableModel!=null)
    {
      dbName = tableModel?.name
    }
    else
    {
      dbName = DBUtil.normalizeDBName(name)
    }
    // use a temp list, because fields is a const, and alls to add on const lists results in a runtime exception
    tmpList := FieldMapping[,]
    model.fields.each |Field f|
    {
      if( ! f.hasFacet(Transient#))
        tmpList.add(FieldMapping(f))
    }
    fields = tmpList

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

  ** Return a map of the field values for the DBModel:  [dbName:Value]
  Str:Obj? getValues(DBModel model)
  {
    Str:Obj? values := [:]
    fields.each |FieldMapping fm|
    {
      Obj? value := model.typeof.field(fm.name, true).get(model)
      // fields to serialized
      if(fm.serialized)
        value = Buf().writeObj(value).flip.readAllStr
      // fields to convert with toStr
      else if(fm.fieldType == Duration# || fm.fieldType == Uri#)
        value = value.toStr
      values.set(fm.dbName, value)
    }
    return values
  }

  ** Returns the SQL commands to create the Table associated with this mapping
  Str[] getCreateTableSql()
  {
    columns := StrBuf()
    Str pKey := DBUtil.normalizeDBName(tableModel?.primaryKey?.name) ?: DBUtil.normalizeDBName("id")
    fields.each
    {
      Str size :=  it.dbSize.size > 0 ? "(${it.dbSize})" : ""
      Str notNull := it.nullable ? "" : "NOT NULL"
      if(columns.size>0)
        columns.add(", ")
      columns.add("${it.dbName} ${it.dbType}${size} ${notNull}")
    }
    Str[] sql := [,]
    sql.add("CREATE TABLE $dbName (${columns.toStr})")
    sql.add("ALTER TABLE $dbName ADD PRIMARY KEY (${pKey})")
    fields.each
    {
      if(it.fieldModel!=null && it.fieldModel.indexIt)
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
  VARCHAR, BIT, BIGINT, FLOAT, DECIMAL, DATE, TIME, TIMESTAMP, NA
}

** Mapping for a single Field (to a table column)
const class FieldMapping
{
  const Str name
  const Str dbName
  const FieldModel? fieldModel
  const Str dbType
  const Str dbSize
  const Type fieldType
  const Bool nullable
  const Bool serialized

  new make(Field f)
  {
    name = f.name
    fieldType = f.typeof
    nullable = fieldType.isNullable
    fieldModel = f.facet(FieldModel#, false)
    dbType = getDbType(f).name
    dbName = fieldModel?.name ?: DBUtil.normalizeDBName(name)
    dbSize = getFieldSize(f)
    serialized = f.hasFacet(SerializeField#)
  }

  ** Get the proper DB column type equivalent for the given Fantom field
  static FieldType getDbType(Field f)
  {
    if(f.hasFacet(SerializeField#))
      return FieldType.VARCHAR
    // TODO: allow DBModel childs ?
    switch(f.type)
    {
      case Bool#:     return FieldType.BIT
      case Int#:      return FieldType.BIGINT
      case Float#:    return FieldType.FLOAT
      case Decimal#:  return FieldType.DECIMAL
      case Str#:      return FieldType.VARCHAR
      case Uri#:      return FieldType.VARCHAR
      case Duration#: return FieldType.VARCHAR
      case Date#:     return FieldType.DATE
      case Time#:     return FieldType.TIME
      case DateTime#: return FieldType.TIMESTAMP
      
      default :       echo("Will not save field $f of type: $f.type")
    }
    return FieldType.NA;
  }

  ** Return the field length  -1(none) for any fields
  ** For Varchar defaults to 80, unless otherwise specified with FieldModel.size
  ** Fields marked with SerializeField are Varchar(2000)
  ** For Decimal it's "28,28"
  static Str getFieldSize(Field f)
  {
    if(f.hasFacet(SerializeField#))
      return "2000"

    FieldModel? model := f.facet(FieldModel#, false)
    Str sz := "80"
    if(model?.size > 0) sz = "$model.size"
    switch(f.type)
    {
      case Str#:      return sz
      case Uri#:      return sz
      case Duration#: return sz
      case Decimal#:  return "28,28"
    }
    return "";
  }
}
