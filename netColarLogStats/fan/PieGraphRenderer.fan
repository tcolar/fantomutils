// Artistic License 2.0
// History:
//   Jun 16, 2010 thibautc Creation
//
using fwt
using gfx

**
** PieGraphRenderer
**
@Js
class PieGraphRenderer : GraphBaseRenderer
{
	** Only values representing at least than minPct percentage will be shown (default: 2)
	Int minPct := 2
	** Can also use this to show only the top 'n' slices
	Int maxSlices := 15

	internal LogDataPoint[] data
	internal Int longestKey
	internal Bool hasOthers := false

	new make(LogDataTableModel dataModel, Size sz)
	{
		this.dataModel = dataModel
		data = filterData(dataModel)
		this.sz = sz
	}

	override Void onPaint(Graphics g)
	{
		g.pen =  Pen { width = 1 }
		g.brush = Color.black

		dataTotal := dataModel.dataTotal.toFloat

		g.antialias = true
		g.font = font

		// calculate longest key text size (pixels)
		longestKey = data.reduce(0) |Int v, LogDataPoint p -> Int|
		{
			pct := p.val.toFloat * 100f / dataTotal
			pctStr := pct.toLocale("0.00")
			txt := "${p.formatedKey} - ${pctStr}%"
			w := g.font.width( txt )
			return w > v ? w : v
		}
		// size of the "pie"
		// 30 for padding on each side + 15 between graph and legend + longest key text + 10 : key square + 6 : k square spacing
		// 30 at top: title + spacing + 15 at bottom
		// We want the pie to be "circle" (not a strectched oval)
		Int smallest := (sz.w - 45 - 10 -6 - longestKey).min(sz.h - 45)
		graphSize = Size(smallest, smallest)
		totalSize := Size(smallest + 15 + longestKey + 10 + 6, smallest)

		// title
		g.font = fontBold
		g.drawText(dataModel.title, sz.w / 2 - g.font.width(dataModel.title) / 2, 1)

		g.font = font
		ColorSet colors := ColorSet()
		// I want to start at "noon" on the pie chart
		curAngle := 180f
		// We will center the pie and legend in te middle of the full graph
		startX := sz.w /2 - totalSize.w / 2
		startY := sz.h /2 - totalSize.h / 2
		startYKeys := sz.h /2 - ( (data.size + (hasOthers?1:0)) * 15) / 2
		// empty pie
		g.brush = Color.white
		g.fillOval(startX, startY, graphSize.w, graphSize.h)
		// pie data
		data.each |LogDataPoint p|
		{
			color := colors.nextColor
			// keys / legend
			g.brush = Color.black
			g.drawRect(startX + graphSize.w + 15, startYKeys, 10, 10)
			pct := p.val.toFloat * 100f / dataTotal
			pctStr := pct.toLocale("0.00")
			txt := "${p.formatedKey} - ${pctStr}%"
			g.drawText(txt, startX + graphSize.w + 15 + 10 + 6, startYKeys)
			g.brush = color
			g.fillRect(startX + graphSize.w + 15 + 1, startYKeys+1, 9, 9)
			// draw the slice
			Float arcAngle := p.val.toFloat / dataTotal * 360f
			// I want to go clockwise (negative values)
			//g.fillArc(startX, startY, graphSize.w, graphSize.h, curAngle.toInt, - arcAngle.toInt -1)
			radius := (graphSize.w / 2)
			midX := startX + graphSize.w/2 + 1
			midY := startY + graphSize.h/2 + 1
			fillArc(g, midX, midY, radius, curAngle, arcAngle)

			curAngle -= arcAngle

			startYKeys += 15
		}
		if(hasOthers)
		{
			// "Others" legend
			g.brush = Color.white
			g.fillRect(startX + graphSize.w + 15, startYKeys, 10, 10)
			g.brush = Color.black
			g.drawRect(startX + graphSize.w + 15, startYKeys, 10, 10)
			g.drawText("Others", startX + graphSize.w + 15 + 10 + 6, startYKeys)
		}
		// Pie border - draw it last as it helps the appearance of my 'fake' fillArc impl.
		g.brush = Color.black
		g.pen =  Pen { width = 2 }
		g.drawOval(startX, startY, graphSize.w, graphSize.h)
	}

	** Temporary impl. of fillArc as Fantrom does not have that impl. yet in javascript
	** Not very good, but OK
	internal Void fillArc(Graphics g, Int midX, Int midY, Int radius, Float startAngle, Float arcAngle)
	{
		points := Point[,]
		points.add(Point(midX, midY))
		(startAngle.toInt .. (startAngle - arcAngle - 1f).toInt).each
		{
			rad := it.toFloat * Float.pi / 180f
			points.add(Point((rad.sin * radius.toFloat).toInt + midX, (rad.cos * radius.toFloat).toInt + midY))
		}
		g.fillPolygon(points)
	}


	internal LogDataPoint[] filterData(LogDataTableModel model)
	{
		Int max := model.dataMaxVal
		// Order from high to low (working on data copy)
		data := model.data.dup().sort |LogDataPoint a, LogDataPoint b -> Int| {return b.val <=> a.val}
		LogDataPoint[] newData := [,]
		cpt := 0
		// filter
		data.each |LogDataPoint p|
		{
			// Only keep value above a certain %, up to maxSlices items
			if( p.val * max / 100 < minPct || newData.size == maxSlices)
				{hasOthers = true; return}
			newData.add(p)
		}
		return newData
	}
}