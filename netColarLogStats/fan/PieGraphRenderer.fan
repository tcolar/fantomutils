// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 16, 2010 thibautc Creation
//
using fwt
using gfx

**
** PieGraphRenderer
**
class PieGraphRenderer : GraphBaseRenderer
{
	** Only values representing at least than minPct percentage will be shown (default: 2)
	Int minPct := 2
	** Can also use this to show only the top 'n' slices
	Int maxSlices := 20

	internal Str:Int data
	internal Int longestKey

	new make(LogDataTableModel dataModel, Size sz)
	{
		this.dataModel = dataModel
		data = filterData(dataModel.data)
		this.sz = sz
	}

	override Void onPaint(Graphics g)
	{
		dataTotal := dataTotal(data).toFloat

		g.antialias = true
		g.font = Font.fromStr("8pt Times Roman")

		// calculate longest key text size (pixels)
		longestKey = data.keys.reduce(0) |Int r, Str v -> Int| 
		{
			w := g.font.width( dataModel.formatedKeys[v] )
			return w > r ? w : r
		}
		// size of the "pie"
		// 30 for padding on each side + 15 between graph and legend + longest key text + 10 : key square + 6 : k square spacing
		// 30 at top: title + spacing + 15 at bottom
		// We want the pie to be "circle" (not a strectched oval)
		Int smallest := (sz.w - 45 - 10 -6 - longestKey).min(sz.h - 45)
		graphSize = Size(smallest, smallest)
		totalSize := Size(smallest + 15 + longestKey + 10 + 6, smallest)

		// title
		g.font = Font.fromStr("bold 8pt Times Roman")
		g.drawText(dataModel.title, sz.w / 2 - g.font.width(dataModel.title) / 2, 1)

		g.font = Font.fromStr("8pt Times Roman")
		ColorSet colors := ColorSet()
		// I want to start at "noon" on the pie chart
		curAngle := 90f
		// We will center the pie and legend in te middle of the full graph
		startX := sz.w /2 - totalSize.w / 2
		startY := sz.h /2 - totalSize.h / 2
		startYKeys := sz.h /2 - ( (data.size+1) * 15) / 2
		// empty pie
		g.brush = Color.white
		g.fillOval(startX, startY, graphSize.w, graphSize.h)
		g.brush = Color.black
		g.drawOval(startX, startY, graphSize.w, graphSize.h)
		// pie data
		data.each |val, key|
		{
			color := colors.nextColor
			// keys / legend
			g.brush = Color.black
			g.drawRect(startX + graphSize.w + 15, startYKeys, 10, 10)
			g.drawText(dataModel.formatedKeys[key], startX + graphSize.w + 15 + 10 + 6, startYKeys)
			g.brush = color
			g.fillRect(startX + graphSize.w + 15 + 1, startYKeys+1, 9, 9)
			// draw the slice
			Float arcAngle := val.toFloat / dataTotal * 360f
			// I want to go clockwise (negative values)
			g.fillArc(startX, startY, graphSize.w, graphSize.h, curAngle.toInt, - arcAngle.toInt -1)
			curAngle -= arcAngle

			startYKeys += 15
		}
		// "Others" legend
		g.brush = Color.white
		g.fillRect(startX + graphSize.w + 15, startYKeys, 10, 10)
		g.brush = Color.black
		g.drawRect(startX + graphSize.w + 15, startYKeys, 10, 10)
		g.drawText("Others", startX + graphSize.w + 15 + 10 + 6, startYKeys)

	}

	internal Str:Int filterData(Str:Int data)
	{
		Int max := maxDataVal(data)
		// Order from high to low
		Str:Int newData := [:] {ordered = true}
		// Only keep value above a certain %
		cpt := 0
		data.each |i, s|
		{
			if( i * max / 100 < minPct || newData.size == maxSlices)
				return
			newData.set(s, i)
		}
		return newData
	}
}