// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 14, 2010 thibautc Creation
//
using fwt
using gfx

**
** LineGraphRenderer
** Render the data as a line graph
**
class LineGraphRenderer : LogDataRenderer
{
	override Canvas render(LogDataTableModel data, Size sz)
	{
		return LGCanvas(data, sz)
	}
}

class LGCanvas : Canvas
{
	LogDataTableModel data
	Size sz
	Int max := 0

	new make(LogDataTableModel data, Size sz)
	{
		this.data = data
		this.sz = sz
		data.data.vals.each
		{
			if(it>this.max) this.max = it
		}
	}

	override Void onPaint(Graphics g)
	{
		w := size.w
		h := size.h
		graphW := w - 30 // For vertical scale (value)
		graphH := h - 30 // 15 for title, 15 for Horizontal scale
		hQuart := graphH / 4
		g.pen =  Pen { width = 2 }
		g.drawLine(30, 15, 30, h -15)
		g.drawLine(30, h-15, w, h -15)
		g.pen =  Pen { width = 1; dash=[4,4].toImmutable }
		g.brush =  Color.blue
		(0..3).each
		{
			g.drawLine(30, 15 + it*hQuart, w, 15 + it*hQuart)
			val := this.max == 0 ? 0 : this.max / (it + 1)
			g.drawText(val.toStr , 2, 15 + it*hQuart)
		}
	}
}
