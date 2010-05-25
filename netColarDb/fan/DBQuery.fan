// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//
using sql

** SQL comparators used to create QueryConditions
enum class SqlComp
{
    EQUAL, NOT_EQUAL, GREATER, LOWER, GREATER_OR_EQ, LOWER_OR_EQ, LIKE
}

** SQL Select query builder
** Note: Methods need to be called in the correct Sql order.
class SelectQuery : QueryBase
{
  new make(Type dbModel, Str selectWhat := "*")
  {
    Str tableName := DBUtil.normalizeDBName(dbModel.name)
    appendToSql("SELECT $selectWhat FROM $tableName ");
  }

  /*SelectQuery limit(Int limit)
  {// TODO: limit
    appendToSql("LIMIT $limit ")
  }*/

  ** Add an orderBy statement to the query
  This orderBy(Str orderBy, Bool ascending := true)
  {
    appendToSql("ORDER BY $orderBy ");
  }

  ** Add a where clause to the query (WHERE / AND WHERE)
  This where(QueryCond cond)
  {
    params.add(cond.val);
    return whereSql(cond.getSquelStr);
  }

  ** Add a where clause to the query (OR WHERE)
  This orWhere(QueryCond cond)
  {
    params.add(cond.val);
    return orWhereSql(cond.getSquelStr);
  }

  ** Run the query and returns matching rows
  Row[] find(SqlService db)
  {
    QueryManager.execute(db, sql.toStr, params, false)
  }

  ** Add a where clause to the query (WHERE / AND WHERE)
  internal This whereSql(Str sql)
  {
    appendToSql((nbWhere == 0 ? "WHERE " : "AND ") + sql);
    nbWhere++;
    return this;
  }

  ** Add a where clause to the query (OR WHERE)
  internal This orWhereSql(Str sql)
  {
    appendToSql((nbWhere == 0 ? "WHERE " : "OR ") + sql);
    nbWhere++;
    return this;
  }

}

** Base of all query builders
abstract class QueryBase
{
  StrBuf sql := StrBuf()
  Int nbWhere := 0;
  Obj[]? params := [,]

  ** Appends "raw" sql to the query being built, preferably not to be used directly
  This appendToSql(Str s)
  {
    sql.add(s)
    return this
  }
}


** A query condition such as "name EQUAL 'john'"
class QueryCond
{
  Str field
  SqlComp comp
  Obj val

  new make(Str field, SqlComp comp, Str val)
  {
    this.field=field
    this.comp=comp
    this.val=val
  }

  ** Return the Comparator (Enum) as an SQL query squeleton (ex: "= ?")
  internal Str getSQLComparator()
  {
    Str s := " = ?";
	switch(comp)
	{
		case SqlComp.GREATER:
             s=" > ?"
		case SqlComp.GREATER_OR_EQ:
             s=" >= ?"
		case SqlComp.LOWER:
             s=" < ?"
		case SqlComp.LOWER_OR_EQ:
             s=" <= ?"
		case SqlComp.LIKE:
             s=" like ?"
		case SqlComp.NOT_EQUAL:
             s=" <> ?"
	}
	return s;
  }

  ** Return The condition as an SQL squeleton (ex: "age >= ?")
  internal once Str getSquelStr()
  {
    "$field $getSQLComparator ";
  }
}

** Handles database queries
class QueryManager
{
  ** Execute a query usinf Fantom's SQL Api's
  static Row[] execute(SqlService db, Str squeleton, [Str:Obj]? params, Bool isUpdate)
  {
    Row[]? rows
    stmt := db.sql.prepare
    if(isUpdate)
      stmt.execute(params)
    else
      rows = stmt.query(params)
    return rows
  }
}

