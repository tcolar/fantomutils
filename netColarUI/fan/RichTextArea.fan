// History:
//   Apr 22, 2010 thibautc Creation
//
using fwt
using gfx

**
** RichTextArea
** A customizable text "area" (can be multiline)
** Text is selectable (copy/paste)
** Can be made 'Editable' (not by default)
** Based on RichText, so the text style can be customized (color etc..)
**
class RichTextArea : RichText
{
    new make(Str lblText, RichTextStyle? lblStyle := null) : super()
    {
        myModel := BasicRichTextModel()
        {
          it.text = lblText
          if(lblStyle!=null)
            style = lblStyle
        }
        model = myModel
        prefRows = myModel.lineCount
        editable = false
        hscroll = false
        vscroll = false
        border = false
    }

    override Size prefSize(Hints hints := Hints.defVal)
    {
        md := model as BasicRichTextModel
        // TODO: unfortunately margins are hardcoded in RichTextPeer (top:0, others: 8)
        w := md.lineCount * md.style.font.width(text) + 16 + 2
        h := md.lineCount * md.style.font.height() + 8
        return Size(w, h)
    }
}

