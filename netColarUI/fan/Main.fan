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
      size = Size(800,600)
      GridPane
      {
        numCols = 1
        expandCol = 0
        uniformCols = true
        halignCells = Halign.fill

        EdgePane
        {
          left = Label{text = "Hello"}
          right = Label{text = "Bye Bye"}
        },
        TitleBar{text="hello dude"},
      },
    }.open
  }
}