// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 10, 2010 thibautc Creation
//

**
** LogTask : Defines a log task
**
class LogTask
{
	Int serverId
	TaskType type := TaskType.COUNT
	//TaskGranularity granularity := TaskGranularity.DAY -> maybe this is a 'reporting' option not task
	//TaskSpan span := TaskSpan.CUR_YEAR -> maybe this is a 'reporting' option not task
	TaskTarget target := TaskTarget.URL
	//Int limiter := -1 -> maybe this is a 'reporting' option not task
	TaskFilter[] filters := [,]
	// DateTime lastRun
}

const class TaskFilter
{
	new make(TaskTarget target, Obj? value, TaskFilterType type := TaskFilterType.EQUALS)
	{
		this.target = target
		this.value = value
		this.filterType = type
	}

	const TaskTarget target
	const TaskFilterType filterType
	const Obj? value
}

enum class TaskFilterType
{
	IS_EMPTY, IS_NOT_EMPTY, EQUALS, NOT_EQUALS, STARTS_WITH, ENDS_WITH, CONTAINS,
	GREATER_THAN, LOWER_THAN, MATCH_PATTERN, NOT_MATCH_PATTERN
}


enum class TaskType
{
	COUNT, COUNT_UNIQUE, AVERAGE, AVERAGE_UNIQUE
}

enum class TaskGranularity
{
	HOUR, DAY, WEEK, MONTH, YEAR
}

enum class TaskSpan
{
	ALL, CUR_YEAR, CUR_MONTH, CUR_WEEK, CUR_DAY
}

enum class TaskTarget
{
	HOST, IDENTD, USER, METHOD, URL, PROTO, STATUS, SIZE, REFERER, AGENT
}
