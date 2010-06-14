// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 14, 2010 thibautc Creation
//
using wisp
using web
using webmod
using util
using fwt
using netColarDb
using sql

**
** ServerService
**
/*class ServerService : AbstractMain
{
  @Opt { help = "http port" }
  Int port := 8480

  override Int run()
  {
    wisp := WispService
    {
      it.port = this.port
      it.root = ServerMod()
    }
    return runServices([wisp])
  }

}

const class ServerMod : WebMod
{
  override Void onGet()
  {
	Weblet(LogWindow()).onService
  }

  override Void onPost()
  {
    super.onPost
  }
}
*/
