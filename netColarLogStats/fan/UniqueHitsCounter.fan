// Artistic License 2.0
// History:
//   Jun 25, 2010 thibautc Creation
//
using sql
using netColarDb

**
** UniqueCounter
** Count per unique Item
** For example hits for a specific url
**
abstract class UniqueHitsProcessor : LogProcessor
{
	LogTask? task
	SqlService? db
	// Stores counter values
	DateTime:UniqueHitVal hCounters := [:] // hourly totals per item
	DateTime:UniqueHitVal dCounters := [:] // dayly totals per item
	DateTime:UniqueHitVal mCounters := [:] // monthly totals per item
	DateTime:UniqueHitVal yCounters := [:] // yearly totals per item

	override Void init(LogTask task, SqlService db) {this.task = task; this.db = db}

	** Return the ID of the item we are counting (for example the unique ID of the URL)
	** <0 means do not store/count
	abstract Int getItemId(ParsedLine line)

	** Called for each relevant log line to be processed
	override Void processLine(ParsedLine? line)
	{
		if(line == null) return
		itemId := getItemId(line)
		if(itemId < 0) return
		ts := line.timestamp
		// store / update the hourly counters
		hour := ts.floor(1hr)
		incrementUniqueVal(hCounters, hour, itemId)
		day := DateTime(ts.year, ts.month, ts.day, 0, 0)
		incrementUniqueVal(dCounters, day, itemId)
		month := DateTime(ts.year, ts.month, 1, 0, 0)
		incrementUniqueVal(mCounters, month, itemId)
		year := DateTime(ts.year, Month.jan, 1, 0, 0)
		incrementUniqueVal(yCounters, year, itemId)
	}

	internal Void incrementUniqueVal(DateTime:UniqueHitVal counter, DateTime time, Int itemId)
	{
		UniqueHitVal hit := counter.containsKey(time) ? counter[time] : UniqueHitVal(itemId)
		hit.val++
		counter.set(time, hit)
	}

	** Called after all lines processed
	override Void completed()
	{
		// Store computed data
		hCounters.each |UniqueHitVal hit, DateTime dt|
		{
			updateCpt(task, db, dt, hit.itemId, hit.val, TaskGranularity.HOUR)
		}
		dCounters.each |UniqueHitVal hit, DateTime dt|
		{
			updateCpt(task, db, dt, hit.itemId, hit.val, TaskGranularity.DAY)
		}
		mCounters.each |UniqueHitVal hit, DateTime dt|
		{
			updateCpt(task, db, dt, hit.itemId, hit.val, TaskGranularity.MONTH)
		}
		yCounters.each |UniqueHitVal hit, DateTime dt|
		{
			updateCpt(task, db, dt, hit.itemId, hit.val, TaskGranularity.YEAR)
		}
	}

	internal Void updateCpt(LogTask task, SqlService db, DateTime dt, Int itemId, Int cpt, TaskGranularity span)
	{
		query := SelectQuery(LogStatRecord#).where(QueryCond("server", SqlComp.EQUAL, task.serverId))
					.where(QueryCond("time", SqlComp.EQUAL, dt))
					.where(QueryCond("task_span", SqlComp.EQUAL, span.name))
					.where(QueryCond("task_name", SqlComp.EQUAL, task.uniqueName))
					.where(QueryCond("unique_item", SqlComp.EQUAL, itemId))
		LogStatRecord record := LogStatRecord.findOrCreateOne(db, query)
		record.server = task.serverId
		record.time =  dt
		record.taskSpan = span.name
		record.taskName = task.uniqueName
		record.value = record.value + cpt
		record.uniqueItem = itemId
		record.save(db)
	}
}

** Stores a unique item ciurrent counter value
class UniqueHitVal
{
	Int val := 0
	Int itemId
	new make(Int itemId) {this.itemId=itemId}
}

** Implementation to count by unique Page path
class PageHitsProcessor : UniqueHitsProcessor
{
	override Int getItemId(ParsedLine line)
	{
		// TODO: not count if 404 ?
		// TODO : only count pages (no extension, or .htm .html, .php, .jsp, .asp, .aspx etc...)
		query := SelectQuery(LogPage#).where(QueryCond("path", SqlComp.EQUAL, line.page))
		LogPage page := LogPage.findOrCreateOne(db, query)
		if(page.isNew)
		{
			page.path = line.page
			page.save(db)
		}
		return page.id
	}
}