// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   23-Apr-2010 tcolar Creation
//
using fwt
using gfx

**
** Main
**
class Main
{
  static Void main()
  {
    Window
    {
      size = Size(300, 300)
	  InsetPane
	  {
		ScrollPane
		{
		  Label{text = "fdsfdsfsdfdsfdfsdfdsfdsfdsfdsfdssfdsfsfsdfdsfdsfdsfdsfdsfdsfdsfdsf"},
		},
	  },
    }.open
  }
}