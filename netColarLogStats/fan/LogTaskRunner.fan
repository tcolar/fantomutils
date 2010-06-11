// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 10, 2010 thibautc Creation
//
using sql
using netColarDb

** Task Processor mxin
mixin LogProcessor
{
	** Called before the first log line is processed
	virtual Void init(LogTask task) {}
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
	ParsedLine? lastProcessed
	DateTime now := DateTime.now

	new make(LogTask task)
	{
		this.task = task;
	}

	** Run the task
	Void run(SqlService db)
	{
		LogProcessor? processor
		switch(task.type)
		{
			case TaskType.COUNT:
				processor = CountingProcessor()
			default:
				throw Err("Unexpected processor type: $task.type")
		}
		processor.init(task)
		query := SelectQuery(LogFile#).where(QueryCond("server", SqlComp.EQUAL, task.serverId))
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
							if(lastProcessed?.timestamp > parsed.timestamp)
							throw Err("Log data is not ordered properly!\nPrev line: $lastProcessed\nCur line: $parsed")
							lastProcessed = parsed
							// process it
							processor.processLine(parsed)
						}
						catch(ArgErr e)
						{
							echo("Failed to parse: $line")
						}
					}
					i++
				}
			}
		}
		processor.completed
	}
}

** Implementation of counter (just count requests)
class CountingProcessor : LogProcessor
{
	LogTask? task
	Int cpt

	override Void init(LogTask task) {this.task = task}

	** Called for each relevant log line to be processed
	override Void processLine(ParsedLine? line)
	{
	}

	** Called after all lines processed
	override Void completed()
	{
		// TODO: Store / persist computed data
	}
}