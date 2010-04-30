// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   23-Apr-2010 tcolar Creation
//
using fwt
using gfx

**
** LabelTest
**
class LabelTest
{
  new make()
  {
    // Need this to init gfx env.
    // otherwise RichLabel font.width use throws an Err
    Desktop.bounds

    Window
    {
      title = "Label test"
      size = Size(600, 400)
      TitleBar{text = "New title"},
	}.open
  }

}