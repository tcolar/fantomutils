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
		return LGCanvas()
	}
}

class LGCanvas : Canvas
{
	override Void onPaint(Graphics g)
	{
		// TODO
		g.drawOval(50,50,50,50)
	}
}
