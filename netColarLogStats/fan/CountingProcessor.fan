// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 14, 2010 thibautc Creation
//

using sql
using netColarDb

**
** CountingProcessor
** Implementation of counter processor (just count request totals)
**
class CountingProcessor : LogProcessor
{
	LogTask? task
	SqlService? db
	// Stores counter values
	DateTime:Int hCounters := [:] // hourly totals
	DateTime:Int dCounters := [:] // dayly totals
	DateTime:Int mCounters := [:] // monthly totals
	DateTime:Int yCounters := [:] // yearly totals

	override Void init(LogTask task, SqlService db) {this.task = task; this.db = db}

	** Called for each relevant log line to be processed
	override Void processLine(ParsedLine? line)
	{
		ts := line.timestamp
		// store / update the hourly counters
		hour := ts.floor(1hr)
		hCounters.set(hour, hCounters.get(hour, 0) + 1)
		day := DateTime(ts.year, ts.month, ts.day, 0, 0)
		dCounters.set(day, dCounters.get(day, 0) + 1)
		month := DateTime(ts.year, ts.month, 1, 0, 0)
		mCounters.set(month, mCounters.get(month, 0) + 1)
		year := DateTime(ts.year, Month.jan, 1, 0, 0)
		yCounters.set(year, yCounters.get(year, 0) + 1)
	}

	** Called after all lines processed
	override Void completed()
	{
		// Store computed data
		hCounters.each |Int cpt, DateTime dt|
		{
			updateCpt(task, db, dt, cpt, TaskGranularity.HOUR)
		}
		dCounters.each |Int cpt, DateTime dt|
		{
			updateCpt(task, db, dt, cpt, TaskGranularity.DAY)
		}
		mCounters.each |Int cpt, DateTime dt|
		{
			updateCpt(task, db, dt, cpt, TaskGranularity.MONTH)
		}
		yCounters.each |Int cpt, DateTime dt|
		{
			updateCpt(task, db, dt, cpt, TaskGranularity.YEAR)
		}
	}

	internal Void updateCpt(LogTask task, SqlService db, DateTime dt, Int cpt, TaskGranularity span)
	{
		query := SelectQuery(LogStatRecord#).where(QueryCond("server", SqlComp.EQUAL, task.serverId))
					.where(QueryCond("time", SqlComp.EQUAL, dt))
					.where(QueryCond("task_span", SqlComp.EQUAL, span.name))
					.where(QueryCond("task_name", SqlComp.EQUAL, task.uniqueName))
		LogStatRecord record := LogStatRecord.findOrCreateOne(db, query)
		record.server = task.serverId
		record.time =  dt
		record.taskSpan = span.name
		record.taskName = task.uniqueName
		record.value = record.value + cpt
		record.save(db)
	}
}