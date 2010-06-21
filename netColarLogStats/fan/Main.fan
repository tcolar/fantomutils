// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
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
		/*SqlService db := SqlService("jdbc:mysql://localhost:3306/fantest", "fantest", "fantest")
		db.open
		model1(db)
		db.close*/

		ServerService().run()
		//TestWindow().open
    }

// for testing
  static LogDataTableModel model1(SqlService db)
  {
	query := SelectQuery(LogStatRecord#).where(QueryCond("server", SqlComp.EQUAL, 1))
					.where(QueryCond("time", SqlComp.GREATER_OR_EQ, "2007-04-00 00:00:00"))
					.where(QueryCond("time", SqlComp.LOWER, "2007-05-00 00:00:00"))
					.where(QueryCond("task_span", SqlComp.EQUAL, TaskGranularity.DAY.name))
					.where(QueryCond("task_name", SqlComp.EQUAL, "TestCounter"))
					.orderBy("time")

	rows := LogStatRecord.findAllRows(db, query)

	formater := |Str str -> Str| {DateTime.fromStr(str).day.toStr}
	model := LogDataTableModel(){it.title = "Daily Hits for 04 2007"}
	LogDataTableModelHelper.injectRows(model, rows, "time", "value", formater)

	// test serialized data
	//Env.cur.out.writeObj(model)

	return model
  }
}
