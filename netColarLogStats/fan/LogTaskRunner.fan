// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 10, 2010 thibautc Creation
//

**
** LogTaskRunner
**
class LogTaskRunner
{
	LogTask task
	ParsedLine? lastProcessed

	new make(LogTask task)
	{
		this.task = task;
	}

	Void run(LogSource[] logs)
	{
		// Order files from least recently modified to most recently modified
		logs.sort |LogSource a, LogSource b -> Int| {return a.timestamp.compare(b.timestamp)}
		// process files
		logs.each |LogSource log|
		{
			file := File(log.path)
			DateTime lastChg := file.modified
			//TODO: check md5 too ?
			if(lastChg > log.timestamp)
			{
				i := 0
				file.in.eachLine |Str line|
				{
					if(i > log.lastLineRead)
						processLine( ParsedLine(line) )
					i++
				}
			}
		}
		// TODO: apply limiter (for count_unique etc...)??
		// TODO: Store / persist computed data
	}

	Void processLine(ParsedLine line)
	{		
		if(line == null) return // Not parseable line
		if(lastProcessed?.timestamp > line.timestamp)
			throw Err("Log data is not ordered properly!\nPrev line: $lastProcessed\nCur line: $line")
		lastProcessed = line

		// TODO check if date in granularity / span

		// TODO check any filters

		// TODO Compute
		switch(task.type)
		{
			case TaskType.COUNT:
				echo("hello")
		}

	}
}