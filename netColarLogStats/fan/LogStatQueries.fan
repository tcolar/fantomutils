// Artistic License 2.0
// History:
//   Jun 18, 2010 thibautc Creation
//
using netColarDb
using sql

**
** Query descriptor
class LogStatQuery
{
	/*LogStatQuery[] allQueries := [
		LogStatQuery("This Month Daily Hits", LogStatQueries#thisMonthDailyHits),
	]*/

	Str desc
	Str method
	Str[] paramTypes := [,]

	new make(Str desc, Method queryMethod)
	{
		method = queryMethod.qname
		this.desc = desc
		queryMethod.params.each {paramTypes.add(it.type.qname)}
	}

	new makeFromSerial(Str desc, Str methodQname, Str[] paramTypes)
	{
		method = methodQname
		this.desc = desc
		this.paramTypes = paramTypes
	}

	** Simple de-serialization
	static LogStatQuery fromStr(Str s)
	{
		a := s.split(';')
		p := a[2].split(',')
		return LogStatQuery.makeFromSerial(a[0], a[1], p)
	}

	** Simple serialization
	override Str toStr()
	{
		p := paramTypes.join(",")
		d := desc.replace(";",",")
		return "$d,$method,$p"
	}

	// TODO: keyFormater ??
	// TODO: call params
	LogDataTableModel fetchData(SqlService db)
	{
		m := Slot.findMethod(method)
		SelectQuery query := m.callList([,])
		rows := query.run(db)
		model := LogDataTableModel {title = desc}
		LogDataTableModelHelper.injectRows(model, rows, "", "")
		return model
	}
}

**
** LogStatQueries
**
class LogStatQueries
{
  static SelectQuery thisMonthDailyHits()
  {
	now := DateTime.now
	start := DateTime(now.year, now.month, 1, 0, 0)
	end := DateTime(now.year, now.month.increment , 1, 0, 0)
	return counterQuery(1, "counter", TaskGranularity.MONTH, start, end)
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

/*
	rows := LogStatRecord.findAllRows(db, query)

	formater := |Str str -> Str| {DateTime.fromStr(str).day.toStr}
	model := LogDataTableModel(){it.title = "Daily Hits for 04 2007"}
	LogDataTableModelHelper.injectRows(model, rows, "time", "value", formater)
*/

}