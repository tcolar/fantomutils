// Artistic License 2.0
// History:
//   Jun 8, 2010 thibautc Creation
//
using fwt
using netColarDb
using sql
using gfx

**
** Main
**
class Main
{
    **
    ** Main method
    **
    static Void main()
    {
		//db := SqlService("jdbc:mysql://localhost:3306/fantest", "fantest", "fantest")
		//db := SqlService("jdbc:h2:~/fantest", "sa", "")
		db := SqlService("jdbc:hsqldb:file://tmp/fantest", "sa", "")
		//updateStats(db)
		ServerService(db).run()
		echo("service done")
    }

	** Parse test log data and run test jobs to pupulate test log data points
	static Void updateStats(SqlService db)
	{
		db.open
		// start with clean sheet
		DBUtil.deleteTable(db, DBUtil.normalizeDBName(LogServer#.name))
		DBUtil.deleteTable(db, DBUtil.normalizeDBName(LogFile#.name))
		DBUtil.deleteTable(db, DBUtil.normalizeDBName(LogPage#.name))
		DBUtil.deleteTable(db, DBUtil.normalizeDBName(LogStatRecord#.name))
		DBUtil.deleteTable(db, DBUtil.counterTable)

		server := LogServer{serverName = "test"}
		server.save(db)
		log := LogFile{serverId = server.id; path = `/home/thibautc/colar_06.log`}
		log.save(db)

		task := LogTask
		{
			uniqueName = "Hits"
			serverId = server.id
			type = TaskType.COUNT
		}
		LogTaskRunner(task).run(db)

		task2 := LogTask
		{
			uniqueName = "PageHits"
			serverId = server.id
			type = TaskType.COUNT_UNIQUE
		}
		LogTaskRunner(task2).run(db)
		db.close
	}
}
