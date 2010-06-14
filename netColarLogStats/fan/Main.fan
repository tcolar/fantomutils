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
		LogWindow().open
    }
    
}

class LogWindow : Window
{
  new make() : super(null, null)
  {
	// temporary testing code, relies on data entered in db by test:ParserTest for now

    SqlService db := SqlService("jdbc:mysql://localhost:3306/fantest", "fantest", "fantest")
    db.open

	query := SelectQuery(LogStatRecord#).where(QueryCond("server", SqlComp.EQUAL, 1))
					.where(QueryCond("time", SqlComp.GREATER_OR_EQ, "2010-06-13 00:00:00"))
					.where(QueryCond("time", SqlComp.LOWER, "2010-06-14 00:00:00"))
					.where(QueryCond("task_span", SqlComp.EQUAL, TaskGranularity.HOUR.name))
					.where(QueryCond("task_name", SqlComp.EQUAL, "TestCounter"))
					.orderBy("time")
	rows := LogStatRecord.findAllRows(db, query)
    //table = Table { model = LogDataTableModel(rows, "time", "value") }
    content = LineGraphRenderer().render(LogDataTableModel(rows, "time", "value"), Size(400, 400))
	db.close()
  }

  Void main()
  {
    open
  }
}