// Artistic License 2.0
// History:
//   Jun 10, 2010 thibautc Creation
//
using sql
using netColarDb

** Task Processor mixin
mixin LogProcessor
{
	** Called before the first log line is processed
	virtual Void init(LogTask task, SqlService db) {}
	** Called for each relevant log line to be processed
	abstract Void processLine(ParsedLine? line)
	** Called after all lines processed
	virtual Void completed() {}
}

**
** LogTaskRunner: run a LogTask item
**
class LogTaskRunner
{
	LogTask task
	//ParsedLine? lastProcessed
	DateTime now := DateTime.now

	new make(LogTask task)
	{
		this.task = task;
	}

	** Run the task
	Void run(SqlService db)
	{
		LogProcessor? processor
		// TODO: Have the TaskType enum return the processor rather than this swicth here ?
		switch(task.type)
		{
			case TaskType.COUNT:
				processor = HitsProcessor()
			case TaskType.COUNT_UNIQUE:
				processor = PageHitsProcessor()
			default:
				throw Err("Unexpected processor type: $task.type")
		}
		processor.init(task, db)
		query := SelectQuery(LogFile#).where(QueryCond("server_id", SqlComp.EQUAL, task.serverId))
		logs := LogFile.findAll(db, query)
		// Order files from least recently modified to most recently modified
		logs.sort |LogFile a, LogFile b -> Int| {return a.timestamp.compare(b.timestamp)}
		// process files
		logs.each |LogFile log|
		{
			file := File(log.path)
			DateTime lastChg := file.modified
			if(lastChg > log.timestamp)
			{
				i := 0
				file.in.eachLine |Str line|
				{
					if(i > log.lastLineRead)
					{
						try
						{
							parsed := ParsedLine(line)
							// process it
							processor.processLine(parsed)
						}
						catch(ArgErr e)
						{
							echo("Failed to parse: $line $e")
						}
					}
					i++
				}
				// TODO: Update LogFile entry
			}
		}
		processor.completed
	}
}

