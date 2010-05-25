// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//
using sql

enum class DBComp
{
    EQUAL, NOT_EQUAL, GREATER, LOWER, GREATER_OR_EQ, LOWER_OR_EQ, LIKE
}
/*
abstract class QueryItem
{
  QueryArg[] args := [,]
  Str[]? orderBy
  Int? limit

  Void and(Str key, DBComp comp, Str val)
  {

  }

  Void or(Str key, DBComp comp, Str val)
  {

  }

  Void orderBy(Str order, Bool Ascend){}

  Void limit(Int size) {}

}
*/
class QueryCond
{
  Str field
  DBComp comp
  Obj val

  new make(Str field, DBComp comp, Str val)
  {
    this.field=field
    this.comp=comp
    this.val=val
  }

  Str getSQLComparator()
  {
    Str s := " = ?";
	switch(comp)
	{
		case GREATER:
             s=" > ?"
		case GREATER_OR_EQ:
             s=" >= ?"
		case LOWER:
             s=" < ?"
		case LOWER_OR_EQ:
             s=" <= ?"
		case LIKE:
             s=" like ?"
		case NOT_EQUAL:
             s=" <> ?"
	}
	return s;
  }

  once Str getSquelStr()
  {
    "$field $getCompStr ";
  }
}

abstract class QueryBase
{
  Str sql := ""
  Int nbWhere := 0;
  Obj[] params := [,]

  This appendToSql(Str sql)
  {
    this.sql += sql
  }
}

class SelectQuery : QueryBase
{
  new make(Type dbModel, Str selectWhat := "*")
  {
    // TODO: Facet specified table name ?
    Str tablename := DBUtil.normalizeDBName(dbModel.name)
    appendToSql("SELECT $selectWhat FROM $tableName ");
  }

  /*SelectQuery limit(Int limit)
  {
    appendToSql("LIMIT $limit ")
  }*/

  This orderBy(Str orderBy, Bool ascending := true)
  {
    appendToSql("ORDER BY $orderBy ");
  }

  This whereSql(Str sql)
  {
    appendToSql((nbWhere == 0 ? "WHERE " : "AND ") + sql);
    nbWhere++;
    return this;
  }

  This orWhereSql(Str sql)
  {
    appendToSql((nbWhere == 0 ? "WHERE " : "OR ") + sql);
    nbWhere++;
    return this;
  }

  This where(QueryCond cond)
  {
    params.add(cond.val);
    return where(cond.getSquelStr);
  }

  This orWhere(QueryCond cond)
  {
    params.add(cond.val);
    return orWhere(cond.getSquelStr);
  }

  Row[] find(SqlService db)
  {
    QueryManager.execute(db, sql, params, false)
  }
}

class QueryManager
{
  static Row[] execute(SqlService db, Str squeleton, [Str:Obj]? params, Bool isUpdate)
  {
    Rows[]? rows
    stmt := db.sql.prepare
    if(isUpdate)
      stmt.execute(params)
    else
      rows = stmt.query(params)
    return rows
  }
}