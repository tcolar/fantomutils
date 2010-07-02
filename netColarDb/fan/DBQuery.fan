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
class SelectQuery : ConditionalQuery
{
  Type objType

  new make(Type objType, Str selectWhat := "*")
  {
    this.objType = objType;
    Str tableName := DBUtil.normalizeDBName(objType.name)
    appendToSql("SELECT $selectWhat FROM $tableName ");
  }

  SelectQuery setLimit(Int limit)
  {// TODO: limit
    this.limit = limit
	return this
  }

  ** Add an orderBy statement to the query
  This orderBy(Str orderBy, Bool ascending := true)
  {
    appendToSql("ORDER BY $orderBy ").appendToSql(ascending?"":"DESC ");
  }

  ** Build a 'by ID' select query (findById)
  static SelectQuery byId(Type objType, Int id)
  {
    make(objType).where(QueryCond("id", SqlComp.EQUAL, id))
  }
}

** Delete query builder
class DeleteQuery : ConditionalQuery
{
  new make(Type objType)
  {
    expectResults = false
    Str tableName := DBUtil.normalizeDBName(objType.name)
    appendToSql("DELETE FROM $tableName ");
  }
}

** Insert query builder
** Values is a map of dbColumnName:Value to be inserted
class InsertQuery : QueryBase
{

  new make(Type objType, Str:Obj? values)
  {
    expectResults = false
    Str tableName := DBUtil.normalizeDBName(objType.name)
    colStr := StrBuf()
    valStr := StrBuf()
    values.each |val, key|
    {
      if(colStr.size > 0)
        colStr.add(", ")
      colStr.add(key)
      if(valStr.size > 0)
        valStr.add(", ")
      valStr.add("@$getNextParamName")
      params.set(getNextParamName, val)
    }
    appendToSql("INSERT INTO $tableName ($colStr.toStr) VALUES($valStr.toStr) ");
  }
}

** Insert query builder
** Values is a map of dbColumnName:Value to be updated
class UpdateQuery : ConditionalQuery
{

  new make(Type objType, Str:Obj? values)
  {
    expectResults = false
    Str tableName := DBUtil.normalizeDBName(objType.name)
    setStr := StrBuf()
    values.each |val, key|
    {
      if(setStr.size > 0)
        setStr.add(", ")
      setStr.add("${key}=@${getNextParamName}")
      params.set(getNextParamName, val)
    }
    appendToSql("UPDATE $tableName SET $setStr.toStr ");
  }
}

** Base for queries that take conditions (where)
abstract class ConditionalQuery : QueryBase
{
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

  ** Add a where clause to the query (WHERE / AND WHERE)
  This where(QueryCond cond)
  {
    sql := cond.getSquelStr("@$getNextParamName")
    params.set(getNextParamName, cond.val)
    return whereSql(sql);
  }

  ** Add a where clause to the query (OR WHERE)
  This orWhere(QueryCond cond)
  {
    sql := cond.getSquelStr("@$getNextParamName")
    params.set(getNextParamName, cond.val)
    return orWhereSql(sql);
  }
}

** Base of all query builders
abstract class QueryBase
{
  StrBuf sql := StrBuf()
  Int nbWhere := 0;
  [Str:Obj]? params := [:]
  Bool expectResults := true
  Int? limit

  ** Appends "raw" sql to the query being built, preferably not to be used directly
  This appendToSql(Str s)
  {
    sql.add(s)
    return this
  }

  internal Str getNextParamName()
  {
    sz := params.size+1
    return "p${sz}"
  }

  ** Run the query
  Row[] run(SqlService db)
  {
    QueryManager.executeQuery(db, this)
  }

}


** A query condition such as "name EQUAL 'john'"
class QueryCond
{
  Str field
  SqlComp comp
  Obj? val

  new make(Str field, SqlComp comp, Obj? val)
  {
    this.field=field
    this.comp=comp
    this.val=val
  }

  ** Return the Comparator (Enum) as an SQL comparator
  internal Str getSQLComparator()
  {
    Str s := "=";
	switch(comp)
	{
		case SqlComp.GREATER:
             s=">"
		case SqlComp.GREATER_OR_EQ:
             s=">="
		case SqlComp.LOWER:
             s="<"
		case SqlComp.LOWER_OR_EQ:
             s="<="
		case SqlComp.LIKE:
             s="like"
		case SqlComp.NOT_EQUAL:
             s="<>"
	}
	return s;
  }

  ** Return The condition as an SQL squeleton (ex: "age >= ?")
  internal Str getSquelStr(Str paramName)
  {
    return "$field $getSQLComparator $paramName ";
  }
}

** Handles database queries
class QueryManager
{
  ** Execute a query usinf Fantom's SQL Api's
  static Row[] executeQuery(SqlService db, QueryBase query)
  {
    Row[] rows := [,]
	// echo Takes forever ... not sure why
    // echo("Will execute: '${squeleton}' with : $params")
    stmt := db.sql(query.sql.toStr)
	if(query.limit != null)
	{	// Note: This needs to be done before prepare()
		stmt.limit = query.limit
		echo("setting limit to: $stmt.limit")
	}
	stmt.prepare()
    if( ! query.expectResults)
      stmt.execute(query.params)
    else
      rows = stmt.query(query.params)
    return rows
  }

  ** Execute a "manual" SQL query
  static Row[] execute(SqlService db, Str sqlSquel, [Str:Obj]? params, Bool isUpdate)
  {
    Row[] rows := [,]
    stmt := db.sql(sqlSquel).prepare()
    if( isUpdate )
      stmt.execute(params)
    else
      rows = stmt.query(params)
    return rows
  }
}

