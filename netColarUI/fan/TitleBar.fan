// History:
//   Nov 11, 2009  thibautc  Creation
//
using fwt
using gfx

** Draws a full width Title bar.
** Text can be justified.
class TitleBar : Canvas
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

  override Void onPaint(Graphics g)
  {
    w := size.w
    h := size.h
    shade := 1

    g.brush = bg
    g.fillRect(0, 0, w, h)
    g.brush = fg
    g.font = font
    width := font.width(text)
    x := sidePadding
    switch(halign)
    {
        case Halign.left:
            x = sidePadding
        case Halign.right:
            x = w - sidePadding - width
        case Halign.center:
            x = (w - width) / 2
        default:
            echo("Unsupported Alignment: $halign")
    }
    g.drawText(text, x, topBotPadding)
    if(underlineHeight > 0)
    {
       g.fillRect(sidePadding, h - underlineHeight, w - sidePadding * 2, underlineHeight)
    }
  }

  override Size prefSize(Hints hints := Hints.defVal)
  {
    echo("Hints: "+hints)
    return Size(font.width(text) + sidePadding * 2, font.height + topBotPadding * 2)
  }
}
