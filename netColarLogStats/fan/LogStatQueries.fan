// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 18, 2010 thibautc Creation
//
using netColarDb

**
** LogStatQueries
**
class LogStatQueries
{
  static SelectQuery ThisMonthDailyHits()
  {
	now := DateTime.now
	start := DateTime(now.year, now.month, 0, 0, 0)
	end := DateTime(now.year, now.month.increment , 0, 0, 0)
	return counterQuery(1, "counter", TaskGranularity.MONTH, start, end)
  }

  internal static SelectQuery counterQuery(Int serverId, Str counterName, TaskGranularity gran, DateTime? start:=null, DateTime? end:=null)
  {
	query := SelectQuery(LogStatRecord#).where(QueryCond("server", SqlComp.EQUAL, serverId))
					.where(QueryCond("task_span", SqlComp.EQUAL, gran))
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