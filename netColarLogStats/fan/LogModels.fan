// Artistic License 2.0
// History:
//   Jun 11, 2010 thibautc Creation
//
// DB Objects
using netColarDb
using sql

**
** StatRecord
** Stores computed log stats
**
class LogStatRecord : DBModel
{
	** Stats for a specific server(vhost)
	Int? server
	Str? taskName // name of task
	DateTime? time // time for this data set (rounded to the hour)
	Int value := 0
	Int? uniqueItem // optional id, used for taks that count unique items (Example hits PER unique URL)
	Str? taskSpan // ex: hour, month, year
	//Str? key // name of task
}

**
** A specific server / vhost
**
class LogServer : DBModel
{
	Str? serverName
	//Uri baseUrl

}

**
** Individual log file
**
class LogFile : DBModel
{
	Int serverId := -1// -> fk to Server
	Uri path := ``
	DateTime timestamp := DateTime.defVal
	Int lastLineRead := -1
	//Str md5
	// FileFormat : txt / gz etc.. ?
	// LogFormat : Common, combined, IIS ....
}

**
** A unique "page" (url)
class LogPage : DBModel
{
	Str? path
}

**
** Preferences/config
class LogPrefs : DBModel
{
	Str? key
	Str? value

	static Str? getValue(SqlService db, LogPrefsKey key)
	{
		query := SelectQuery(LogPrefs#).where(QueryCond("key", SqlComp.EQUAL, key.name))
		LogPrefs? entry := findOne(db, query)
		return entry?.value
	}

	static Void setValue(SqlService db, LogPrefsKey key, Str? value)
	{
		query := SelectQuery(LogPrefs#).where(QueryCond("key", SqlComp.EQUAL, key.name))
		LogPrefs entry := findOrCreateOne(db, query)
		entry.key = key.name
		entry.value = value
		entry.save(db)
	}
}

** Preferences names, used as LogPrefs keys
enum class LogPrefsKey
{
	** If false url parameters are not used to determin unique 'page'. Default: false
	urlEnableParams,
	** if urlEnableParams=true, then you can use this to say which params to keep (unique page), others will be dropped
	urlKeepParams,
	** if urlEnableParams=true, then you can use this to specify params to be dropped (unique page), others will be kept
	urlDropParams
}

