// Include failed for:../../Licenses/FanDefaultLicense.txt->java.lang.NullPointerException
//
// History:
//   Nov 11, 2009  thibautc  Creation
//
using fwt
using gfx

**
** PropertyTable
** Displays a TitleBar, followed by a a key / value set (Grid)
**
class PropertyTable : EdgePane
{
  GridPane data
  Str textFont

  new make(Str title, Map props, Str textFont:="10pt Courier") : super()
  {
    this.textFont = textFont
    data = dataPane(props)
    top =  TitleBar
    {
      text = title
      font = Font("bold "+textFont)
      underlineHeight = 2
    }
    center = data
  }

  Void updateProps(Map props)
  {
    data = dataPane(props)
    center = data
    relayout
  }


  GridPane dataPane(Map props)
  {
    grid := GridPane
    {
      it.numCols = 2
    }

    props.each |Str value, Str key|
    {
      desc := Label
      {
        text = key
        font = Font("bold "+textFont)
        fg = Color("#000")
      }
      val := RichTextArea(value, RichTextStyle{ font = Font(textFont) })
      grid.add(desc)
      grid.add(val)
    }
      
    return grid
  }
}

