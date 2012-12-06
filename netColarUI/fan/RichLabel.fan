// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Apr 22, 2010 thibautc Creation
//
using fwt
using gfx

**
** RichLabel
**
class RichLabel : RichText
{
  new make(Str lblText, RichTextStyle? lblStyle := null) : super()
  {
    prefRows = 1
    editable = false
    hscroll = false
    vscroll = false
    border = false
    model = BasicRichTextModel()
    {
      it.text = lblText
      if(lblStyle!=null)
        style = lblStyle
    }
    pack
  }

  override Size prefSize(Hints hints := Hints.defVal)
  {
    md := model as BasicRichTextModel
    w := md.style.font.width(text) + 16
    h := md.style.font.height() + 11
    return Size(w, h)
  }
}

