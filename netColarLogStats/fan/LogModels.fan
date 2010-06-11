// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 11, 2010 thibautc Creation
//
using netColarDb

// DB Objects

**
** StatRecord
** Stores computed log stats
**
class LogStatRecord : DBModel
{
	** Stats for a specific server(vhost), null = all
	Str? server
	Int? year
	Int? month
	Int? week
	Int? day
	Int? hour
	Str? task_name
	Str? key
	Int? value
	** Timestamp of the last log entry counted
	DateTime? lastEntryTime
}

**
** A specific server / vhost
**
class LogServer : DBModel
{
	Str? serverName
	//Uri baseUrl

	new make(Str name) {serverName = name}
}

**
** Individual log file
**
class LogFile : DBModel
{
	Int serverId // -> fk to Server
	Uri path
	DateTime timestamp := DateTime.defVal
	Int lastLineRead := -1
	//Str md5
	// FileFormat : txt / gz etc.. ?
	// LogFormat : Common, combined, IIS ....

	new make(Int serverId, Uri path)
	{
		this.serverId = serverId
		this.path = path
	}
}