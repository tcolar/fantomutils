// Artistic License 2.0
// History:
//   Jun 14, 2010 thibautc Creation
//
using fwt
using gfx

**
** LineGraphRenderer
** Render the data as a line graph
**
@Js
class LineGraphRenderer : GraphBaseRenderer
{
	new make(LogDataTableModel dataModel, Size sz)
	{
		this.dataModel = dataModel
		this.sz = sz
		// 30 For vertical scale (value) + 10 for padding on right
		// 15 for title, 15 for Horizontal scale
		graphSize = Size(sz.w - 40, sz.h - 30)
	}

	override Void onPaint(Graphics g)
	{
		baseScale := 5
		max := dataModel.dataMaxVal
		nbVals := dataModel.data.size
		fullScale := getFullScale(baseScale)

		// draw base graph
		drawGraphBase(g, baseScale)
		interval := (graphSize.w - 1).toFloat / (nbVals - 1).toFloat
		// Add data keys (if their is enough room)
		cpt := 0
		lastX := 0
		g.pen =  Pen { width = 2 }
		dataModel.data.each |LogDataPoint p|
		{
			key := p.formatedKey
			lx := (30.toFloat + interval*cpt.toFloat).toInt
			if(lastX < lx -12)
			{
				g.drawText(key, lx - (g.font.width(key) / 2), sz.h - 14)
				lastX = lx - 6 + g.font.width(key)
				g.drawLine(lx , sz.h - 18, lx, sz.h - 15)
			}
			cpt++
		}
		// Plot the data
		g.brush =  Color.makeRgb(0xFF, 0x66, 0x66)
		Point? prev
		cpt = 0
		dataModel.data.each |LogDataPoint point|
		{
			// Add data points and link them with line
			p := Point((30.toFloat + interval*cpt.toFloat).toInt, sz.h - 15 - (graphSize.h * point.val) / fullScale)
			g.fillOval(p.x-2, p.y-2, 6, 6)
			if(prev!=null) g.drawLine(p.x, p.y, prev.x, prev.y);
			prev = p
			cpt++
		}
	}

}
