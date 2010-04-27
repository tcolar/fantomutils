// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Apr 22, 2010 thibautc Creation
//
using fwt
using gfx

**
**  Basic RichTextModel for styling a text
**  It support s "plain" text wit lines separated by \n
**  The whole text is style with ONE style
**
class BasicRichTextModel : RichTextModel
{
  ** Style
  RichTextStyle style := RichTextStyle { font = Font { size = 10 }}
  ** the text
  override Str text := ""

  override Int charCount()
  {
    text.size
  }

  override Int lineCount()
  {
    text.splitLines.size
  }

  override Str line(Int lineIndex)
  {
    text.splitLines[lineIndex]
  }

  override Int lineAtOffset(Int offset)
  {
    line := 0
    for (i:=0; i<offset; ++i) if (text[i] == '\n') line++
    return line
  }

  override Int offsetAtLine(Int lineIndex)
  {
    Int r := text.splitLines[0..<lineIndex]
      .reduce(0) |Obj o, Str line->Int| { return line.size+o+1 }
    return r
  }

  override Str textRange(Int start, Int len)
  {
    text[start..<start+len]
  }

  override Void modify(Int start, Int len, Str newText)
  {
    // update model
    oldText := textRange(start, len)
    text = text[0..<start] + newText + text[start+len..-1]

    // must fire modify event
    tc := TextChange
    {
      it.startOffset    = start
      it.startLine      = lineAtOffset(start)
      it.oldText        = oldText
      it.newText        = newText
      it.oldNumNewlines = oldText.numNewlines
      it.newNumNewlines = newText.numNewlines
    }
    onModify.fire(Event { id = EventId.modified; data = tc })
  }

  override Obj[]? lineStyling(Int lineIndex)
  {
      return [style]
  }

}