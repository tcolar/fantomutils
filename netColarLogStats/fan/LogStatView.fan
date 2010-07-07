// Artistic License 2.0
//
// History:
//   Jul 7, 2010 thibautc Creation
//

using fwt
using dom
using gfx

**
** LogStatView
**
@Js
mixin LogStatView
{
	abstract Pane viewPane
	abstract Void fetchData()
}

@Js
class LogHitsView : LogStatView
{
	internal GraphPane pane := GraphPane(Size(700, 350))
	internal GraphPane pane2 := GraphPane(Size(700, 250))
	internal GraphPane pane3 := GraphPane(Size(300, 150))

	override Pane viewPane := GridPane
	{
        numCols = 1
		pane,
		pane2,
		pane3,
	}

	override Void fetchData()
	{
		logReq := LogQueryRequest("monthPageHits",["2007","6"/*,100*/]) // TODO: add a limit option (# of items)
		req := HttpReq { uri=`/data`; async = true}
		req.post(logReq.toStr) |res| { pane.updateData(res.content.in.readObj) }
		req.post(logReq.toStr) |res| { pane2.updateData(res.content.in.readObj) }
		req.post(logReq.toStr) |res| { pane3.updateData(res.content.in.readObj) }
	}
}

enum class GraphType
{
	lineGraph, histogram, pieChart, table
}

enum class GraphWidth
{
	full, half
}

class GraphView
{
	** Data query
	LogQueryRequest query
	** Types of data rendering graph enabled / First is default.
	GraphType[] graphTypes := [GraphType.lineGraph, GraphType.histogram, GraphType.pieChart, GraphType.table]
	** width of graph as a unit
	GraphWidth width := GraphWidth.full
	** height of graph in pixel
	Int height := 250

	new make(LogQueryRequest query)
	{
		this.query = query
	}
}
/*
class GraphPage
{
	Str title := "Stats"
	GraphView[] views := [,]

	Void add(GraphView view) {views.add(view)}
}

enum class GraphPages
{
	hits(GraphPage
			{
				title = "Hits stats"
				GraphView(LogQueryRequest(LogQuery.monthHits.name,["2007","7"]))
				{
					width = GraphWidth.half
				},
				GraphView(LogQueryRequest(LogQuery.monthHits.name,["2007","6"]))
				{
					width = GraphWidth.half
				},
			}
	)

	private new make(GraphPage page)
	{
		this.page = page.toImmutable
	}

	const GraphPage page
}*/