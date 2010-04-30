// History:
//   Nov 11, 2009  thibautc  Creation
//
using fwt
using gfx

** Draws a full width Title bar.
** Text can be justified.
**
class TitleBar : GridPane
{
  Str text := ""
  Brush bg := Color("#DDDDDD")
  Brush fg := Color("#000000")
  Font font := Font("bold 12pt Courier")
  ** Aligment of text: L,R,Center
  Halign halign:= Halign.left
  ** Padding to left and right of text (ignore when centered)
  Int sidePadding := 15
  ** Padding above and bellow the text
  Int topBotPadding := 3
  ** Draw an underline across the bottom (x pixels high). 0 = no underline
  Int underlineHeight := 0
  Brush underlineBrush := Color("#000000")

  new make()
  {
	numCols = 1
	expandCol = 0
	halignCells = Halign.fill
	add(TitlebarCanvas(this))
  }
}

class TitlebarCanvas : Canvas
{
  TitleBar bar

  new make(TitleBar bar)
  {
	this.bar = bar
  }

  override Void onPaint(Graphics g)
  {
    w := size.w
    h := size.h
    shade := 1

    g.brush = bar.bg
    g.fillRect(0, 0, w, h)
    g.brush = bar.fg
    g.font = bar.font
    width := bar.font.width(bar.text)
    x := bar.sidePadding
    switch(bar.halign)
    {
	  case Halign.left:
		x = bar.sidePadding
	  case Halign.right:
		x = w - bar.sidePadding - width
	  case Halign.center:
		x = (w - width) / 2
	  default:
		echo("Unsupported Alignment: $bar.halign")
    }
    g.drawText(bar.text, x, bar.topBotPadding)
    if(bar.underlineHeight > 0)
	  {
	  g.fillRect(bar.sidePadding, h - bar.underlineHeight, w - bar.sidePadding * 2, bar.underlineHeight)
    }
  }

  override Size prefSize(Hints hints := Hints.defVal)
  {
    return Size(bar.font.width(bar.text) + bar.sidePadding * 2, bar.font.height + bar.topBotPadding * 2)
  }
}
