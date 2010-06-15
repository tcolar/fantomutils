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
	Int nbVals

	new make(LogDataTableModel data, Size sz)
	{
		this.data = data
		this.sz = sz
		nbVals = 0
		data.data.vals.each
		{
			if(it>this.max) this.max = it
			nbVals++
		}
	}

	override Void onPaint(Graphics g)
	{
		w := size.w
		h := size.h
		graphW := w - 40 // 30 For vertical scale (value), 10 for padding on right
		graphH := h - 30 // 15 for title, 15 for Horizontal scale
		hQuart := graphH / 5
		g.antialias = true
		// title
		g.font = Font.fromStr("bold 8pt Times Roman")
		g.drawText(data.title, w - 10 - g.font.width(data.title), 1)
		// Draw the graph background
		g.font = Font.fromStr("8pt Times Roman")
		g.pen =  Pen { width = 2 }
		g.drawLine(30, 15, 30, h -15)
		g.drawLine(30, h-15, w, h -15)
		g.pen =  Pen { width = 1; dash=[4,4].toImmutable }
		g.brush =  Color.blue
		// Graph value scale : 5, 10, 50, 100, 500, 1k, 5k, 10k, 50k, 100k, 1M, 5M, 10M, 50M, 100M, 500M ...
		scale := 5
		while(this.max > scale) {scale = scale.toStr[0]=='5' ? scale*2 : scale*5}
		(0..4).each
		{
			g.drawLine(30, 15 + it*hQuart, w, 15 + it*hQuart)
			val := scale * (5 - it) / 5
			g.drawText(getScaleTxt(val) , 1, 15 + it*hQuart - 6)
		}
		interval := (graphW - 1).toFloat / (nbVals - 1).toFloat
		// Add data keys (if their is enough room)
		cpt := 0
		lastX := 0
		g.pen =  Pen { width = 2 }
		data.data.each |Int val, Str key|
		{
			key = data.getFormatedKeyText(key)
			lx := (30.toFloat + interval*cpt.toFloat).toInt
			if(lastX < lx -12)
			{
				g.drawText(key, lx - (g.font.width(key) / 2), h - 14)
				lastX = lx - 6 + g.font.width(key)
				g.drawLine(lx , h - 18, lx, h - 15)
			}
			cpt++
		}
		// Plot the data
		g.brush =  Color.makeRgb(0xFF, 0x66, 0x66)
		Point? prev
		cpt = 0
		data.data.each |Int val, Str key|
		{
			// Add data points and link them with line
			p := Point((30.toFloat + interval*cpt.toFloat).toInt, h - 15 - (graphH * val) / scale)
			g.fillOval(p.x-2, p.y-2, 6, 6)
			if(prev!=null) g.drawLine(p.x, p.y, prev.x, prev.y);
			prev = p
			cpt++
		}
	}

	Str getScaleTxt(Int val)
	{
		if(val >= 1_000_000)
			return "${val/1_000_000}M"
		if(val >= 1_000)
			return "${val/1_000}K"
		return val.toStr
	}

	override Size prefSize(Hints hints := Hints.defVal)
	{
		return sz
	}
}
