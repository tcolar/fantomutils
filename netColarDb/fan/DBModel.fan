// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//

using sql

**
** DBModel
** This allows for persistance of the object using it
** Basic ORM functionality is provided
** A DBModel has a direct relationship to a database Table
**
class DBModel
{
  ** Default primaryKey, unless other specified with TableModel
  Int id := -1 // -1 means new

  ** "Make"(load) an object from a row in the matching database table.
  static DBModel loadFromRow(SqlService db, Type objType, Row row)
  {
    instance := objType.make
    mapping := getMapping(db, instance.typeof)
    mapping.fields.each |FieldMapping fm|
    {
      Field? field := instance.typeof.field(fm.name, false)
      Obj? val := row.get(row.col(fm.dbName))
      // fields that where serialized
      if(fm.serialized)
        val = (val as Str).in.readObj
      // fields that where converted with toStr
      else if(field.type == Duration# || field.type == Uri#)
        val = (field.type.slot("fromStr") as Method).call(val)
      field?.set(instance, val)
    }
    return instance
  }

  ** Save/Update the object into the database
  Void save(SqlService db)
  {
    mapping := getMapping(db, this.typeof)

    if(isNew)
    {
      id = DBUtil.nextVal(db, mapping.dbName)
      Str:Obj? values := mapping.getValues(this)
      // Create unique ID
      InsertQuery(this.typeof, values).run(db)
    }
    else
    {
      Str:Obj? values := mapping.getValues(this)
      UpdateQuery(this.typeof, values).where(QueryCond("id", SqlComp.EQUAL, id)).run(db)
    }
  }

  ** Delete the object from the database
  ** Note that if you save a previously deleted object, it will create a brand new entry (with a new ID)
  Void delete(SqlService db)
  {
    mapping := getMapping(db, this.typeof)
    DeleteQuery(this.typeof).where(QueryCond("id", SqlComp.EQUAL, id)).run(db)
    id = -1
  }

  ** Return the first match (if any) for the given query
  static DBModel? findOne(SqlService db, SelectQuery query)
  {
	// call to getMapping to create the table if needed
    getMapping(db, query.objType)
	Row[] rows := query.run(db)
    if(rows.size == 0)
      return null
    return loadFromRow(db, query.objType, rows[0])
  }

  //** Return the object for the given ID
  /*static This? findByID(SqlService db, Int id)
  {
    query := SelectQuery(this).where(QueryCond("ID", SqlComp.EQUAL, id))
    return findOne(db, query)
  }*/

  ** Return the first match (if any) for the given query
  ** If no match was found, then create a new object
  static DBModel findOrCreateOne(SqlService db, SelectQuery query)
  {
	// call to getMapping to create the table if needed
    getMapping(db, query.objType)
    Row[] rows := query.run(db)
    if( ! rows.isEmpty)
      return loadFromRow(db, query.objType, rows[0])
    // Else, create a new one
    return query.objType.make
  }

  static DBModel? findById(SqlService db, Type objType, Int id)
  {
    findOne(db, SelectQuery.byId(objType, id))
  }

  ** Return a list of objects matching the given query
  static DBModel[] findAll(SqlService db, SelectQuery query, Int limit := -1)
  {
	// call to getMapping to create the table if needed
    getMapping(db, query.objType)
    // TODO: Deal with limit, once fantom sql supports it
    Row[] rows := query.run(db)
    DBModel[] objs := [,]
    rows.each { objs.add(loadFromRow(db, query.objType, it)) }
    return objs
  }

  ** Get the mapping object for a given model.
  ** Note: this also validates the Table, and create it as needed etc...
  static DBModelMapping getMapping(SqlService db, Type objType)
  {
    DBModelMapping(db, objType)
  }

  ** Whether this is a new item (not in DB yet)
  Bool isNew()
  {
    id == -1
  }
}

