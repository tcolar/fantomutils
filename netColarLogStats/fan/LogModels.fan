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
	** Stats for a specific server(vhost)
	Int? server
	Str? taskName // name of task
	DateTime? time // time for this data set (rounded to the hour)
	Str? taskSpan // ex: hour, month, year
	//Str? key // name of task
	Int value := 0
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