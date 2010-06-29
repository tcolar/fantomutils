// Artistic License 2.0
// History:
//   Jun 16, 2010 thibautc Creation
//

using fwt
using gfx

**
** HistogramRenderer
**
@Js
class HistogramRenderer : GraphBaseRenderer
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
		// draw base
		drawGraphBase(g, baseScale)
		// Add data keys (if their is enough room)
		interval := (graphSize.w - 1).toFloat / nbVals.toFloat
		cpt := 0
		lastX := 0
		g.pen =  Pen { width = 2 }
		dataModel.data.each |LogDataPoint p|
		{
			key := p.formatedKey
			lx := (31.toFloat + interval*cpt.toFloat + interval/2f - g.font.width(key).toFloat/2f).toInt
			if(lastX < lx - 12)
			{
				g.drawText(key, lx , sz.h - 14)
				lastX = lx + g.font.width(key)
			}
			cpt++
		}
		// Plot the data
		ColorSet colors := ColorSet()
		cpt = 0
		dataModel.data.each |LogDataPoint point|
		{
			// Add data bars
			g.brush =  colors.nextColor
			p := Point((31.toFloat + interval*cpt.toFloat).toInt, sz.h - 15 - (graphSize.h * point.val) / fullScale)
			g.fillRect(p.x, p.y, interval.toInt, sz.h - 16 - p.y)
			cpt++
		}
	}
}
