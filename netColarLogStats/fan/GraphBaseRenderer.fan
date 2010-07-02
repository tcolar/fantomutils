// Artistic License 2.0
// History:
//   Jun 14, 2010 thibautc Creation
//
using fwt
using gfx

**
** Abstract base of graph renderers
**
@Js
abstract class GraphBaseRenderer : Canvas
{
	** Graph data
	LogDataTableModel? dataModel
	** Total size of graph
	Size? sz
	** Size of Graph (data area)
	Size? graphSize

	static const Font font := Font.fromStr("12pt Lucida Sans Unicode")
	static const Font fontBold := font.toBold

	** Draw the "background" of a x/y type graph (x, y axis with key/values/scale)
	** Can be used by subclasses that want to (Ex: HistogramGraph, lineGraph)
	Void drawGraphBase(Graphics g, Int baseScale)
	{
		g.pen =  Pen { width = 1 }
		g.brush = Color.black
		scale := getFullScale(baseScale)
		hQuart := graphSize.h / 5
		g.antialias = true
		// title
		g.font = fontBold
		g.drawText(dataModel.title, sz.w - 10 - g.font.width(dataModel.title), 1)
		// Draw the graph background
		g.font = font
		g.pen =  Pen { width = 2 }
		g.drawLine(30, 15, 30, sz.h -15)
		g.drawLine(30, sz.h-15, sz.w, sz.h -15)
		g.pen =  Pen { width = 1; dash=[4,4].toImmutable }
		g.brush =  Color.blue
		// Graph value scale : 5, 10, 50, 100, 500, 1k, 5k, 10k, 50k, 100k, 1M, 5M, 10M, 50M, 100M, 500M ...
		Int max := dataModel.dataMaxVal
		(0..4).each
		{
			g.drawLine(30, 15 + hQuart * it, sz.w, 15 + hQuart * it)
			val := scale * (5 - it) / 5
			g.drawText(getScaleTxt(val) , 1, 15 + hQuart * it - 6)
		}
	}

	override Size prefSize(Hints hints := Hints.defVal)
	{
		return sz
	}

	Str getScaleTxt(Int val)
	{
		if(val >= 1_000_000)
			return "${val/1_000_000}M"
		if(val >= 1_000)
			return "${val/1_000}K"
		return val.toStr
	}

	Int getFullScale(Int baseScale)
	{
		max := dataModel.dataMaxVal
		scale := baseScale
		while(max > scale) {scale = scale.toStr[0]=='5' ? scale*2 : scale*5}
		return scale
	}

}

** A set of 'unique' colors
** A new color is returned each time nextColor is called
** Number of colors is finite and will eventually roll over
@Js
class ColorSet
{
	static const Color[] baseColors := [Color.blue, Color.red,
										Color.green, Color.yellow,
										Color.purple, Color.fromStr("#00FFFF"),
										Color.fromStr("#000033"), Color.fromStr("#330000"),
                                        Color.fromStr("#003300"), Color.fromStr("#333300"),
                                        Color.fromStr("#330033"), Color.fromStr("#003333")]
	Int cpt := 0

	** Gives a new different color at each call
	** After the "base" colors have been used, give lighter shades of them by 20% increment
	** Once we got to 80% lighter, start over -> gives a total of 8*4 = 32 "unique" colors
	Color nextColor()
	{
		Color color := baseColors[ cpt % baseColors.size ]
		round := cpt / baseColors.size
		color = color.lighter( round.toFloat * 0.2f )
		cpt ++
		// start over if all colors used
		if(cpt >= baseColors.size * 4) cpt = 0
		return color
	}
}

** A panel that shows a stat graph and let you switch between:
** Raw data, Line chart, Histogram, Pie chart
@Js
class GraphPane : BorderPane
{
  LogDataTableModel? dataModel
  Size sz
  internal Widget graph
  internal GridPane buttons

  new make(Size sz, LogDataTableModel? data := null) : super()
  {
	this.sz = sz
	buttons = getButtons
	graph = EdgePane { center = Label{text="Loading data ..."} }
    insets = Insets(6)
    border = Border("2 #008 5")
    bg = Color("#eeeeff")
	if(data == null)
		updateGraph
	else
		updateData(data)
  }

  Void updateData(LogDataTableModel data)
  {
	dataModel = data
	graph = LineGraphRenderer(dataModel, sz) // Default graph
	updateGraph
  }

  internal Void updateGraph()
  {
	content?.removeAll
	content = GridPane
      {
		buttons,
		ConstraintPane
		{
			minw=sz.w
			maxw=sz.w
			minh=sz.h
			maxh=sz.h
			graph,
		}
    }
	relayout
  }

  GridPane getButtons()
  {
	return GridPane
	{
		numCols = 4
		Button
		{
			text = "LineGraph"
			onAction.add {graph = LineGraphRenderer(dataModel, sz); updateGraph}
		},
		Button
		{
			text = "Histogram"
			onAction.add {graph = HistogramRenderer(dataModel, sz); updateGraph}
		},
		Button
		{
			text = "Pie"
			onAction.add {graph = PieGraphRenderer(dataModel, sz); updateGraph}
		},
		Button
		{
			// TODO: sizing / scrolling still not quite good
			//image = Image(`fan://pod/netColarLogStats/res/table.png`)
			text = "Table"
			onAction.add 
			{
				graph = Table {model = dataModel; multi=true; }
				updateGraph
			}
		},
	}
  }
}

