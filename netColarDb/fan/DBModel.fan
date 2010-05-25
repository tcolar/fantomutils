// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//

using sql

**
** DBModel
**
abstract class DBModel
{
  ** Default primaryKey, unless other specified with TableModel
  Int id := -1 // -1 means new

  new make() {}

  new makeFromRow(Row row)
  {
    mapping := getMapping(this)
    mapping.fields.each |FieldMapping fm|
    {
      Field? field := this.typeof.field(fm.name, false)
      field?.set(this, row.get(fm.dbName))
    }
  }

  Void save()
  {
    //db.sql("DELETE FROM @COL WHERE ID = @ID", ["TBL": name, "ID":id])

  }

  Void delete()
  {
    //db.sql("DELETE FROM @COL WHERE ID = @ID", ["TBL": name, "ID":id])
    id = -1
  }

  static This findOne(SqlService db, SelectQuery query)
  {
    Row[] rows := query.find(db)
    if(rows.size == 0)
      return null
    return rows[0] as This
  }

  static This findByID(SqlService db, Int id)
  {
    query := SelectQuery(This).where(QueryCond("ID", DBComp.EQUAL, id))
    return findOne(db, query)
  }


  static This findOrCreateOne(SqlService db, SelectQuery query)
  {
    Row[] rows := query.find(db)
    if(rows.size == 0)
      return make // create new one
    return rows[0] as This
  }


  static This[] findAll(SqlService db, SelectQuery query, Int limit := -1)
  {
    Row[] rows := query.find(db)
  }

  static once DBModelMapping getMapping(SqlService db, DBModel model)
  {
    DBModelMapping(db, model)
  }

}

