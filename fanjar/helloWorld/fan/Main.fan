// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Dec 15, 2009  thibautc  Creation
//
using fwt
using gfx

**
** Main
**
class Main
{
    
    **
    ** Main method
    **
    static Void main()
    {
	 20.times
	 {
		Actor.sleep(500ms)
        	echo("Hello world from Fan")
	 }
    }
    
	**
	** Alternate Main uisng fwt
	** 
	static Void mainFwt()
	{
		Window
		{
		size = Size(300,200)
		Label { text = "Hello world"; halign=Halign.center },
		}.open
	}
}


