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

    content = GridPane
	{
		GridPane
		{
			numCols = 2; 
			LineGraphRenderer(model1(db), Size(400, 200)),
			HistogramRenderer(model1(db), Size(400, 200)),
		},
		GridPane
		{
			numCols = 2;
			LineGraphRenderer(model2(db), Size(400, 200)),
			HistogramRenderer(model2(db), Size(400, 200)),
		},
		GridPane
		{
			numCols = 3;
			LineGraphRenderer(model3(db), Size(300, 200)),
			HistogramRenderer(model3(db), Size(300, 200)),
			PieGraphRenderer(model3(db), Size(200, 200)),
		},
	}
	db.close()
  }

  LogDataTableModel model1(SqlService db)
  {
	query := SelectQuery(LogStatRecord#).where(QueryCond("server", SqlComp.EQUAL, 1))
					.where(QueryCond("time", SqlComp.GREATER_OR_EQ, "2007-04-00 00:00:00"))
					.where(QueryCond("time", SqlComp.LOWER, "2007-05-00 00:00:00"))
					.where(QueryCond("task_span", SqlComp.EQUAL, TaskGranularity.DAY.name))
					.where(QueryCond("task_name", SqlComp.EQUAL, "TestCounter"))
					.orderBy("time")
	rows := LogStatRecord.findAllRows(db, query)

	formater := |Str str -> Str| {DateTime.fromStr(str).day.toStr}
	model := LogDataTableModel(rows, "time", "value"){it.title = "Daily Hits for 04 2007"; keyTextFormater = formater}
	return model
  }

  LogDataTableModel model2(SqlService db)
  {
	query := SelectQuery(LogStatRecord#).where(QueryCond("server", SqlComp.EQUAL, 1))
					.where(QueryCond("time", SqlComp.GREATER_OR_EQ, "2007-01-01 00:00:00"))
					.where(QueryCond("time", SqlComp.LOWER, "2008-01-01 00:00:00"))
					.where(QueryCond("task_span", SqlComp.EQUAL, TaskGranularity.DAY.name))
					.where(QueryCond("task_name", SqlComp.EQUAL, "TestCounter"))
					.orderBy("time")
	rows := LogStatRecord.findAllRows(db, query)

	formater := |Str str -> Str| {DateTime.fromStr(str).dayOfYear.toStr}
	model := LogDataTableModel(rows, "time", "value") {it.title = "Daily Hits for 2007"; keyTextFormater = formater}
	return model
  }

  LogDataTableModel model3(SqlService db)
  {
	query := SelectQuery(LogStatRecord#).where(QueryCond("server", SqlComp.EQUAL, 1))
					.where(QueryCond("time", SqlComp.GREATER_OR_EQ, "2007-01-01 00:00:00"))
					.where(QueryCond("time", SqlComp.LOWER, "2008-01-01 00:00:00"))
					.where(QueryCond("task_span", SqlComp.EQUAL, TaskGranularity.MONTH.name))
					.where(QueryCond("task_name", SqlComp.EQUAL, "TestCounter"))
					.orderBy("time")
	rows := LogStatRecord.findAllRows(db, query)

	formater := |Str str -> Str| {DateTime.fromStr(str).month.toStr}
	model := LogDataTableModel(rows, "time", "value") {it.title = "Monthly Hits for 2007"; keyTextFormater = formater}
	return model
  }

  Void main()
  {
	size = Size(600, 600)
    open
  }
}