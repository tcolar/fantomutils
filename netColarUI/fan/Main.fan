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
      content  = BorderPane
      {
          insets = Insets("4")
          bg = Color.red
        content = GridPane
        {
          numCols = 1
          expandCol = 0
          uniformCols = true

          BorderPane{
              insets = Insets("4")
              bg = Color.blue
          content = EdgePane
          {
            left = Label{text = "Hello"}
            right = Label{text = "Bye Bye"}
          }
          },
          BorderPane{bg=Color.yellow; Insets("4")},
        }
      }
    }.open
  }
}