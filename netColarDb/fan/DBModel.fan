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

  ** "Make"(load) the object a row in the matching database table.
  static DBModel loadFromRow(Row row)
  {
    DBModel instance := make
    mapping := getMapping(this)
    mapping.fields.each |FieldMapping fm|
    {
      Field? field := instance.typeof.field(fm.name, false)
      field?.set(instance, row.col(fm.dbName))
    }
    return instance
  }

  ** Save the object into the database
  Void save(SqlService db)
  {
    //db.sql("DELETE FROM @COL WHERE ID = @ID", ["TBL": name, "ID":id])
    //TODO
  }

  ** Delete the object from the database
  ** Note that if you saev a previously deleted object, it will create a brand new entry (with a new ID)
  Void delete(SqlService db)
  {
    //TODO
    //db.sql("DELETE FROM @COL WHERE ID = @ID", ["TBL": name, "ID":id])
    id = -1
  }

  ** Return the first match (if any) for the given query
  static DBModel? findOne(SqlService db, SelectQuery query)
  {
    Row[] rows := query.find(db)
    if(rows.size == 0)
      return null
    return loadFromRow(rows[0])
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
    Row[] rows := query.find(db)
    if( ! rows.isEmpty)
      return loadFromRow(rows[0])
    // Else, create a new one
    return make
  }

  ** Return a list of objects matching the given query
  static DBModel[] findAll(SqlService db, SelectQuery query, Int limit := -1)
  {
    // TODO: Deal with limit, once fantom sql supports it
    Row[] rows := query.find(db)
    DBModel[] objs := [,]
    rows.each { objs.add(loadFromRow(it)) }
    return objs
  }

  ** Get the mapping object for a given model.
  ** Note: this also validates the Table, and create it as needed etc...
  static DBModelMapping getMapping(SqlService db, Type modelType)
  {
    DBModelMapping(db, modelType)
  }

}

