// Artistic License 2.0
// History:
//   Jun 18, 2010 thibautc Creation
//
using netColarDb
using sql

**
** Enum of available queries
enum class LogQuery
{
	curMonthHits(LogStatQuery("Current Month Daily Hits", LogStatQuery#thisMonthDailyHits.qname, "TIME", "VALUE", LogStatQuery.dayFormater)),
	monthHits(LogStatQuery("Daily hits for specified Year/Month", LogStatQuery#monthDailyHits.qname, "TIME", "VALUE", LogStatQuery.dayFormater)),
	curMonthPageHits(LogStatQuery("Curent month Hits per individual page", LogStatQuery#thisMonthTopPages.qname, "UNIQUE_ITEM", "VALUE", LogStatQuery.pageNameFormater)),
	monthPageHits(LogStatQuery("Individual page hits for specified Year/Month", LogStatQuery#monthTopPages.qname, "UNIQUE_ITEM", "VALUE", LogStatQuery.pageNameFormater))

	private new make(LogStatQuery query) { this.query = query; }

	const LogStatQuery query;
}

**
** Query descriptor
const class LogStatQuery
{
	const Str desc
	const Str method
	const Str[] paramTypes
	const Str keyCol
	const Str valCol
	const |Str, SqlService -> Str|? keyFormater

	** queryMethod is a static method defined in LogStatQueries
	new make(Str desc, Str queryMethod, Str keyCol, Str valCol, |Str, SqlService -> Str|? keyFormater := null)
	{
		this.method = queryMethod
		this.desc = desc
		this.keyCol = keyCol
		this.valCol = valCol
		this.keyFormater = keyFormater
		Str[] pt := [,]
		m := Slot.findMethod(method, false)
		m?.params?.each { pt.add(it.type.qname) }
		paramTypes = pt.dup
	}
	// Pre made queries
  static SelectQuery thisMonthDailyHits()
  {
	now := DateTime.now
	return monthDailyHits(now.year, now.month.ordinal + 1)
  }

  ** month: 1 = january
  static SelectQuery monthDailyHits(Int year, Int month)
  {
	Month m := Month.vals[month-1]
	start := DateTime(year, m, 1, 0, 0)
	end := DateTime(year, m.increment , 1, 0, 0)
	return counterQuery(1, "Hits", TaskGranularity.DAY, start, end)
  }

  static SelectQuery thisMonthTopPages()
  {
	now := DateTime.now
	return monthTopPages(now.year, now.month.ordinal + 1)
  }

  ** month: 1 = january
  static SelectQuery monthTopPages(Int year, Int month)
  {
	Month m := Month.vals[month-1]
	start := DateTime(year, m, 1, 0, 0)
	end := DateTime(year, m.increment , 1, 0, 0)
	return counterQuery(1, "PageHits", TaskGranularity.MONTH, start, end)
  }

  internal static SelectQuery counterQuery(Int serverId, Str counterName, TaskGranularity gran, DateTime? start:=null, DateTime? end:=null)
  {
	query := SelectQuery(LogStatRecord#).where(QueryCond("server", SqlComp.EQUAL, serverId))
					.where(QueryCond("task_span", SqlComp.EQUAL, gran.name))
					.where(QueryCond("task_name", SqlComp.EQUAL, counterName))
	if(start!=null)
		query = query.where(QueryCond("time", SqlComp.GREATER_OR_EQ, start.toLocale("YYYY-MM-DD hh:mm:ss")))
	if(end!=null)
		query = query.where(QueryCond("time", SqlComp.LOWER, end.toLocale("YYYY-MM-DD hh:mm:ss")))
	return query.orderBy("time")
  }

	// TODO: keyFormater ??
	** Helper to fetch the data for a query
	static LogDataTableModel fetchData(SqlService db, LogQueryRequest req)
	{
		logQuery := LogQuery.fromStr(req.key)
		Obj[] params := [,]
		Str[] paramTypes := logQuery.query.paramTypes
		cpt := 0
		req.vals.each
		{
			p := Type.find(paramTypes[cpt]).method("fromStr").call(it)
			params.add(p);
			cpt++
		}

		m := Method.findMethod(logQuery.query.method)
		SelectQuery query := m.callList(params)
		echo("sql: $query.sql with $query.params")
		rows := query.run(db)
		model := LogDataTableModel {title = logQuery.query.desc}
		LogDataTableModelHelper.injectRows(db, model, rows, logQuery.query.keyCol, logQuery.query.valCol, logQuery.query.keyFormater)
		return model
	}

	static const |Str, SqlService db->Str| pageNameFormater := |Str s, SqlService db->Str| {LogPage? page := LogPage.findById(db, LogPage#, s.toInt); return page?.path}
	static const |Str, SqlService db->Str| dayFormater := |Str s, SqlService db->Str| {DateTime.fromStr(s).day.toStr}
}

// #### Lightweight Objects used by the frontend ####

** Predefined query descriptor that will be sent to frontend
@Js
@Serializable
const class LogQueryDescriptor
{
	const Str key
	const LogQueryParam[] params
	new make(Str logQueryKey, LogQueryParam[] params) {key = logQueryKey ; this.params = params}
}

** Predefined query expected parameter
@Js
@Serializable
const class LogQueryParam
{
	const Type type
	const Str desc
	new make(Type t, Str desc) {type = t ; this.desc = desc}
}

** Object sent by frontend to request a query
** Custom serialization as JS impl. does not support buf.writeObj yet
@Js
@Serializable {simple = true}
class LogQueryRequest
{
	const Str key
	const Str[] vals
	new make(Str logQueryKey, Str[] paramVals) {vals = paramVals ; key = logQueryKey}

	override Str toStr()
	{
		// Note: Was using Buf .. but doesn't seem to be avail in Js
		s := "${key};"
		vals.each {s += "${it};"}
		return s
	}

	static LogQueryRequest fromStr(Str s)
	{
		a := s.split(';')
		return LogQueryRequest(a[0], a[1..-2]) // trailing ;
	}
}


