// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 14, 2010 thibautc Creation
//
using fwt
using gfx

**
** Abstract base of graph renderers
**
abstract class GraphBaseRenderer : Canvas
{
	** Graph data
	LogDataTableModel? dataModel
	** Total size of graph
	Size? sz
	** Size of Graph (data area)
	Size? graphSize

	** Draw the "background" of a x/y type graph (x, y axis with key/values/scale)
	** Can be used by subclasses that want to (Ex: HistogramGraph, lineGraph)
	Void drawGraphBase(Graphics g, Int baseScale)
	{
		scale := getFullScale(baseScale)
		hQuart := graphSize.h / 5
		g.antialias = true
		// title
		g.font = Font.fromStr("bold 8pt Times Roman")
		g.drawText(dataModel.title, sz.w - 10 - g.font.width(dataModel.title), 1)
		// Draw the graph background
		g.font = Font.fromStr("8pt Times Roman")
		g.pen =  Pen { width = 2 }
		g.drawLine(30, 15, 30, sz.h -15)
		g.drawLine(30, sz.h-15, sz.w, sz.h -15)
		g.pen =  Pen { width = 1; dash=[4,4].toImmutable }
		g.brush =  Color.blue
		// Graph value scale : 5, 10, 50, 100, 500, 1k, 5k, 10k, 50k, 100k, 1M, 5M, 10M, 50M, 100M, 500M ...
		Int max := maxDataVal(dataModel.data)
		(0..4).each
		{
			g.drawLine(30, 15 + hQuart * it, sz.w, 15 + hQuart * it)
			val := scale * (5 - it) / 5
			g.drawText(getScaleTxt(val) , 1, 15 + hQuart * it - 6)
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

	Int getFullScale(Int baseScale)
	{
		max := dataModel.data.vals.max
		scale := baseScale
		while(max > scale) {scale = scale.toStr[0]=='5' ? scale*2 : scale*5}
		return scale
	}

	Int maxDataVal(Str:Int data)
	{
		data.vals.max
	}

	Int dataTotal(Str:Int data)
	{
		data.vals.reduce(0) |Int r, Int v -> Int| {return v + r}
	}
}

** A set of 'unique' colors
** A new color is returned each time nextColor is called
** ~ 32 different colors returned
class ColorSet
{
	static const Color[] baseColors := [Color.blue, Color.red,
										Color.green, Color.yellow,
										Color.purple, Color.orange,
										Color.gray, Color.black]
	Int cpt := 0

	** Gives a new different color at each call
	** After the 8 "base" colors have been used, give lighter shades of them by 20% increment
	** Once we got to 80% lighter, start over -> gives a total of 8*4 = 32 "unique" colors
	Color nextColor()
	{
		Color color := baseColors[ cpt % baseColors.size ]
		round := cpt / baseColors.size
		color = color.lighter( round.toFloat * 0.2f )
		cpt ++
		// start over if all 32 colors used
		if(cpt >= baseColors.size * 4) cpt = 0
		return color
	}
}
